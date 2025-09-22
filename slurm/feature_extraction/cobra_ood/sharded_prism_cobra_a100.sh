#!/bin/bash

#SBATCH --job-name=cobra_feat_sharded
#SBATCH --output=cobra_feat_sharded.out
#SBATCH --error=cobra_feat_sharded.err
#SBATCH --time=8:00:00
#SBATCH --nodes=1
#SBATCH --mem=150000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=5
#SBATCH --gres=gpu:a100:1
#SBATCH --partition=gpu


module load devel/miniforge/24.9.2
conda activate trident

cd $BENCH

# 30 min
cp --parents -r cobra_features/*/patches/ ${TMPDIR}

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

# prism - 1:30h x 4
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh ${BENCH}/cobra/packages/ood/images/ ${TMPDIR}/cobra_features 3 14 feat prism 20 512 128 ${TMPDIR}/cobra_features/20x_512px_0px_overlap/
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh ${BENCH}/cobra/packages/ood/images/ ${TMPDIR}/cobra_features 3 14 feat prism 20 256 128 ${TMPDIR}/cobra_features/20x_256px_0px_overlap/
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh ${BENCH}/cobra/packages/ood/images/ ${TMPDIR}/cobra_features 3 14 feat prism 10 512 128 ${TMPDIR}/cobra_features/10x_512px_0px_overlap/
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh ${BENCH}/cobra/packages/ood/images/ ${TMPDIR}/cobra_features 3 14 feat prism 10 256 128 ${TMPDIR}/cobra_features/10x_256px_0px_overlap/

rsync -av ${TMPDIR}/cobra_features $BENCH
