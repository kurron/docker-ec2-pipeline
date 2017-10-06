FROM ubuntu:16.04

MAINTAINER Ron Kurr <kurr@kurron.org>

# spit out the CLI version
CMD ["aws", "--version"]

# ---- watch your layers and put likely mutating operations here -----

RUN apt-get update --yes && \
    apt-get install --yes python-pip && \
    apt-get purge --yes && \
    pip install awscli
