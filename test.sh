#!/bin/bash

# Environment variables required by the AWS CLI
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-west-2}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-CHANGEME}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-CHANGEME}

function runContainer() {
  local USER_ID=$(id -u $(whoami))
  local GROUP_ID=$(id -g $(whoami))
  local WORK_AREA=/work-area
  local HOME_DIR=$(cut -d: -f6 < <(getent passwd ${USER_ID}))

  local CMD="docker run --net host \
                  --hostname inside-docker \
                  --env HOME=${HOME_DIR} \
                  --env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
                  --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
                  --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
                  --interactive \
                  --name ec2-docker-pipeline \
                  --rm \
                  --tty \
                  --user=${USER_ID}:${GROUP_ID} \
                  --volume $(pwd):$(pwd) \
                  --volume ${HOME_DIR}:${HOME_DIR} \
                  --volume /etc/passwd:/etc/passwd \
                  --volume /etc/group:/etc/group \
                  --workdir $(pwd) \
                  dockerec2tagsearch_deployer:latest bash"
  echo $CMD
  $CMD
}

runContainer
