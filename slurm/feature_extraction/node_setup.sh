#!/bin/bash

# Setup Node with the following:
cd $TMPDIR
# clone TRIDENT
git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git
# install TRIDENT
module load devel/miniforge/24.9.2
module load devel/python/3.12_gnu_11.4
conda env create -f "${TMPDIR}/TRIDENT/environment.yml" --yes
conda activate trident
# add trident to python path
SITE_PACKAGES=$(python -c "import sys; print(sys.get")
cd ${TMPDIR}/TRIDENT
echo $(pwd) > $(SITE_PACKAGES)/trident.pth
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
# move model weights to trident
HF_BENCH=/pfs/10/project/bw16k010/benchmark/hf_models_bench
HF_TMP="${TMPDIR}/hf_models_bench"
mkdir $HF_TMP
# for patch_encoders
cp /home/fr/fr_fr/fr_sr1178/feature_extraction/patch_encoder_models/local_ckpts.json ${TMPDIR}/TRIDENT/trident/patch_encoder_models/
sed -i "s|$HF_BENCH|$HF_TMP|g" ${TMPDIR}/TRIDENT/trident/patch_encoder_models/local_ckpts.json
# for segmentation_models
cp /home/fr/fr_fr/fr_sr1178/feature_extraction/segmentation_models/local_ckpts.json ${TMPDIR}/TRIDENT/trident/segmentation_models/
sed -i "s|$HF_BENCH|$HF_TMP|g" ${TMPDIR}/TRIDENT/trident/segmentation_models/local_ckpts.json
# for slide_encoder_models
cp /home/fr/fr_fr/fr_sr1178/feature_extraction/slide_encoder_models/local_ckpts.json ${TMPDIR}/TRIDENT/trident/slide_encoder_models/
sed -i "s|$HF_BENCH|$HF_TMP|g" ${TMPDIR}/TRIDENT/trident/slide_encoder_models/local_ckpts.json

