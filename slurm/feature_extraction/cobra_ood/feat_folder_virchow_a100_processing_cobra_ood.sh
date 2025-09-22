#!/bin/bash

#SBATCH --job-name=feat_virchow_a100



# ENVS
FEAT_DIR="cobra_features"
FEAT_PATH="${BENCH}/${FEAT_DIR}"
PATCH_ENCODER="virchow2"
PATCHSIZE=512
MAG=20
OVERLAP=0
FEAT_FOLDER="${FEAT_PATH}/${MAG}x_${PATCHSIZE}px_${OVERLAP}px_overlap/features_${PATCH_ENCODER}"

module load devel/miniforge/24.9.2

# Setup local scratch
cd $BENCH

cp --parents -r ${FEAT_DIR}/*/features_${PATCH_ENCODER}/ ${TMPDIR}

cd $TMPDIR

cp -r ${BENCH}/hf_models_bench $TMPDIR
git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git
git clone -b dev --single-branch https://github.com/sincRK/Patho-Bench.git

cp -r ${HOME}/SotA-WSI-classification/slurm/feature_extraction $TMPDIR

MODEL_DIR="hf_models_bench"

# for patch_encoders
INPUT_JSON="${TMPDIR}/TRIDENT/trident/patch_encoder_models/local_ckpts.json"
cp ${TMPDIR}/feature_extraction/patch_encoder_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench

# for segmentation_models
INPUT_JSON="${TMPDIR}/TRIDENT/trident/segmentation_models/local_ckpts.json"
cp ${TMPDIR}/feature_extraction/segmentation_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench

# for slide_encoder_models
INPUT_JSON="${TMPDIR}/TRIDENT/trident/slide_encoder_models/local_ckpts.json"
cp ${TMPDIR}/feature_extraction/slide_encoder_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench


# Steps:
# - Feather inference  not possible because embedding dim mismatch (512 vs 1280)
# - Prism2 inference
# awaiting model release
# - prism inference
# awaiting authorization by paige.ai to use model
# - feather finetuning & inference
conda activate patho_bench
which python
# - abmil finetuning & inference
which python


