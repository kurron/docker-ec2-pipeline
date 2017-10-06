#!/bin/bash

# Environment variables required by the AWS CLI
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-west-2}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-CHANGEME}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-CHANGEME}

# Environment variables needed to map the Docker user to the user's Environment
USER_ID=${USER_ID:-$(id -u $(whoami))}
GROUP_ID=${GROUP_ID:-$(id -g $(whoami))}
HOME_DIR=${HOME_DIR:-$(cut -d: -f6 < <(getent passwd ${USER_ID}))}

# Environment variables required to identify the correct EC2 instances
PROJECT=${PROJECT:-Weapon-X}
ENVIRONMENT=${ENVIRONMENT:-development}
BASTION_TAG=${BASTION_TAG:-Bastion}
PRIVATE_TAG=${PRIVATE_TAG:-Docker}

# Environment variables needed to contact Hashicorp's Vault
VAULT_ADDR=${VAULT_ADDR:-http://192.168.254.90:8200}
ROLE_ID=${ROLE_ID:-CHANGEME}
SECRET_ID=${SECRET_ID:-CHANGEME}
VAULT_PATH=${VAULT_PATH:-CHANGEME}

function determineBastionAddress() {
  local STATE_FILTER=Name=instance-state-name,Values=running
  local PROJECT_FILTER=Name=tag:Project,Values=${PROJECT}
  local ENVIRONMENT_FILTER=Name=tag:Environment,Values=${ENVIRONMENT}
  local DUTY_FILTER=Name=tag:Duty,Values=${BASTION_TAG}

  local CMD="aws ec2 describe-instances \
                 --filters ${STATE_FILTER} \
                 --filters ${PROJECT_FILTER} \
                 --filters ${ENVIRONMENT_FILTER} \
                 --filters ${DUTY_FILTER} \
                 --query Reservations[0].Instances[*].[PublicIpAddress] \
                 --output text"
  echo ${CMD}
  BASTION=$(${CMD})
  echo "Bastion IP address is ${BASTION}"

}

function determineDockerAddresses() {
  local STATE_FILTER=Name=instance-state-name,Values=running
  local PROJECT_FILTER=Name=tag:Project,Values=${PROJECT}
  local ENVIRONMENT_FILTER=Name=tag:Environment,Values=${ENVIRONMENT}
  local DUTY_FILTER=Name=tag:Duty,Values=${PRIVATE_TAG}

  local CMD="aws ec2 describe-instances \
                 --filters ${STATE_FILTER} \
                 --filters ${PROJECT_FILTER} \
                 --filters ${ENVIRONMENT_FILTER} \
                 --filters ${DUTY_FILTER} \
                 --query Reservations[*].Instances[*].[PrivateIpAddress] \
                 --output text"

  echo ${CMD}
  local IDS=$(${CMD})
  echo ${IDS}
  WORKERS=$(echo ${IDS} | sed -e "s/ /,/g")
  echo "Docker addresses are ${WORKERS}"
}

function runContainer() {
  local CMD="docker run --net host \
                  --add-host bastion:${BASTION} \
                  --hostname inside-docker \
                  --env HOME=${HOME_DIR} \
                  --env ANSIBLE_CONFIG=/tmp/ansible.cfg \
                  --env VAULT_ADDR=${VAULT_ADDR} \
                  --env ROLE_ID=${ROLE_ID} \
                  --env SECRET_ID=${SECRET_ID} \
                  --env VAULT_PATH=${VAULT_PATH} \
                  --env WORKERS=${WORKERS} \
                  --interactive \
                  --name deployer-test \
                  --rm \
                  --tty \
                  --user=${USER_ID}:${GROUP_ID} \
                  --volume ${HOME_DIR}:${HOME_DIR} \
                  --volume ${PLAYBOOK}:${HOME_DIR}/playbook.yml \
                  --volume /etc/passwd:/etc/passwd \
                  --volume /etc/group:/etc/group \
                  --workdir ${HOME_DIR} \
                  kurron/docker-ansible:latest /tmp/deploy-docker-containers.sh"
  echo $CMD
  $CMD
}

determineBastionAddress
determineDockerAddresses
runContainer
