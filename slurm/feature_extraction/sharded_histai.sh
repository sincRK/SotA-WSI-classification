#!/bin/bash

#SBATCH --job-name=test_run_sharded
#SBATCH --output=test_run_sharded.out
#SBATCH --error=test_run_sharded.err
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --mem=90000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH --cpus-per-task=16
#SBATCH --gres=gpu:a30:1
#SBATCH --partition=gpu


module load devel/miniforge/24.9.2
conda activate trident

cd $TMPDIR

cp -r ${BENCH}/histai/histai_skin $TMPDIR
cp -r ${BENCH}/hf_models_bench $TMPDIR

mkdir ${TMPDIR}/histai_features

git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git

cp -r ${HOME}/feature_extraction $TMPDIR

# for patch_encoders
INPUT_JSON="${TMPDIR}/TRIDENT/trident/patch_encoder_models/"
cp ${TMPDIR}/feature_extraction/patch_encoder_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR $TMPDIR

# for segmentation_models
INPUT_JSON="${TMPDIR}/TRIDENT/trident/segmentation_models/"
cp ${TMPDIR}/feature_extraction/segmentation_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR $TMPDIR

# for slide_encoder_models
INPUT_JSON="${TMPDIR}/TRIDENT/trident/slide_encoder_models/"
cp ${TMPDIR}/feature_extraction/slide_encoder_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR $TMPDIR

which python
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh ${TMPDIR}/histai_skin ${TMPDIR}/histai_features 8 2

cp -r histai_features $BENCH
