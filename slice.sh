#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "No arguments supplied"
fi


bcfile=$1
crit=$2

# Delete old lines file if exists
if [ -f ${bcfile}.lines ]; then
    rm ${bcfile}.lines
fi

# Execute slicer
llvm-slicer -c $2 ${bcfile}.bc

# Iterate over sliced lines and create regex
for x in $(llvm-to-source ${bcfile}.sliced); do
    echo "^ *$x.*$" >> ${bcfile}.lines
done

# Match source file against regex patterns
nl -ba -nln ${bcfile}.c | grep --color=always -e "^" -f ${bcfile}.lines

# Delete temporary regex file
rm ${bcfile}.lines
