#!/usr/bin/env bash

LATEST_COMMIT=$(git rev-parse HEAD)

BACK_COMMIT=$(git log -1 --format=format:%H --full-diff 11-docker/back)

if [[ ${DOCKER_COMMIT} = ${LATEST_COMMIT} ]]; then
        echo "files in folder1 has changed"
        .circleci/do_something.sh
