FROM --platform=linux/amd64 ubuntu:bionic-20220315

RUN apt-get update -qq && \
    apt-get install -y -qq build-essential && \
    apt-get clean

VOLUME ["/workspace"]

WORKDIR /workspace
