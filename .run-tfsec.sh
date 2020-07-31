#!/bin/sh

for d in $(find . -type d  -not -path '*/\.*' -not -path './example'| sed -e 's,^\./,,' | sort); do
    # Scans the module for problems
    tfsec --no-colour $OPTS $d
done
