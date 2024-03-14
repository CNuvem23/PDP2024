#!/bin/sh

OUTPUT_DIRECTORY="./shared"
mkdir -p "$OUTPUT_DIRECTORY"

help() {
  echo "Usage: $0 <uid> <distro> <n_times> <timestamp> <mode:server|client|both> [additional_parameters]"
  echo "  --outlier-multiplier <multiplier>  Remove outliers from the results from the standard deviation * multipler. Set to 0 to not remove outliers. Default is 2."
  exit 1
}

if [ $# -lt 2 ]; then
  help
  exit 1
fi

USER="$1"
DISTRO="$2"
shift 2

RUN_N_TIMES="$1"
TIMESTAMP="$2"
MODE="$3"

if [ -z "$RUN_N_TIMES" ]; then
  echo "Number of times to run was not specified...Setting to the default value '10'..."
  RUN_N_TIMES="10"
else
  shift 1
fi

if [ -z "$TIMESTAMP" ]; then
  echo "Timestamp was not specified...Setting to the default value 'current time'..."
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
else
  shift 1
fi

if [ -z "$MODE" ]; then
  echo "Mode was not specified...Setting to the default value 'both'..."
  MODE="both"
else
  shift 1
fi

OUTLIER_MULTIPLIER=2
while [ $# -gt 0 ]; do
  case $1 in
    --outlier-multiplier)
      OUTLIER_MULTIPLIER="$2"
      shift 2
      ;;
    *)
      ORIGINAL_ARGS="$ORIGINAL_ARGS $1"
      shift
      ;;
  esac
done
set -- $ORIGINAL_ARGS

line() {
  printf "\n------------------------------------------------------------\n"
  echo $@
}

remove_outliers() {
  local constant_multiplier=$1
  shift 1
  local values="$@"

  local sum=0
  local count=0
  for value in $values; do
    sum=`echo "$sum + $value" | bc`
    count=`expr $count + 1`
  done
  local mean=`echo "scale=6; $sum / $count" | bc`

  sum=0
  for value in $values; do
    diff=`echo "$value - $mean" | bc`
    sum=`echo "$sum + ($diff * $diff)" | bc`
  done
  local variance=`echo "scale=6; $sum / $count" | bc`
  local std_dev=`echo "scale=6; sqrt($variance)" | bc`

  local lower_bound=`echo "$mean - $constant_multiplier * $std_dev" | bc`
  local upper_bound=`echo "$mean + $constant_multiplier * $std_dev" | bc`

  local trimmed_values=""
  for value in $values; do
    if [ `echo "$value >= $lower_bound" | bc -l` -eq 1 ] && [ `echo "$value <= $upper_bound" | bc -l` -eq 1 ]; then
      trimmed_values="$trimmed_values $value"
    fi
  done

  echo "$trimmed_values"
}

