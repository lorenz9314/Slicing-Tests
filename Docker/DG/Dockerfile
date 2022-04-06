# --------------------------------------------------
# Base container
# --------------------------------------------------
FROM ubuntu:20.04 AS base

RUN set -e

# Install packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -yq --no-install-recommends clang llvm

# --------------------------------------------------
# Build container
# --------------------------------------------------
FROM base as build

# Can be used to specify which git ref to checkout
ARG GIT_REF=master
ARG GIT_REPO=mchalupa/dg

# Install build dependencies
RUN apt-get update && apt-get install -yq \
	--no-install-recommends ca-certificates cmake git \
	ninja-build llvm-dev python3 vim make

# Clone
RUN git clone https://github.com/$GIT_REPO
WORKDIR /dg
RUN git fetch origin $GIT_REF:build
RUN git checkout build

# libfuzzer does not like the container environment
RUN cmake -S. -GNinja -Bbuild -DCMAKE_INSTALL_PREFIX=/opt/dg \
          -DCMAKE_CXX_COMPILER=clang++ -DENABLE_FUZZING=OFF
RUN cmake --build build

# Install
RUN cmake --build build --target install

# -------------------------------------------------
# Release container
# -------------------------------------------------
FROM base AS release

RUN apt-get -y update && apt-get -y install make vim clang llvm

COPY --from=build /opt/dg /opt/dg
COPY --from=build /dg /dg
ENV PATH="/opt/dg/bin:$PATH"
ENV PATH="/dg/build/tools:$PATH"
ENV LD_LIBRARY_PATH="/opt/dg/lib"

# Verify it works
RUN llvm-slicer --version

