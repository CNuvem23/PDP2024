#!/bin/bash

# DinD base
source ./scripts/docker_dind.sh
dind_parse_arguments "$@"
shift $DIND_PROCESSED_ARGS_COUNT
dind_start
# DinD base

echo "Running $@ (Docker in Docker)"
dind_dispatch $@ | tee -a $DIND_OUTPUT_DIRECTORY/outputs-dind-$DIND_TIMESTAMP.txt

dind_stop
