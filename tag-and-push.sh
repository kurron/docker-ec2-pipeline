#!/bin/bash

# use the time as a tag
UNIXTIME=$(date +%s)

# docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
docker tag dockerec2tagsearch_ec2-docker-pipeline:latest kurron/docker-ec2-pipeline:latest
docker tag dockerec2tagsearch_ec2-docker-pipeline:latest kurron/docker-ec2-pipeline:${UNIXTIME}
docker images

# Usage:  docker push [OPTIONS] NAME[:TAG]
docker push kurron/docker-ec2-pipeline:latest
docker push kurron/docker-ec2-pipeline:${UNIXTIME}
