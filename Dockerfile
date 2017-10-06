FROM ubuntu:16.04

MAINTAINER Ron Kurr <kurr@kurron.org>

ENV DOCKER_VERSION=17.03.2-ce
ENV COMPOSE_VERSION=1.16.1

# spit out the CLI version
CMD ["aws", "--version", "&&", "docker", "--version"]

# ---- watch your layers and put likely mutating operations here -----

# Intall AWS CLI
RUN apt-get update --yes && \
    apt-get install --yes curl python-pip && \
    apt-get purge --yes && \
    pip install awscli

# Install Docker client so we can launch the next step in the pipeline
RUN curl --fail --silent --show-error --location --remote-name https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar --strip-components=1 -xvzf docker-${DOCKER_VERSION}.tgz -C /usr/local/bin && \
    rm -f docker-${DOCKER_VERSION}.tgz && \
    chmod 0555 /usr/local/bin/docker
