#!/bin/bash

BASE_DIR=$1
SCRIPT_DIR=$(dirname "$0")

eval_files=$(find $BASE_DIR -type f -name "eval.sh")

for file in $eval_files; do
    dir=$(basename $(dirname "$file"))
    bash "${SCRIPT_DIR}/click_${dir}_eval.sh" ${file}
done
