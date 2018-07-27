FROM jenkins/jenkins:latest
USER root
RUN apt-get update && apt-get -y install mercurial build-essential git python-pip subversion
RUN pip install -U py65
RUN svn checkout https://svn.code.sf.net/p/acme-crossass/code-0/trunk acme \
	&& cd acme/src \ 
	&& make \
	&& make install
RUN git clone https://github.com/cc65/cc65.git \
	&& cd cc65 \
	&& make \
	&& PREFIX=/usr/local make install


