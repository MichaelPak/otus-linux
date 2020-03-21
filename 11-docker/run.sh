#!/usr/bin/env bash

LATEST_COMMIT=$(git rev-parse HEAD)

DOCKER_COMMIT=$(git log -1 --format=format:%H --full-diff 11-docker)

docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

cd 11-docker

build_and_push () {
    docker build --build-arg VCS_REF=`git rev-parse --short HEAD` \
            -f $1/Dockerfile -t michaelpak/otus-docker-$1 .
    docker push michaelpak/otus-docker-$1
}

set -e

if [[ ${DOCKER_COMMIT} = ${LATEST_COMMIT} ]]; then
    echo "Build & push backend"
    pipenv lock --requirements > requirements.txt
    build_and_push back
    echo "Build & push frontend"
    build_and_push front
fi
