#!/bin/bash
# @file entrypoint.sh
# @brief Entrypoint for Github Action.
#
# @description This script acts as the entrypoint for this Github Action. Its sole purpose is to
# call the scripts doing the actual work. The scripts are splitted to ensure maintainability and
# to comply to the single responsibility principle.
#
# IMPORTANT: Do not run this script directly! This script is intended to run as part of a Github
# Actions job!
#
# ==== Arguments
#
# The script does not accept any parameters.


echo "[INFO] Deletage to generate-from-bash.sh ================================================"
bash /generate-from-bash.sh
