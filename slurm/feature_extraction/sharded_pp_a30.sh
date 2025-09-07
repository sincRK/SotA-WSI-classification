#!/bin/bash

#SBATCH --job-name=pp_seg_sharded
#SBATCH --output=pp_seg_sharded.out
#SBATCH --error=pp_seg_sharded.err
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --mem=90000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:a30:1
#SBATCH --partition=gpu


module load devel/miniforge/24.9.2
conda activate trident

cd $TMPDIR

cp -r ${BENCH}/pp $TMPDIR
cp -r ${BENCH}/hf_models_bench $TMPDIR

mkdir ${TMPDIR}/pp_features

git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git

cp -r ${HOME}/SotA-WSI-classification/slurm/feature_extraction $TMPDIR

# Create list of files
bash ${TMPDIR}/feature_extraction/create_list_of_files.sh ${TMPDIR}/pp isyntax 0.25

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
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh ${TMPDIR}/pp ${TMPDIR}/pp_features 1 5 seg uni_v2 20x 512
bash ${TMPDIR}/feature_extraction/feature_extraction_sharded.sh ${TMPDIR}/pp ${TMPDIR}/pp_features 1 5 seg uni_v2 20x 256

cp -r ${TMPDIR}/pp_features $BENCH
