#!/bin/bash

#SBATCH --job-name=pp_feat_sharded
#SBATCH --output=pp_feat_sharded.out
#SBATCH --error=pp_feat_sharded.err
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --mem=90000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=5
#SBATCH --gres=gpu:a100:1
#SBATCH --partition=gpu

FEAT_DIR="pp_features"
PATCH_ENCODER="resnet50"
DATA_DIR="${BENCH}/pp"

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

# conch_v15 - 2:30h x 4
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh $DATA_DIR ${TMPDIR}/${FEAT_DIR} 3 18 feat $PATCH_ENCODER 20 512 128 ${TMPDIR}/${FEAT_DIR}/20x_512px_0px_overlap/
rsync -av ${TMPDIR}/${FEAT_DIR} $BENCH

bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh $DATA_DIR ${TMPDIR}/${FEAT_DIR} 3 18 feat $PATCH_ENCODER 20 256 128 ${TMPDIR}/${FEAT_DIR}/20x_256px_0px_overlap/
rsync -av ${TMPDIR}/${FEAT_DIR} $BENCH

bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh $DATA_DIR ${TMPDIR}/${FEAT_DIR} 3 18 feat $PATCH_ENCODER 10 512 128 ${TMPDIR}/${FEAT_DIR}/10x_512px_0px_overlap/
rsync -av ${TMPDIR}/${FEAT_DIR} $BENCH

bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh $DATA_DIR ${TMPDIR}/${FEAT_DIR} 3 18 feat $PATCH_ENCODER 10 256 128 ${TMPDIR}/${FEAT_DIR}/10x_256px_0px_overlap/
rsync -av ${TMPDIR}/${FEAT_DIR} $BENCH