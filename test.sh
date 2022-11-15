#!/bin/bash
# @file test.sh
# @brief Local tets
#
# @description Run locally
#
# ==== Arguments
#
# The script does not accept any parameters.


IMAGE="local/shdoc:dev"

docker image rm "$IMAGE"

(
  cd src/main || exit
  docker build -t "$IMAGE" .
)

docker run -it --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" "$IMAGE" bash
