#!/usr/bin/env sh

docker build -t svf:latest .
docker run --rm -ti --name svf \
	-v "${PWD}/../../examples:/examples" \
	-v "${PWD}/../../files:/files" \
	svf:latest
