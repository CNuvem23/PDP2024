#!/bin/bash

[ $1 ] && [ $2 ] || { echo "Usage: $0 <container-name> <out-file-name>"; exit; }

print_begin_end() {
    echo "#========================================================="
    echo "#docker stats: $1" 
    echo "#========================================================="
}

STOP=$(date +%s)
STOP=$((STOP+240)) # wait 120s until killing itself
# wait until container is running
while [ 1 ]
do
    if [ "$( docker container inspect -f '{{.State.Running}}' $1 2> /dev/null)" = "true" ]
    then
        break
    fi
    sleep 1
    NOW=$(date +%s)
    [ $NOW -le $STOP ] || { exit; }
done

print_begin_end BEGIN > "$2"
echo "#TS-BEGIN (YYYYMMDDHHMMSS): "$(date +%Y%m%d%H%M%S) >> "$2"
echo "#TS-BEGIN (in seconds): "$(date +%s) >> "$2"
while [ 1 ]
do
    docker stats --no-stream --format "table {{.Name}};{{.CPUPerc}};{{.MemUsage}};{{.MemPerc}};{{.NetIO}};{{.BlockIO}};{{.PIDs}}" $1 >> "$2" 2> /dev/null
    [ $? -eq 0 ] || { break; }
done
echo "#TS-END (YYYYMMDDHHMMSS): "$(date +%Y%m%d%H%M%S) >> "$2"
echo "#TS-END (in seconds): "$(date +%s) >> "$2"
print_begin_end END >> "$2"

./scripts/docker_stats_parse.sh "$2"
