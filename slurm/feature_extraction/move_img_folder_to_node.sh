#!/bin/bash

# move data to $TMPDIR
# usage example /path/histai /path2/histai/data tiff
root_img_folder="$1"
target_dir="$2"
extension="$3"

# create manifest for root_img_folder
bash ${TMPDIR}/feature_extraction/create_manifest.sh $root_img_folder $extension

# copy files from root_img_folder to target_dir
# this will collapse the root_img_folder structure
# all imgs will be renamed based on their real_path and
# put into target_dir on the same level
bash ${TMPDIR}/feature_extraction/copy_from_manifest.sh manifest.csv $target_dir