generate_results() {
  if [ $# -lt 2 ]; then
    echo "Usage: $0 <directory> <mode>"
    exit 1
  fi

  local DIRECTORY="$1"
  local MODE="$2"

  shift 2

  local LATEST_FILE=$(find "$DIRECTORY" -type f -name "*iperf*$MODE*" -exec ls -t1 {} + | head -1)

  if [ -n "$LATEST_FILE" ]; then
    echo "Latest iperf server log: $LATEST_FILE"
  else
    echo "Error: failed to find iperf server log"
    exit 1
  fi

  RAW_BANDWIDTH_VALUES=$(grep -o '[0-9.]\+ Gbits/sec' "$LATEST_FILE" | awk '{ print $1 }')
  BANDWIDTH_VALUES="$RAW_BANDWIDTH_VALUES"
  if [ -n "$OUTLIER_MULTIPLIER" ] && echo "$OUTLIER_MULTIPLIER" | grep -Eq '^[+-]?([0-9]*[.])?[0-9]+$' && [ $(echo "$OUTLIER_MULTIPLIER > 0" | bc) -eq 1 ]; then
    BANDWIDTH_VALUES=$(remove_outliers $OUTLIER_MULTIPLIER $RAW_BANDWIDTH_VALUES)
  fi

  REMOVED_ELEMENTS=""
  for i in $RAW_BANDWIDTH_VALUES; do
    skip=""
    for j in $BANDWIDTH_VALUES; do
      if [ "$i" = "$j" ]; then
        skip=1
        break
      fi
    done
    if [ -z "$skip" ]; then
      REMOVED_ELEMENTS="$REMOVED_ELEMENTS $i"
    fi
  done

  if [ ${#REMOVED_ELEMENTS} -gt 0 ]; then
    echo "List of outliers removed: $REMOVED_ELEMENTS"
  fi

  if [ -z "$BANDWIDTH_VALUES" ]; then
    echo "ERROR: No values found or outlier multipler too low." | tee -a "$DIRECTORY/outputs-iperf-$TIMESTAMP.stats"
  else
    SUM=0
    for value in $BANDWIDTH_VALUES; do
      SUM=$(echo "$SUM + $value" | bc)
    done

    AVG_BANDWIDTH=$(echo "scale=2; $SUM / $(echo "$BANDWIDTH_VALUES" | wc -w)" | bc)

    SUM_SQUARED_DIFF=0
    for value in $BANDWIDTH_VALUES; do
      DIFF=$(echo "$value - $AVG_BANDWIDTH" | bc)
      SUM_SQUARED_DIFF=$(echo "$SUM_SQUARED_DIFF + ($DIFF * $DIFF)" | bc)
    done

    VARIANCE=$(echo "scale=2; $SUM_SQUARED_DIFF / $(echo "$BANDWIDTH_VALUES" | wc -w)" | bc)
    STD_DEV=$(echo "scale=2; sqrt($VARIANCE)" | bc)

    echo "Average Bandwidth: $AVG_BANDWIDTH Gbits/sec" | tee -a "$DIRECTORY/outputs-iperf-$TIMESTAMP.stats"
    echo "Standard Deviation: $STD_DEV Gbits/sec" | tee -a "$DIRECTORY/outputs-iperf-$TIMESTAMP.stats"
  fi
}

if [ "$MODE" != "server" ] && [ "$MODE" != "client" ] && [ "$MODE" != "both" ]; then
  line "Invalid mode: $MODE"
  exit 1
fi

if [ "$MODE" = "server" ] || [ "$MODE" = "both" ]; then
  line "Starting server... $@"
  SERVER_OUTPUT_FILE=$OUTPUT_DIRECTORY/outputs-iperf-$DISTRO-server-$TIMESTAMP.txt
  if [ "$MODE" = "both" ]; then
    iperf -s $@ | tee $SERVER_OUTPUT_FILE &
  else
    iperf -s $@ | tee $SERVER_OUTPUT_FILE
    cat $SERVER_OUTPUT_FILE
  fi
fi

if [ "$MODE" = "client" ] || [ "$MODE" = "both" ]; then
  if [ "$MODE" != "both" ] && [ $# -lt 1 ]; then
    echo "When running in client mode, you must specify the server address."
    exit 1
  fi

  for i in $(seq 1 $RUN_N_TIMES)
  do
    line "Starting client $i... $@"
    CLIENT_OUTPUT_FILE=$OUTPUT_DIRECTORY/outputs-iperf-$DISTRO-client-$i-$TIMESTAMP.txt
    if [ "$MODE" = "both" ]; then
      iperf -c localhost | tee $CLIENT_OUTPUT_FILE
    else
      iperf -c $@ | tee $CLIENT_OUTPUT_FILE
    fi
    cat $CLIENT_OUTPUT_FILE
  done
fi

if [ "$MODE" = "client" ]; then
  generate_results $OUTPUT_DIRECTORY "client"
elif [ "$MODE" = "server" ] || [ "$MODE" = "both" ]; then
  generate_results $OUTPUT_DIRECTORY "server"
fi

chown -R $USER $OUTPUT_DIRECTORY

line "Execution of iperf completed. Logs saved in: $OUTPUT_DIRECTORY"
