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
Use `./test.sh` to exercise the image.

# Troubleshooting

# Contributing

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).

# List of Changes
