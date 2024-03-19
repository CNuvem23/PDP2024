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

BENCH_ARRAY=()
OTHER_BENCH_ARGS=()

USER_ID=$(id -u $USER)
DIR=$(readlink -f benchmarks/)

BENCHS=$(ls benchmarks/ | cut -f2)
BENCHS_STR=$(echo $BENCHS|sed 's/ /|/g')

TAGS=$(ls benchmarks/$BENCHS/Dockerfile.* | cut -d"." -f2)
TAGS_STR=$(echo $TAGS|sed 's/ /|/g')

usage() {
    echo ""
    echo "Usage: $0 -b=$BENCHS_STR -t=$TAGS_STR -c=build|pull|local -m=docker|dind -s=y|n -ne=1 <benchmark arguments>"
    echo "  -b <benchmark>: $BENCHS_STR"
    echo "      You can run multiple benchmarks using -b tag multiple times in one execution"
    echo "      ATTENTION! THIS CONFIG THERE IS NO DEFAULT VALUE"
    echo "  -t <tag>: $TAGS_STR"
    echo "      DEFAULT VALUE: alpine"
    echo "  -c <cmd>: "
    echo "      pull  = get image from Docker Hub: docker pull <docker_image>"
    echo "      local = just run local image: docker run -it <docker_image>"
    echo "      build = build image first: docker build -f Dockerfile.TAG"
    echo "      DEFAULT VALUE: pull"
    echo "  -m <mode>: "
    echo "      docker = docker only"
    echo "      dind   = docker in docker only"
    echo "      both   = docker AND docker in docker"
    echo "      DEFAULT VALUE: both"
    echo "  -s <stats>: "
    echo "      y = collect docker stats"
    echo "      n = do NOT collect docker stats"
    echo "      DEFAULT VALUE: y"
    echo "  -ne <n_exec>: (int) number of times to execute the benchmark"
    echo "      DEFAULT VALUE: 10"
    echo "  -ba <bench_args>: other optional benchmark-specific arguments"
    echo "      There is no default value!"
    echo "  -h <help>: show this message"
    echo ""
    exit 
}

j=""
for i in $*
do
    case $j in
    -h)
    usage
    ;;
    -b)
    # Add each argument with -b flag to the array
    BENCH_ARRAY+=("$i")
    ;;

    -t)
    DISTRO="$i"
    ;;

    -c)
    DOCKER_CMD="$i"
    ;;

    -m)
    DOCKER_MODE="$i"
    ;;

    -s)
    DOCKER_STATS="$i"
    ;;

    -ne)
    N_TIMES_EXEC="$i"
    ;;
    
    -ba)
    # Handle benchmark-specific arguments (optional)
    OTHER_BENCH_ARGS+=("$i")
    ;;
    esac
    j=$i
done

[ $DISTRO ] || { 
    DISTRO=alpine
}

[ $DOCKER_CMD ] || {
    DOCKER_CMD=pull
}

[ $DOCKER_MODE ] || {
    DOCKER_MODE=both
}

[ $DOCKER_STATS ] || {
    DOCKER_STATS=y
}

[ $N_TIMES_EXEC ] || {
    N_TIMES_EXEC=10
}


[ $BENCH_ARRAY ] || {
    echo "[WARNING] You must inform a valid benchmark name to begin!"
    echo "Valid benchmarks are: $BENCHS_STR"
    echo ""
    exit
}

[[ "$N_TIMES_EXEC" =~ ^[0-9]+$ ]] || {
    echo ""
    echo "[ERROR] parameter -ne is NOT an integer!"
    echo ""
    sleep 2
    usage
}

DOCKER_IMAGE=()

