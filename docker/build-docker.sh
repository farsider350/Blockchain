#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

DOCKER_IMAGE=${DOCKER_IMAGE:-autxpay/autxd-develop}
DOCKER_TAG=${DOCKER_TAG:-latest}

BUILD_DIR=${BUILD_DIR:-.}

rm docker/bin/*
mkdir docker/bin
cp $BUILD_DIR/src/autxd docker/bin/
cp $BUILD_DIR/src/autx-cli docker/bin/
cp $BUILD_DIR/src/autx-tx docker/bin/
strip docker/bin/autxd
strip docker/bin/autx-cli
strip docker/bin/autx-tx

docker build --pull -t $DOCKER_IMAGE:$DOCKER_TAG -f docker/Dockerfile docker
