# Overview
This project is a Docker container that is the first step in a pipeline of
Docker containers that deploy Docker containers into EC2 instances.  The idea
is to have everything run from within Docker, freeing CI/CD servers from having
any required dependencies installed.

# Guidebook
Details about this project are contained in the [guidebook](guidebook/guidebook.md)
and should be considered mandatory reading prior to contributing to this project.

# Prerequisites
* a working [Docker](http://docker.io) engine
* a working [Docker Compose](http://docker.io) installation

# Building
Type `./build.sh` to build the image.

# Installation
Docker will automatically install the newly built image into the cache.

# Tips and Tricks

## Launching The Image
Use `./test.sh` to exercise the image.  The container require several environment
variables to be set, requiring a little configuration before hand.  Here is
a list of the variables and example values:

* AWS_DEFAULT_REGION - us-west-2
* AWS_ACCESS_KEY_ID - AAAAAAAAAAAAAAAAAAAA
* AWS_SECRET_ACCESS_KEY - AAAAAA/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
* VAULT_ADDR - http://192.168.1.1:8200
* ROLE_ID - ab30c420-3f48-60e3-b45e-07a672aa4860
* SECRET_ID - 0fb79713-0c1b-edd2-6d60-b6714da074d2
* VAULT_PATH - secret/build/ssh/myproject
* PLAYBOOK - /home/vagrant/GitHub/docker-ec2-pipeline/ansible/playbook.yml

# Troubleshooting

# Contributing

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).

# List of Changes
