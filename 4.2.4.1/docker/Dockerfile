FROM quay.io/ncigdc/gatk:4.2.4.1

USER root
RUN apt-get update && apt-get install -y --force-yes \
    python3-pip python3-dev

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

ADD gatk4_multithread_mutect2.py /opt/

ENTRYPOINT ["/bin/bash"]