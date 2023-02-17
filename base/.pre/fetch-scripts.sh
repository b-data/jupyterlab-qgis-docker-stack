#!/bin/bash

set -e

files="start-notebook.sh start-singleuser.sh"

for i in $files ; do
  curl -sL https://raw.githubusercontent.com/jupyter/docker-stacks/main/base-notebook/$i \
    -o scripts/usr/local/bin/$i
done

curl -sL https://raw.githubusercontent.com/jupyter/docker-stacks/main/docker-stacks-foundation/start.sh \
  -o scripts/usr/local/bin/start.sh

chmod +x scripts/usr/local/bin/*.sh
