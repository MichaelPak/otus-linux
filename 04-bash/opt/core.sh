#!/bin/bash

count_ips () {
  start_block "IP requests count:"
  awk '{print $1}' $ACCESS_LOG_PATH \
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
  awk '{print $7}' $ACCESS_LOG_PATH \
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
  cat $ACCESS_LOG_PATH \
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
  cat access.log \
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