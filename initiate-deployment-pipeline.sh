#!/bin/bash

# Environment variables required by the AWS CLI
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-west-2}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-CHANGEME}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-CHANGEME}

# Environment variables required to identify the correct EC2 instances
PROJECT=${PROJECT:-Weapon-X}
ENVIRONMENT=${ENVIRONMENT:-development}
BASTION_TAG=${BASTION_TAG:-Bastion}
PRIVATE_TAG=${PRIVATE_TAG:-Docker}

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
  local SSH_GROUP_ID=$(cut -d: -f3 < <(getent group ssh))
  local USER_ID=$(id -u $(whoami))
  local GROUP_ID=$(id -g $(whoami))
  local WORK_AREA=/work-area
  local HOME_DIR=$(cut -d: -f6 < <(getent passwd ${USER_ID}))

  ANSIBLE="ansible-playbook --user ec2-user \
                            --inventory ${WORKERS} \
                            --verbose \
                            playbook.yml"

  echo ${ANSIBLE}

  local CMD="docker run --net host \
                  --add-host bastion:${BASTION} \
                  --hostname inside-docker \
                  --env HOME=${HOME_DIR} \
                  --env SSH_AUTH_SOCK=${SSH_AUTH_SOCK} \
                  --interactive \
                  --name deployer-test \
                  --rm \
                  --tty \
                  --user=${USER_ID}:${GROUP_ID} \
                  --volume ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} \
                  --volume $(pwd):$(pwd) \
                  --volume ${HOME_DIR}:${HOME_DIR} \
                  --volume /etc/passwd:/etc/passwd \
                  --volume /etc/group:/etc/group \
                  --workdir $(pwd) \
                  dockeransible2bastionaccess_deployer:latest ${ANSIBLE}"
  echo $CMD
  $CMD
}

determineBastionAddress ${REGION} ${PROJECT} ${ENVIRONMENT} Bastion
determineDockerAddresses ${REGION} ${PROJECT} ${ENVIRONMENT} Docker
#runContainer
