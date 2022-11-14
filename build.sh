#!/bin/bash

(
  cd src/main/baseimage || exit

  docker pull sommerfeldio/git:ci-build
  docker build -t local/shdoc:dev .
)

docker run --rm \
  --volume "$(pwd):$(pwd)" \
  --workdir "$(pwd)" \
  local/shdoc:dev shdoc < entrypoint.sh > entrypoint.md
