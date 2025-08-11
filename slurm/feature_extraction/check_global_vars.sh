#!/bin/bash

# Pipeline requires
# $TMPDIR (node scratch dir) and
# $BENCH (project base folder) and
# $HOME (config and scripts folder)
# as global variables
if [ -z "${TMPDIR+x}" ]; then
    echo "TMPDIR not set. Where is the scratch folder?"
    exit 1
else
    echo "Scratch folder set to ${TMPDIR}."
fi

if [ -z "${BENCH+x}" ]; then
    echo "BENCH not set. Where is the project base folder?"
    exit 1
else
    echo "Project base folder set to ${BENCH}."
fi

if [ -z "${HOME+x}" ]; then
    echo "HOME not set. Where is the config and script folder?"
    exit 1
else
    echo "Project base folder set to ${HOME}."
fi
