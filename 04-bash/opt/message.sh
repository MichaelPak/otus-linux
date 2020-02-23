#!/bin/bash

# import variables
source setenv.sh

# import core functions
source core.sh

if ( set -o noclobber; echo "$$" > "$LOCKFILE_PATH") 2> /dev/null; then
  trap 'stop' INT TERM EXIT KILL

  if [ -f "$STATE_PATH" ]; then
    finish_datetime=$(tail -n 1 "$STATE_PATH" | awk '{print $2}')
    linesToSkip=$(grep -n "$finish_datetime" "$ACCESS_LOG_PATH" | awk -F':' '{print $1'})
    echo "Skip $linesToSkip lines"
  else
    linesToSkip=0
    echo "Start without skipping"
  fi

  rm -f $TMP_LOG_PATH

  {
    for ((i=$linesToSkip;i--;)); do
      read
    done
    while read line ;do
      echo $line
      echo $line >> $TMP_LOG_PATH
      sleep 1
    done
  } < $ACCESS_LOG_PATH

else
  echo "Failed to acquire lockfile: $LOCKFILE_PATH."
  echo "Held by $(cat $LOCKFILE_PATH)"
fi
