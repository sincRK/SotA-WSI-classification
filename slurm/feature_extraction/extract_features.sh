#!/bin/bash

# Usage: extract_features.sh /path/data /path/output 8
# Assumes list_of_files.csv in data dir and images in data dir
DATA_DIR="$1"
OUTPUT_DIR="$2"
WORKERS="$3"

module load devel/miniforge/24.9.2
conda activate trident
which python

# run feature_extraction on multi core (default 8)
# as patch encoder
# for uni
# for uni2
python ${TMPDIR}/TRIDENT/run_batch_of_slides.py --task all --max_workers $WORKERS --wsi_dir $DATA_DIR --custom_list_of_wsis ${DATA_DIR}/list_of_files.csv --job_dir $OUTPUT_DIR --patch_encoder uni_v2
# for phikon
# for phikonv2
# for ctranspath
# for virchow
# for virchow2
# for h-optimus-0
# for prov-gigapath
# for kaiko
# for hibou
# for plip
# for biomedclip
# for conch
# for lunit
# for hipt
# for pathdino
# as slide encoder
# for titan
# for feather
# for chief
# for madeleine
# for prov-gigapath
# for quiltnet-b32
# for beph
