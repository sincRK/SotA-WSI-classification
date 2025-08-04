#!/bin/bash

# fetch all *.isyntax
cd ${TMPDIR}/pp/data/
find . -type f -name '*.isyntax' | awk -v mpp=0.25 'BEGIN {print "wsi,mpp"} {print $0","mpp}' > list_of_wsi.csv
# run feature_extraction on single core
# as patch encoder
# for uni
# for uni2
python ${TMPDIR}/TRIDENT/run_batch_of_slides.py --task all --max_workers 1 --wsi_dir $(pwd) --custom_list_of_wsis ./list_of_wsi.csv --job_dir ${TMPDIR}/pp/output/ --patch_encoder uni_v2
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
# for gigapath
# for quiltnet-b16
# for beph
