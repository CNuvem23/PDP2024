#!/bin/sh

# $1  = USER
# $2  = DISTRO (debian|alpine)
# $3  = N TIMES TO EXEC
# $4  = TIMESTAMP 
# $5* = OTHER benchmark-specific parameters

TIMESTAMP=$4

N_TIMES_EXEC=$3

for N in $(seq 1 $N_TIMES_EXEC)
do

echo -n "Running exec $N ... " 

OUT_FILE="/cnuvem23/shared/outputs-stress-$2-$TIMESTAMP-exec$N.txt"

print_line(){
    echo "================================================================" >> $OUT_FILE
}

echo "" > $OUT_FILE
print_line
echo "CPU: stress --cpu 1 --timeout 100s" >> $OUT_FILE
print_line
$EXEC_CMD stress --cpu 1 --timeout 100s >> $OUT_FILE 

print_line
echo "HDD: stress --hdd 1 --timeout 100s" >> $OUT_FILE
print_line
$EXEC_CMD stress --hdd 1 --timeout 100s --verbose >> $OUT_FILE 

print_line
echo "CPU: stress --io 1 --timeout 100s" >> $OUT_FILE
print_line
$EXEC_CMD stress --io 1 --timeout 100s >> $OUT_FILE

print_line
echo "CPU: stress --vm 1 --timeout 100s" >> $OUT_FILE
print_line
$EXEC_CMD stress --vm 1 --timeout 100s >> $OUT_FILE

print_line
echo "CPU: stress --cpu 1 --io 1 --vm 1 --hdd 1 --timeout 100s" >> $OUT_FILE
print_line
$EXEC_CMD stress --cpu 1 --io 1 --vm 1 --hdd 1 --timeout 100s  >> $OUT_FILE

echo "done."

done

chown -R $1 /cnuvem23/shared
