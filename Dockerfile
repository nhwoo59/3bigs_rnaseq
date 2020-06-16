FROM centos:centos7

MAINTAINER woo "nhwoo@3bigs.com"

RUN echo "Welcome to thedam!" > tmp/hello

RUN yum install -y git

RUN git clone https://github.com/nhwoo59/thedam.git

RUN yum install epel-release

RUN yum install R

COPY example-input.count /root/ 

COPY example-input_2 /root/ 

RUN mkdir -p /thedam/data/

WORKDIR ./thedam

EXPOSE 80

# Install required R libraries
RUN Rscript librarySetup.R
