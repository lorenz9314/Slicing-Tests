#!/usr/bin/env sh

docker build -t dg:latest .
docker run --rm -ti --name dg \
	-v "${PWD}/../../examples:/examples" \
	-v "${PWD}/../../files:/files" \
	dg:latest
