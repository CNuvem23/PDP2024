#!/bin/sh

# $1  = USER
# $2  = DISTRO (debian|alpine)
# $3  = N TIMES TO EXEC
# $4  = TIMESTAMP
# $5* = OTHER benchmark-specific parameters

TIMESTAMP=$4

N_TIMES_EXEC=$3

OUT_FILE_NAME="/cnuvem23/shared/outputs-sysbench-$2-$TIMESTAMP"

for i in $(seq 1 $N_TIMES_EXEC)
do
	OUT="$OUT_FILE_NAME-exec$i"
	sysbench fileio prepare --file-total-size=1G
	sysbench fileio run --file-total-size=1G --file-test-mode=rndrw --time=10 --threads=4 > $OUT
done
