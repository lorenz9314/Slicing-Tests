FROM ubuntu:20.04

# dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -y update && apt-get -y install \
	openjdk-11-jre python3 git curl gnupg bash \
	libnss3 ncurses-dev \
	&& ln -sf python3 /usr/bin/python

# sbt
ENV SBT_VERSION 1.3.13
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin
RUN curl -sL "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" \
	| gunzip | tar -x -C /usr/local

# building joern
RUN git clone https://github.com/ShiftLeftSecurity/joern.git \
	&& cd joern && sbt stage

WORKDIR /joern
