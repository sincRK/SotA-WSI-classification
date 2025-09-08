#!/bin/bash

#SBATCH --job-name=histai_b1_seg_sharded
#SBATCH --output=histai_b1_seg_sharded.out
#SBATCH --error=histai_b1_seg_sharded.err
#SBATCH --time=48:00:00
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

cd $TMPDIR

cp -r ${BENCH}/histai/histai_skin/skin-b1 $TMPDIR
cp -r ${BENCH}/hf_models_bench $TMPDIR

mkdir ${TMPDIR}/histai_skin_b1_features

git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git

cp -r ${HOME}/SotA-WSI-classification/slurm/feature_extraction $TMPDIR

# Create list of files
bash ${TMPDIR}/feature_extraction/create_list_of_files.sh ${TMPDIR}/skin-b1 tiff 0.5

MODEL_DIR="hf_models_bench"

# for patch_encoders
INPUT_JSON="${TMPDIR}/TRIDENT/trident/patch_encoder_models/"
cp ${TMPDIR}/feature_extraction/patch_encoder_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench

# for segmentation_models
INPUT_JSON="${TMPDIR}/TRIDENT/trident/segmentation_models/"
cp ${TMPDIR}/feature_extraction/segmentation_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench

# for slide_encoder_models
INPUT_JSON="${TMPDIR}/TRIDENT/trident/slide_encoder_models/"
cp ${TMPDIR}/feature_extraction/slide_encoder_models/local_ckpts.json $INPUT_JSON
bash ${TMPDIR}/feature_extraction/rewrite_trident_ckpts.sh $INPUT_JSON $INPUT_JSON $MODEL_DIR ${TMPDIR}/hf_models_bench

which python
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh ${TMPDIR}/skin-b1 ${TMPDIR}/histai_skin_b1_features 5 10 seg 
cp -r ${TMPDIR}/histai_skin_b1_features $BENCH
