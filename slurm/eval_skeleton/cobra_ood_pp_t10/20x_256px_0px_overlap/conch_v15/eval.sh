#!/bin/bash

set -euo pipefail

BASE_DIR=$TMPDIR
DATASET=cobra_ood
ENCODER=resnet50
PATHBENCH_DIR=${BASE_DIR}/Patho-Bench
MAG=20x
PATCH_SIZE=512
CONFIG_DIR=${BASE_DIR}/eval_skeleton/${DATASET}/configs
SPLIT_DIR=${BASE_DIR}/eval_skeleton/${DATASET}/

OUTBASE=${BASE_DIR}/eval_skeleton/${DATASET}/${MAG}_${PATCH_SIZE}px_0px_overlap/${ENCODER}

# Finetune Model
MODEL=abmil
EXPERIMENT=finetune
MODIFIER=after
OUT_DIR="features_${ENCODER}_${MODIFIER}_${EXPERIMENT}_${MODEL}"
TASK_CODE="${DATASET}_${MAG}_${PATCH_SIZE}_0px_overlap_${ENCODER}_${MODIFIER}_${EXPERIMENT}_${MODEL}"
python $PATHBENCH_DIR/patho_bench/scripts/sweep_single_task.py \
    --experiment_type ${EXPERIMENT} \
    --model_name $MODEL \
    --model_kwargs_yaml ${CONFIG_DIR}/${MODEL}_kwargs_${ENCODER}.yaml \
    --task_code ${TASK_CODE}--${TASK_CODE} \
    --combine_slides_per_patient False \
    --saveto ${OUTBASE}/${OUT_DIR} \
    --hyperparams_yaml ${CONFIG_DIR}/${EXPERIMENT}/${MODEL}.yaml \
    --patch_dirs_yaml ${CONFIG_DIR}/patch_embeddings_paths.yaml \
    --path_to_split ${SPLIT_DIR}/${DATASET}_folds.csv \
    --path_to_task_config ${CONFIG_DIR}/${DATASET}_config.yaml \
    --pooled_dirs_yaml ${CONFIG_DIR}/pooled_embeddings_paths.yaml

all_test_metrics=$(find ${OUTBASE}/${OUT_DIR} -type f -wholename "*/test_metrics/fold_*/metrics.json")
METRIC="weighted-f1"

# Read all metrics from the files and find fold with best metric
# json is build as {"overall": {"weighted-f1": 0.75, "accuracy": 0.8, ...}}
best_fold=""
best_metric=-1
for file in $all_test_metrics; do
    fold=$(echo $file | grep -oP 'fold_\K[0-9]+')
    metric_value=$(jq -r --arg metric "$METRIC" '.overall[$metric]' $file)
    echo "Fold: $fold, $METRIC: $metric_value"
    if (( $(echo "$metric_value > $best_metric" | bc -l) )); then
        best_metric=$metric_value
        best_fold=$fold
    fi
done

echo "Best fold: $best_fold with $METRIC = $best_metric"

best_model_path=$(find ${OUTBASE}/${OUT_DIR} -type f -wholename "*/checkpoints/fold_${best_fold}/epoch_*.pt")

# Get real path of the best model
best_model_real_path=$(realpath $best_model_path)
echo "Best model path: $best_model_real_path"

# Write kwargs for finetuned model
cp ${CONFIG_DIR}/${MODEL}_kwargs_${ENCODER}.yaml ${OUTBASE}/${MODEL}_kwargs_${ENCODER}_finetuned.yaml
echo "weights_path: $best_model_real_path" >> ${OUTBASE}/${MODEL}_kwargs_${ENCODER}_finetuned.yaml
sed -i 's/pretrained: False/pretrained: True/' ${OUTBASE}/${MODEL}_kwargs_${ENCODER}_finetuned.yaml

# Linprobe from finetuned model
MODEL=abmil
EXPERIMENT=linprobe
MODIFIER=after_finetune
OUT_DIR="features_${ENCODER}_${EXPERIMENT}_${MODIFIER}_${MODEL}"
TASK_CODE="${DATASET}_${MAG}_${PATCH_SIZE}_0px_overlap_${ENCODER}_${EXPERIMENT}_${MODIFIER}_${MODEL}"
python $PATHBENCH_DIR/patho_bench/scripts/sweep_single_task.py \
    --experiment_type ${EXPERIMENT} \
    --model_name $MODEL \
    --model_kwargs_yaml ${OUTBASE}/${MODEL}_kwargs_${ENCODER}_finetuned.yaml \
    --task_code ${TASK_CODE}--${TASK_CODE} \
    --combine_slides_per_patient False \
    --saveto ${OUTDIR}/${OUT_DIR} \
    --hyperparams_yaml ${CONFIG_DIR}/${EXPERIMENT}/linprobe.yaml \
    --patch_dirs_yaml ${CONFIG_DIR}/patch_embeddings_paths.yaml \
    --path_to_split ${SPLIT_DIR}/${DATASET}.csv \
    --path_to_task_config ${CONFIG_DIR}/${DATASET}_config.yaml \
    --pooled_dirs_yaml ${CONFIG_DIR}/pooled_embeddings_paths.yaml

# Linprobe wo finetuned model
MODEL=abmil
EXPERIMENT=linprobe
MODIFIER=wo_finetune
OUT_DIR="features_${ENCODER}_${EXPERIMENT}_${MODIFIER}_${MODEL}"
TASK_CODE="${DATASET}_${MAG}_${PATCH_SIZE}_0px_overlap_${ENCODER}_${EXPERIMENT}_${MODIFIER}_${MODEL}"
python $PATHBENCH_DIR/patho_bench/scripts/sweep_single_task.py \
    --experiment_type ${EXPERIMENT} \
    --model_name $MODEL \
    --model_kwargs_yaml ${CONFIG_DIR}/${MODEL}_kwargs_${ENCODER}.yaml \
    --task_code ${TASK_CODE}--${TASK_CODE} \
    --combine_slides_per_patient False \
    --saveto ${OUTDIR}/${OUT_DIR} \
    --hyperparams_yaml ${CONFIG_DIR}/${EXPERIMENT}/linprobe.yaml \
    --patch_dirs_yaml ${CONFIG_DIR}/patch_embeddings_paths.yaml \
    --path_to_split ${SPLIT_DIR}/${DATASET}.csv \
    --path_to_task_config ${CONFIG_DIR}/${DATASET}_config.yaml \
    --pooled_dirs_yaml ${CONFIG_DIR}/pooled_embeddings_paths.yaml
