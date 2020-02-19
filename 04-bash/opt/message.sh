#!/bin/bash

# import variables
source setenv.sh

# import common functions
source common.sh

# import core functions
source core.sh

run () {
  # generate message file
  cleanup
  count_ips
  count_requested_paths
  view_errors
  count_codes
  send_message
}

if ( set -o noclobber; echo "$$" > $PID_FILE_PATH)