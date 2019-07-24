FROM ubuntu:16.04

USER root
RUN apt-get update && apt-get install -y --force-yes \
    python-pip python-dev

RUN pip install pysam

ADD modify_vcf_sample.py /opt/
