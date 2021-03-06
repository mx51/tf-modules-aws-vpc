#!/bin/sh

WORKING_DIR=$(pwd)
for d in $(find . -type f -name '*.tf*' | sed -r 's|/[^/]+$||' |sort |uniq); do
    echo $d
    cd $d
    terraform 0.13upgrade -yes 
    cd $WORKING_DIR
done
