FROM ubuntu:16.04

USER root
RUN apt-get update && apt-get install -y --force-yes \
    python-pip python-dev \
    openjdk-8-jre-headless \
    curl \
    unzip

RUN cd /opt && curl -LO https://github.com/broadinstitute/gatk/releases/download/4.1.2.0/gatk-4.1.2.0.zip \
    && unzip gatk-4.1.2.0.zip && rm /opt/gatk-4.1.2.0.zip

ADD gatk4_multithread_mutect2.py /opt/
