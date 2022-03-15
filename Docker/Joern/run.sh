#!/usr/bin/env sh

docker build -t joern:latest .
docker run --rm -ti --name joern \
	-v "${PWD}/../../examples:/joern/examples" \
	-v "${PWD}/../../files:/joern/files" \
	joern:latest
