#!/bin/sh

[ $0 ] && [ $1 ] || { echo "Usage: $0 <read_interval(e.g., 0.1)> <prog> <arg1> ... <arg3>"; exit; }

LOG_FILE="log_"
LOG_FILE=$LOG_FILE$(basename $0 .sh)
READ_INTERVAL=$1
shift
LOG_FILE=$LOG_FILE".log."$(echo $1 | sed 's/ //g;s/^.*\///;s/\./_/g')"."$(date +%Y%m%d%H%M%S)
echo $* > $LOG_FILE.input
$* &>/dev/null &
PID="$!"
trap "kill $PID" SIGINT
FORMAT='%cpu,%mem,vsz,rss'
printf 'ps_read_i,%s\n' "$FORMAT" | sed 's/,/ /g' | tee -a "$LOG_FILE"
i=1
while PSREAD="$(ps --no-headers -o "$FORMAT" -p "$PID")"
do
  printf "$i $PSREAD\n"
  i=$((i + 1))
  eval `sleep "${T:-$READ_INTERVAL}"`
done | tee -a "$LOG_FILE"

N_READS=$(grep -v ^ps $LOG_FILE | tail -n 1 | awk '{print $1}')
MEM_MAX=$(grep -v ^ps $LOG_FILE | awk '{print $3}' | sort -n | tail -n 1)
MEM_VSZ=$(grep -v ^ps $LOG_FILE | awk '{print $4}' | sort -n | tail -n 1)
MEM_RSS=$(grep -v ^ps $LOG_FILE | awk '{print $5}' | sort -n | tail -n 1)
CPU_MAX=$(grep -v ^ps $LOG_FILE | awk '{print $2}' | cut -d"." -f1 | sort -n | tail -n 1)
CPU_AVG=$(grep -v ^ps $LOG_FILE | awk '{print $2}')
CPU_AVG=$(echo $CPU_AVG | sed 's/ /+/g')
CPU_AVG=$(echo "scale=2; ($CPU_AVG)/$N_READS" | bc | sed 's/\..*$//')
MEM_TOTAL=$(grep MemTotal /proc/meminfo | head -n 1 | awk '{print $2}')
MEM_USE=$(echo "scale=2; $MEM_TOTAL*$MEM_MAX" | bc | sed 's/\.[0-9]*$//')
EXEC_TI=$(echo "scale=2; $N_READS*$READ_INTERVAL" | bc)
PADDING="            "
printf "READS_N: $N_READS ${PADDING:${#N_READS}} # number of stats reads\n" | tee -a "$LOG_FILE.stats"
printf "READS_I: $READ_INTERVAL ${PADDING:${#READ_INTERVAL}} # interval between reads (in seconds)\n" | tee -a "$LOG_FILE.stats"
printf "EXEC_TI: $EXEC_TI ${PADDING:${#EXEC_TI}} # total execution time (in seconds)\n" | tee -a "$LOG_FILE.stats"
printf "CPU_AVG: $CPU_AVG ${PADDING:${#CPU_AVG}} # average CPU consumption (percentage)\n" | tee -a "$LOG_FILE.stats"
printf "CPU_MAX: $CPU_MAX ${PADDING:${#CPU_MAX}} # maximum CPU consumption (percentage)\n" | tee -a "$LOG_FILE.stats"
printf "MEM_PER: $MEM_MAX ${PADDING:${#MEM_MAX}} # maximum memory consumption (percentage)\n" | tee -a "$LOG_FILE.stats"
printf "MEM_USE: $MEM_USE ${PADDING:${#MEM_USE}} # maximum memory consumption (in bytes)\n" | tee -a "$LOG_FILE.stats"
printf "MEM_VSZ: $MEM_VSZ ${PADDING:${#MEM_VSZ}} # maximum VSZ memory consumption (in bytes)\n" | tee -a "$LOG_FILE.stats"
printf "MEM_RSS: $MEM_RSS ${PADDING:${#MEM_RSS}} # maximum RSS memory consumption (in bytes)\n" | tee -a "$LOG_FILE.stats"
