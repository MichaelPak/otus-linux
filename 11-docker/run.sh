#!/usr/bin/env bash

LATEST_COMMIT=$(git rev-parse HEAD)

BACK_COMMIT=$(git log -1 --format=format:%H --full-diff 11-docker/back)
FRONT_COMMIT=$(git log -1 --format=format:%H --full-diff 11-docker/front)

docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

build_and_push () {
    cd 11-docker && docker build --build-arg VCS_REF=`git rev-parse --short HEAD` \
            -f $1/Dockerfile -t michaelpak/otus-docker-$1 .
    docker push michaelpak/otus-docker-$1
}

set -e

if [[ ${BACK_COMMIT} = ${LATEST_COMMIT} ]]; then
    cd 11-docker/back
    pipenv lock --requirements > requirements.txt
    echo "Files for backend has changed"
    build_and_push back
elif [[ ${FRONT_COMMIT} = ${LATEST_COMMIT} ]]; then
    echo "Files for frontend has changed"
    build_and_push front
fi
