#!/bin/bash

# Usage: bash click_resnet50_eval.sh /path/to/target/dir/eval.sh
# This will recreate the eval.sh from the template blocks
# The target models are based on the encoder
# resnet50 runs the following experiments:
# - finetune abmil
# - linprobe abmil after finetune
# - linprobe abmil wo finetune

# it is highly recommended to run adapt_evals.sh after this to fix the variables
# derived from the /path/to/target/dir/eval.sh path

TARGET_FILE=$1
SCRIPT_DIR=$(dirname "$0")
echo "Recreating $TARGET_FILE"

# Create a temporary file to hold the new content
TEMP_FILE=$(mktemp)

# Append eval_block/base.template
cat ${SCRIPT_DIR}/eval_block/base.template >> $TEMP_FILE

# Take eval_block/finetune.template and sed MODEL=... with MODEL=abmil then append
sed 's/^MODEL=.*/MODEL=abmil/' ${SCRIPT_DIR}/eval_block/finetune.template >> $TEMP_FILE

cat ${SCRIPT_DIR}/eval_block/model_artifact_to_results_dir.template >> $TEMP_FILE

# Take eval_block/linprobe_after_finetune.template and sed MODEL=... with MODEL=abmil then append
sed 's/^MODEL=.*/MODEL=abmil/' ${SCRIPT_DIR}/eval_block/linprobe_after_finetune.template >> $TEMP_FILE

# Take eval_block/linprobe_wo_finetune.template and sed MODEL=... with MODEL=abmil then append
sed 's/^MODEL=.*/MODEL=abmil/' ${SCRIPT_DIR}/eval_block/linprobe_wo_finetune.template >> $TEMP_FILE

# Move the temporary file to the target location
mv $TEMP_FILE $TARGET_FILE

