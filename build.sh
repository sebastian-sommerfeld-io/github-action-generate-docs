#!/bin/bash

(
  cd src/main/baseimage || exit

  docker pull sommerfeldio/git:ci-build
  docker build -t local/shdoc:dev .
)
