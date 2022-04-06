FROM ubuntu:20.04

ARG UNAME=docker
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

# Stop ubuntu-20 interactive options.
ENV DEBIAN_FRONTEND noninteractive

# Stop script if any individual command fails.
RUN set -e

# Define LLVM version.
ENV llvm_version=13.0.0

# Define home directory
ENV HOME=/home/SVF-tools

# Define dependencies.
ENV lib_deps="make g++-8 gcc-8 git zlib1g-dev libncurses5-dev build-essential libssl-dev libpcre2-dev zip vim"
ENV build_deps="wget xz-utils cmake python git gdb tcl"

# Fetch dependencies.
RUN apt-get update --fix-missing
RUN apt-get install -y $build_deps $lib_deps

# Fetch and build SVF source.
RUN echo "Downloading LLVM and building SVF to " ${HOME}
WORKDIR ${HOME}
RUN git clone "https://github.com/SVF-tools/SVF.git"
WORKDIR ${HOME}/SVF
RUN echo "Building SVF ..."
RUN bash ./build.sh 

# Export SVF, llvm, z3 paths
ENV PATH=${HOME}/SVF/Release-build/bin:$PATH
ENV PATH=${HOME}/SVF/llvm-$llvm_version.obj/bin:$PATH
ENV SVF_DIR=${HOME}/SVF
ENV LLVM_DIR=${HOME}/SVF/llvm-$llvm_version.obj
ENV Z3_DIR=${HOME}/SVF/z3.obj

RUN apt-get -yq update && apt-get install -yq \
	python3-pip sudo libtinfo5 && \
	pip3 install psrecord

RUN echo $UNAME:$UNAME | chpasswd chpasswd && adduser docker sudo
USER $UNAME

WORKDIR /
