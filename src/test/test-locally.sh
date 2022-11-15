#!/bin/bash
# @file test-locally.sh
# @brief Run on localhost to test this actions Docker image.
#
# @description Run this script on your localhost to build as (tagged as
# ``local/generate-docs-action:dev``) and run the image. When running this image locally the
# ``docs/modules/AUTO-GENERATED`` Antora module is generated based in bash scripts from this repo.
#
# Keep in mind that the Docker container is run as root due to Github Action policy:
#
# [quote, https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions#user]
# ____
# Docker actions must be run by the default Docker user (root). Do not use the USER instruction in
# your Dockerfile, because you won't be able to access the GITHUB_WORKSPACE.
# ____
#
# When running the image locally the ``docs/modules/AUTO-GENERATED`` directory is owned by ``root``.
# To remove this directory ``sudo`` is required.
#
# ==== Arguments
#
# The script does not accept any parameters.


IMAGE="local/generate-docs-action:dev"


echo -e "$LOG_INFO Remove old versions of image $IMAGE"
docker image rm "$IMAGE"

echo -e "$LOG_INFO Build image $IMAGE"
(
  cd src/main || exit
  docker build -t "$IMAGE" .
)

echo -e "$LOG_INFO Run container with image $IMAGE"
docker run -it --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" "$IMAGE"
