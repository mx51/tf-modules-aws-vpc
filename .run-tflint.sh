#!/bin/sh

set -e

for d in $(find . -type d -not -path '*/\.*' | sort); do
    # Scans the module for problems
    echo "checking $d..."
    tflint $d --loglevel=error
done
