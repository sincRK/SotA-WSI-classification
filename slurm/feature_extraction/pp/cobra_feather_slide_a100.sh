#!/bin/bash

#SBATCH --job-name=cobra_feat
#SBATCH --output=cobra_feat.out
#SBATCH --error=cobra_feat.err
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --mem=50000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH --ntasks=3
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:a100:1
#SBATCH --partition=gpu

SLIDE_ENCODER="feather"
PATCH_FOLDER="features_conch_v15"

module load devel/miniforge/24.9.2
conda activate trident

cd $BENCH

# 30 min
cp --parents -r cobra_features/*/${PATCH_FOLDER}/ ${TMPDIR}

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

# few minutes
python ${TMPDIR}/TRIDENT/run_batch_of_slides.py --task feat --max_workers 16 --wsi_dir ${BENCH}/cobra/packages/ood/images/ --custom_list_of_wsis ${BENCH}/cobra/packages/ood/images/list_of_files.csv --job_dir ${TMPDIR}/cobra_features --slide_encoder ${SLIDE_ENCODER} --mag 20 --patch_size 512 --batch_size 128
python ${TMPDIR}/TRIDENT/run_batch_of_slides.py --task feat --max_workers 16 --wsi_dir ${BENCH}/cobra/packages/ood/images/ --custom_list_of_wsis ${BENCH}/cobra/packages/ood/images/list_of_files.csv --job_dir ${TMPDIR}/cobra_features --slide_encoder ${SLIDE_ENCODER} --mag 20 --patch_size 256 --batch_size 128
python ${TMPDIR}/TRIDENT/run_batch_of_slides.py --task feat --max_workers 16 --wsi_dir ${BENCH}/cobra/packages/ood/images/ --custom_list_of_wsis ${BENCH}/cobra/packages/ood/images/list_of_files.csv --job_dir ${TMPDIR}/cobra_features --slide_encoder ${SLIDE_ENCODER} --mag 10 --patch_size 512 --batch_size 128
python ${TMPDIR}/TRIDENT/run_batch_of_slides.py --task feat --max_workers 16 --wsi_dir ${BENCH}/cobra/packages/ood/images/ --custom_list_of_wsis ${BENCH}/cobra/packages/ood/images/list_of_files.csv --job_dir ${TMPDIR}/cobra_features --slide_encoder ${SLIDE_ENCODER} --mag 20 --patch_size 256 --batch_size 128

rsync -av ${TMPDIR}/cobra_features $BENCH
