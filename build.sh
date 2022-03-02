#!/usr/bin/bash

for dir in */; do
	cd $dir && make all && cd ..
done
