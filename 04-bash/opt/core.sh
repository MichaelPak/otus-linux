#!/bin/bash

cleanup () {
  rm -f $TMP_MESSAGE_PATH
  rm -f $STATE_PATH
}

start_block () {
  printf "$1\n" >> $TMP_MESSAGE_PATH
}

finish_block () {
  printf "========================\n\n" >> $TMP_MESSAGE_PATH
}

generate_message () {
  mail -s "Nginx statistic" "$RECIPIENT_ADDRESS" < $TMP_MESSAGE_PATH
}

get_time_range () {
  head -n 1 "$TMP_LOG_PATH" | awk '{print $4}' | cut -c 2- | awk '{print "start: " $1}' >> $STATE_PATH
  tail -n 1 "$TMP_LOG_PATH" | awk '{print $4}' | cut -c 2- | awk '{print "finish: " $1}' >> $STATE_PATH
  cat $STATE_PATH >> $TMP_MESSAGE_PATH
  finish_block
}

count_ips () {
  start_block "IP requests count:"
  awk '{print $1}' $TMP_LOG_PATH \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n $COUNT_IP_X \
  | sed -e 's/^[[:space:]]*//' \
  | awk '{print "IP: [" $2 "] count: [" $1 "]"}' \
  >> $TMP_MESSAGE_PATH
  finish_block
}

count_requested_paths () {
  start_block "Requested paths count:"
  awk '{print $7}' $TMP_LOG_PATH \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n $REQUESTED_PATHS_Y \
  | sed -e 's/^[[:space:]]*//' \
  | awk '{print "path: [" $2 "] requests: [" $1 "]"}' \
  >> $TMP_MESSAGE_PATH
  finish_block
}

view_errors () {
  start_block "Errors:"
  cat $TMP_LOG_PATH \
  | grep 'HTTP\/1.1" [4-5]' \
  | awk '{print $6 " " $7 " " $9}' \
  | cut -c 2- \
  | sort \
  | uniq -c \
  | sort -nr \
  | sed -e 's/^[[:space:]]*//' \
  | awk '{print "code: [" $4 "] method: [" $2 "] path: [" $3 "] count: [" $1 "]"}' \
  >> $TMP_MESSAGE_PATH
  finish_block
}

count_codes () {
  start_block "HTTP codes:"
  cat $TMP_LOG_PATH \
  | cut -d '"' -f3 \
  | cut -d ' ' -f2 \
  | sort \
  | uniq -c \
  | sort -nr \
  | sed -e 's/^[[:space:]]*//' \
  | awk '{print "code: [" $2 "] count: [" $1 "]"}' \
  >> $TMP_MESSAGE_PATH
  finish_block
}

mail_message () {
  echo "Sending message to $RECIPIENT_ADDRESS"
  mail -s "Nginx statistic" $RECIPIENT_ADDRESS < $TMP_MESSAGE_PATH
}

run () {
  cleanup
  generate_message
  get_time_range
  count_ips
  count_requested_paths
  view_errors
  count_codes
  mail_message
}

stop () {
  run
  rm -f $LOCKFILE_PATH
  exit $?
}