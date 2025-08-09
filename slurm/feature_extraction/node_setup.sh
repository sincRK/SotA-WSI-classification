#!/bin/bash

# Setup Node with the following:
cd $TMPDIR
# clone TRIDENT
git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git
# install TRIDENT
module load devel/miniforge/24.9.2
conda env create -f "${TMPDIR}/TRIDENT/environment.yml" --yes
conda activate trident
# add trident to python path
SITE_PACKAGES=$(python -c "import sysconfig; print(sysconfig.get_paths()['purelib'])")
cd ${TMPDIR}/TRIDENT
echo $(pwd) > ${SITE_PACKAGES}/trident.pth
# create data structure in $TMPDIR
cd $TMPDIR
mkdir histai
mkdir histai/data
mkdir histai/output
mkdir cobra
mkdir cobra/data
mkdir cobra/output
mkdir pp
mkdir pp/data
mkdir pp/output

# setup local model weights to trident
MODEL_DIR=hf_models_bench
HF_TMP="${TMPDIR}/${MODEL_DIR}"
mkdir $HF_TMP

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
