#!/bin/bash

# adapt dataset in job-name
#SBATCH --job-name=cobra_bcc_feat_conchv15
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --mem=150000m
#SBATCH --ntasks=20
#SBATCH --cpus-per-task=2
#SBATCH --gres=gpu:a100:1
#SBATCH --partition=gpu

FEAT_DIR="cobra_bcc_features" # adapt feature dir in $BENCH
PATCH_ENCODER="resnet50" # adapt patch encoder key as in slurm/feature_extraction/patch_encoder_models/local_ckpts.json
DATA_DIR="${BENCH}/cobra/packages/bcc/images/" # adapt image dir of dataset

module load devel/miniforge/24.9.2
conda activate trident

cd $BENCH

# 30 min
cp --parents -r ${FEAT_DIR}/*/patches/ ${TMPDIR}

cd $TMPDIR

cp -r ${BENCH}/hf_models_bench $TMPDIR

git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git

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

which python

# adapt the resource usage:
# first number is max workers isyntax 1 max workers, others 2-3
# second number is sharding. therefore make an estimate how many
# model instances can run on gpu. at least 10% leeway for overhead
# bash ${TMPDIR}/feature_extr ... ${TMPDIR}/${FEAT_DIR} _ _ feat ...

bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh $DATA_DIR ${TMPDIR}/${FEAT_DIR} 3 18 feat $PATCH_ENCODER 20 512 128 ${TMPDIR}/${FEAT_DIR}/20x_512px_0px_overlap/
rsync -av ${TMPDIR}/${FEAT_DIR} $BENCH

bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh $DATA_DIR ${TMPDIR}/${FEAT_DIR} 3 18 feat $PATCH_ENCODER 20 256 128 ${TMPDIR}/${FEAT_DIR}/20x_256px_0px_overlap/
rsync -av ${TMPDIR}/${FEAT_DIR} $BENCH

bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh $DATA_DIR ${TMPDIR}/${FEAT_DIR} 3 18 feat $PATCH_ENCODER 10 512 128 ${TMPDIR}/${FEAT_DIR}/10x_512px_0px_overlap/
rsync -av ${TMPDIR}/${FEAT_DIR} $BENCH

bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh $DATA_DIR ${TMPDIR}/${FEAT_DIR} 3 18 feat $PATCH_ENCODER 10 256 128 ${TMPDIR}/${FEAT_DIR}/10x_256px_0px_overlap/
rsync -av ${TMPDIR}/${FEAT_DIR} $BENCH
