#!/bin/bash

DIND_USER_ID=$(id -u $USER)
DIND_TIMESTAMP=$(date +%Y%m%d%H%M%S)
DIND_IMAGE="docker:dind"
DIND_VOLUMES=()

dind_usage() {
  echo "Usage: $0 [OPTIONS] [ARGUMENTS]"
  echo "Runs docker container inside a container running docker (Docker in Docker - DinD)."
  echo ""
  echo "Options:"
  echo "  -v, --volume    Map volumes to the Docker-in-Docker container"
  echo "  -h, --help      Show this help message"
  echo ""
  echo "Arguments:"
  echo "  command       The command to run in the Docker container"
  echo ""
  exit 1
}

dind_getOutputDir() {
  DIND_OUTPUT_DIRECTORY="./shared"
  mkdir -p "$DIND_OUTPUT_DIRECTORY"
  echo $DIND_OUTPUT_DIRECTORY
}

dind_dispatch() {
  local DIND_ARGS="$@"
  docker exec docker-dind sh -c "$DIND_ARGS"
}

DIND_CID=0
dind_start() {
  echo "Starting Docker in Docker..."
  docker stop docker-dind > /dev/null 2>&1
  docker rm -f -v docker-dind > /dev/null 2>&1
  DIND_CID=$(eval "docker run --rm -d --privileged -v $PWD/.runtime/docker-dind-files:/var/lib/docker --name docker-dind ${DIND_VOLUMES[@]} $DIND_IMAGE")
  if [ $? -ne 0 ]; then
    echo "Error: failed to start Docker in Docker"
    exit 1
  fi
  echo "Docker in Docker (DinD) started with container ID ${DIND_CID}."
  sleep 5
}

dind_stop() {
  echo "Stopping Docker in Docker..."
  docker stop docker-dind > /dev/null 2>&1
  docker rm -f -v docker-dind > /dev/null 2>&1
  echo "Docker in Docker (DinD) completed."
  exit 1
}

dind_logs() {
  local DIND_CONTAINER_LIST=$(dind_dispatch docker ps -q)
  for DIND_CONTAINER_ID in $DIND_CONTAINER_LIST
  do
    dind_dispatch docker logs $DIND_CONTAINER_ID
  done
}

DIND_PROCESSED_ARGS_COUNT=0
dind_parse_arguments() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -v|--volume)
        if [ -n "$2" ]; then
          DIND_VOLUMES+=("-v $2")
          DIND_PROCESSED_ARGS_COUNT=$((DIND_PROCESSED_ARGS_COUNT + 2))
          shift 2
        else
          echo "Error: Missing volume mapping after $1 option."
          exit 1
        fi
        ;;
      -?*|--?*)
        echo "Error: Unrecognized option: $1"
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  dind_usage
fi

if ! [ -x "$(command -v docker)" ]; then
  echo "Error: docker is not installed."
  exit 1
fi

docker pull $DIND_IMAGE
if [ $? -ne 0 ]; then
  echo "Error: failed to pull image $DIND_IMAGE"
  exit 1
fi

DIND_OUTPUT_DIRECTORY=$(dind_getOutputDir)

trap dind_stop SIGINT

if [ $? -ne 0 ]; then
  echo "Error: failed to start Docker in Docker"
  exit 1
fi
