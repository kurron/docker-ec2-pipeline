#!/bin/bash

# Environment variables required by the AWS CLI
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-west-2}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-CHANGEME}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-CHANGEME}

# Environment variables needed to contact Hashicorp's Vault
VAULT_ADDR=${VAULT_ADDR:-http://192.168.254.90:8200}
ROLE_ID=${ROLE_ID:-CHANGEME}
SECRET_ID=${SECRET_ID:-CHANGEME}
VAULT_PATH=${VAULT_PATH:-CHANGEME}

# We need to be part of the docker group to interact with the Docker daemon
DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))

# Environment variable describing the location of the playbook to run
PLAYBOOK=${PLAYBOOK:-$(pwd)/ansible/playbook.yml}

function runContainer() {
  local USER_ID=$(id -u $(whoami))
  local GROUP_ID=$(id -g $(whoami))
  local WORK_AREA=/work-area
  local HOME_DIR=$(cut -d: -f6 < <(getent passwd ${USER_ID}))

  local CMD="docker run --net host \
                  --group-add ${DOCKER_GROUP_ID} \
                  --hostname inside-docker \
                  --env HOME=${HOME_DIR} \
                  --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
                  --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                  --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                  --env VAULT_ADDR=${VAULT_ADDR} \
                  --env ROLE_ID=${ROLE_ID} \
                  --env SECRET_ID=${SECRET_ID} \
                  --env VAULT_PATH=${VAULT_PATH} \
                  --env PLAYBOOK=${PLAYBOOK} \
                  --interactive \
                  --name ec2-docker-pipeline \
                  --rm \
                  --tty \
                  --user=${USER_ID}:${GROUP_ID} \
                  --volume $(pwd):$(pwd) \
                  --volume ${HOME_DIR}:${HOME_DIR} \
                  --volume /etc/passwd:/etc/passwd \
                  --volume /etc/group:/etc/group \
                  --volume /var/run/docker.sock:/var/run/docker.sock \
                  --workdir $(pwd) \
                  dockerec2tagsearch_ec2-docker-pipeline:latest /tmp/initiate-deployment-pipeline.sh"
  echo $CMD
  $CMD
}

runContainer
