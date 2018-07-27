FROM jenkins/jenkins:latest
USER root
RUN apt-get update && apt-get -y install mercurial build-essential git python-pip
RUN pip install -U py65
RUN git clone https://github.com/cc65/cc65.git \
	&& cd cc65 \
	&& make \
	&& PREFIX=/usr/local make install

