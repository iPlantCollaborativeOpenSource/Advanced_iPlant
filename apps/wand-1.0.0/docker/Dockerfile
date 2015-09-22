FROM centos:6
MAINTAINER vaughn@iplantcollaborative.org

RUN sudo apt-get update && \
    sudo apt-get -y install git curl python-dev \
    r-base-core r-cran-gplots && \
    apt-get clean

WORKDIR /home
