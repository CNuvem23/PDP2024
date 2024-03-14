#!/bin/bash

# dependencies:
# - scripts/docker_dind.sh
# - scripts/run_dind.sh
# - scripts/linux_env_data.sh

DEPENDENCIES="scripts/docker_dind.sh scripts/run_dind.sh scripts/linux_env_data.sh"
for FILE in $DEPENDENCIES
do
    [ -f $FILE ] || {
    echo "[ERROR] missing dependency $FILE!"
    }
done

TAGS=$(ls benchmarks/$1/Dockerfile.* | cut -d"." -f2)
TAGS_STR=$(echo $TAGS|sed 's/ /|/g')

DISTRO=$2
[ $DISTRO ] || { 
    DISTRO=tag
}
# BENCHMARK_NAME=$(pwd | sed 's/^.*\///' | tr '[:upper:]' '[:lower:]') 
BENCHMARK_NAME=$1
DOCKER_IMAGE=cnuvem23/$BENCHMARK_NAME:$DISTRO

usage() {
    echo ""
    echo "Usage: $0 <benchmark:iozone|iperf|stress|sysbench> <tag:$TAGS_STR> <cmd:build|pull|local> <mode:docker|dind> <docker_stats:yes|no> <n_times_exec> <other_benchmark_args>"
    echo "  benchmark: "
    echo "    iozone   = make tests with iozone, focus on disk benchmark"
    echo "    iperf    = make tests with iperf, focus on network benchmark"
    echo "    stress   = make tests with stress, focus on CPU, RAM and disk benchmarks"
    echo "    sysbench = make tests with sysbench, focus on CPU, RAM, threads, disk and database benchmarks"
    echo "  tag: $TAGS_STR"
    echo "  cmd: "
    echo "    build = build image first: docker build -f Dockerfile.TAG"
    echo "    pull  = get image from Docker Hub: docker pull $DOCKER_IMAGE"
    echo "    local = just run local image: docker run -it $DOCKER_IMAGE"
    echo "  mode: "
    echo "    docker = docker only"
    echo "    dind   = docker in docker"
    echo "  docker_stats: "
    echo "    yes = collect docker stats"
    echo "    no  = do NOT collect docker stats"
    echo "  n_times_exec: (int) number of times to execute the benchmark"
    echo "  other_benchmark_args: other optional benchmark-specific arguments"
    echo ""
    exit 
}

[ $1 ] && [ $2 ] && [ $3 ] && [ $4 ] && [ $5 ] && [ $6 ] || { 
    usage
}

# BENCHMARKS="iozone iperf stress sysbench"
# VALID_BENCH=0
# for BENCH in BENCHMARKS
# do
#     if [ $BENCH = $1 ] 
#     then $VALID_BENCH=1 
#     fi
# done

# if [ $VALID_BENCH -eq 0 ] 
# then usage
# fi

DOCKER_CMD=$3
DOCKER_MODE=$4
DOCKER_STATS=$5
N_TIMES_EXEC=$6
# shift input args
for i in 1 2 3 4 5 6
do
    shift
done
OTHER_BENCH_ARGS="$*"

[[ "$N_TIMES_EXEC" =~ ^[0-9]+$ ]] || {
    echo ""
    echo "[ERROR] parameter 6 is NOT an integer!"
    echo ""
    sleep 2
    usage
}

case $DOCKER_CMD in 
    build)
    docker build -t $DOCKER_IMAGE -f ./benchmarks/$BENCHMARK_NAME/Dockerfile.$DISTRO .
    ;;
    pull)
    docker pull $DOCKER_IMAGE
    ;;
    local)
    ;;
    *)
    echo "[ERROR] invalid cmd option $DOCKER_CMD!"
    usage
    ;;
esac

USER_ID=$(id -u $USER)
DIR=$(readlink -f shared)
docker inspect $DOCKER_IMAGE &> /dev/null
if [ $? -ne 0 ]
then
    echo "[ERROR] could not inspect docker image $DOCKER_IMAGE"
    exit
fi

RAND_CHARS=$(echo $RANDOM | base64 | head -c 7; echo)
RAND_CHARS=$(echo $RAND_CHARS | sed 's/[^a-zA-Z0-9]/X/g')
CONTAINER_NAME=$BENCHMARK_NAME.$DISTRO.$RAND_CHARS

TIMESTAMP=$(date +%Y%m%d%H%M%S)

DSTATS_FILE="shared/outputs-$BENCHMARK_NAME-$DISTRO-$TIMESTAMP-docker_stats"

echo "=========================================================="
echo " Collecting host info"
echo "=========================================================="
./scripts/linux_env_data.sh shared/outputs-$BENCHMARK_NAME-$DISTRO-$TIMESTAMP 0 none
echo "=========================================================="
echo "" 
echo "=========================================================="
echo " Executing benchmark $BENCHMARK_NAME $N_TIMES_EXEC times"
echo "=========================================================="
case $DOCKER_MODE in 
    docker)
    [ "$DOCKER_STATS" != "yes" ] || { 
        ./scripts/docker_stats_collect.sh $CONTAINER_NAME "$DSTATS_FILE" &> /dev/null &
    }
    docker run -it --name=$CONTAINER_NAME -v $DIR:/cnuvem23/shared -e DISPLAY=unix$DISPLAY $DOCKER_IMAGE /bin/sh /cnuvem23/shared/run-benchmark-$BENCHMARK_NAME.sh $USER_ID $DISTRO $N_TIMES_EXEC $TIMESTAMP $OTHER_BENCH_ARGS
    docker container rm $CONTAINER_NAME &> /dev/null
    ;;
    dind)
    [ "$DOCKER_STATS" != "yes" ] || { 
        ./scripts/docker_stats_collect.sh docker-dind "$DSTATS_FILE" &> /dev/null &
    }
    ./scripts/run_dind.sh -v $DIR:/cnuvem23/shared docker run --name=$CONTAINER_NAME -v /cnuvem23/shared:/cnuvem23/shared -e DISPLAY=unix$DISPLAY $DOCKER_IMAGE /cnuvem23/shared/run-benchmark-$BENCHMARK_NAME.sh $USER_ID $DISTRO $N_TIMES_EXEC $TIMESTAMP $OTHER_BENCH_ARGS
    docker container rm $CONTAINER_NAME &> /dev/null
    ;;
    *)
    echo "[ERROR] invalid mode option $DOCKER_MODE!"
    usage
    ;;
esac
echo "" 

sudo chown -R $USER shared

echo "=========================================================="
echo " ls shared/"
echo "=========================================================="
ls shared/
echo "=========================================================="
