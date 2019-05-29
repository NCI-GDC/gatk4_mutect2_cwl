FROM ubuntu:16.04

USER root
RUN apt-get update && apt-get install -y --force-yes \
    python-pip python-dev \
    openjdk-8-jre-headless \
    curl \
    unzip

RUN cd /bin && curl -LO https://github.com/broadinstitute/gatk/releases/download/4.0.4.0/gatk-4.0.4.0.zip \
    && unzip gatk-4.0.4.0.zip && rm /bin/gatk-4.0.4.0.zip

ADD multi_mutect2_tumor_only.py /bin/

ENV multi_mutect2_tumor_only v1.0
