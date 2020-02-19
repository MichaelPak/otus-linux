#!/bin/bash

cleanup () {
  rm $TMP_MESSAGE_PATH
}

start_block () {
  printf "$1\n" >> $TMP_MESSAGE_PATH
}

finish_block () {
  printf "========================\n\n" >> $TMP_MESSAGE_PATH
}