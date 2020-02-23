#!/bin/bash

COUNT_IP_X=10
REQUESTED_PATHS_Y=10

WORK_PATH="/opt"
TMP_PATH="/tmp/messages"

ACCESS_LOG_PATH="$WORK_PATH/access.log"
LOCKFILE_PATH="$WORK_PATH/message.lock"

TMP_LOG_PATH="$TMP_PATH/tmp.log"
TMP_MESSAGE_PATH="$TMP_PATH/message"
PID_FILE_PATH="$TMP_PATH/message"
STATE_PATH="$TMP_PATH/state"

RECIPIENT_ADDRESS="mialpak@gmail.com"