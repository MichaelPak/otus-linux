#!/usr/bin/env bash

LATEST_COMMIT=$(git rev-parse HEAD)

BACK_COMMIT=$(git log -1 --format=format:%H --full-diff 11-docker/back)

docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"

build_and_push () {
    cd 11-docker/back && pipenv lock --requirements > requirements.txt
    docker build --build-arg VCS_REF=`git rev-parse --short HEAD` -t michaelpak/otus-linux-$1 .
    docker push michaelpak/otus-linux-$1
}

if [[ ${BACK_COMMIT} = ${LATEST_COMMIT} ]]; then
        echo "Files for backend has changed"
        build_and_push back
fi