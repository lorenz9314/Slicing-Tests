#!/usr/bin/env sh

docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
  	-f Dockerfile -t svf:latest .
docker run -ti --name svf \
	-v "${PWD}/../../examples:/examples:Z" \
	-v "${PWD}/../../files:/files:Z" \
	svf:latest