for i in $BENCH_ARRAY
do
    BENCHMARK_NAME=$i
    $DOCKER_IMAGE+=("cnuvem23/$BENCHMARK_NAME:$DISTRO")
    docker inspect $DOCKER_IMAGE &> /dev/null
    if [ $? -ne 0 ]
    then
        echo "[ERROR] could not inspect docker image $DOCKER_IMAGE"
        exit
    fi
    RAND_CHARS=$(echo $RANDOM | base64 | head -c 7; echo)
    RAND_CHARS=$(echo $RAND_CHARS | sed 's/[^a-zA-Z0-9]/X/g')
    CONTAINER_NAME=$BENCHMARK_NAME.$DISTRO.$RAND_CHARS
    CONTAINER_NAME_DIND=$CONTAINER_NAME.DIND
    
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    
    DSTATS_FILE="shared/outputs-$BENCHMARK_NAME-$DISTRO-$TIMESTAMP-docker_stats-$RAND_CHARS"
    
    echo "=========================================================="
    echo " Collecting host info"
    echo "=========================================================="
    ./scripts/linux_env_data.sh shared/outputs-$BENCHMARK_NAME-$DISTRO-$TIMESTAMP 0 none
    echo "=========================================================="
    echo "" 
    echo "=========================================================="
    echo " Executing $BENCHMARK_NAME $N_TIMES_EXEC times"
    echo "=========================================================="
    case $DOCKER_MODE in 
        docker)
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
        [ "$DOCKER_STATS" != "yes" ] || { 
            ./scripts/docker_stats_collect.sh $CONTAINER_NAME "$DSTATS_FILE" &> /dev/null &
        }
        docker run -it --name=$CONTAINER_NAME -v $DIR/$BENCHMARK_NAME/shared:/dind_bench/shared -e DISPLAY=unix$DISPLAY $DOCKER_IMAGE /bin/sh /dind_bench/shared/run-benchmark-$BENCHMARK_NAME.sh $USER_ID $DISTRO $N_TIMES_EXEC $TIMESTAMP $OTHER_BENCH_ARGS
        docker container rm $CONTAINER_NAME &> /dev/null
        ;;

        dind)
        [ "$DOCKER_STATS" != "yes" ] || { 
            ./scripts/docker_stats_collect.sh docker-dind "$DSTATS_FILE" &> /dev/null &
        }
        ./scripts/run_dind.sh -v $DIR/$BENCHMARK_NAME/shared:/dind_bench/shared docker run --name=$CONTAINER_NAME_DIND -v /dind_bench/shared:/dind_bench/shared -e DISPLAY=unix$DISPLAY $DOCKER_IMAGE /dind_bench/shared/run-benchmark-$BENCHMARK_NAME.sh $USER_ID $DISTRO $N_TIMES_EXEC $TIMESTAMP $OTHER_BENCH_ARGS
        docker container rm $CONTAINER_NAME_DIND &> /dev/null
        ;;

        both)    
        [ "$DOCKER_STATS" != "yes" ] || { 
            ./scripts/docker_stats_collect.sh $CONTAINER_NAME "$DSTATS_FILE" &> /dev/null &
            ./scripts/docker_stats_collect.sh docker-dind "$DSTATS_FILE-docker-dind" &> /dev/null &
        }
        docker run -it --name=$CONTAINER_NAME -v $DIR/$BENCHMARK_NAME/shared:/dind_bench/shared -e DISPLAY=unix$DISPLAY $DOCKER_IMAGE /bin/sh /dind_bench/shared/run-benchmark-$BENCHMARK_NAME.sh $USER_ID $DISTRO $N_TIMES_EXEC $TIMESTAMP $OTHER_BENCH_ARGS
        ./scripts/run_dind.sh -v $DIR/$BENCHMARK_NAME/shared:/dind_bench/shared docker run --name=$CONTAINER_NAME_DIND -v /dind_bench/shared:/dind_bench/shared -e DISPLAY=unix$DISPLAY $DOCKER_IMAGE /dind_bench/shared/run-benchmark-$BENCHMARK_NAME.sh $USER_ID $DISTRO $N_TIMES_EXEC $TIMESTAMP $OTHER_BENCH_ARGS
        docker container rm $CONTAINER_NAME &> /dev/null
        docker container rm $CONTAINER_NAME_DIND &> /dev/null
        ;;
        *)
        echo "[ERROR] invalid mode option $DOCKER_MODE!"
        usage
        ;;
    esac
done
echo "" 

sudo chown -R $USER shared

echo "=========================================================="
echo " Execution finished"
echo "=========================================================="
# echo "=========================================================="
# echo " ls shared/"
# echo "=========================================================="
# ls shared/
# echo "=========================================================="
