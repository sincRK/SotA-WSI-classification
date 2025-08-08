#!/bin/bash

#SBATCH --job-name=test_run
#SBATCH --output=test_run.out
#SBATCH --error=test_run.err
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --mem=10000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH -c 8

# Set global vars the first two should be set per default
# export HOME=
# export TMPDIR=
export BENCH=/pfs/10/project/bw16k010/benchmark/test

# Pipeline requires
# $TMPDIR (node scratch dir) and
# $BENCH (project base folder) and
# $HOME (config and scripts folder)
# as global variables
if [ -z "${TMPDIR+x}" ]; then
    echo "TMPDIR not set. Where is the scratch folder?"
    exit(1)
else
    echo "Scratch folder set to ${TMPDIR}."
fi

if [ -z "${BENCH+x}" ]; then
    echo "BENCH not set. Where is the project base folder?"
    exit(1)
else
    echo "Project base folder set to ${BENCH}."
fi

if [ -z "${HOME+x}" ]; then
    echo "HOME not set. Where is the config and script folder?"
    exit(1)
else
    echo "Project base folder set to ${HOME}."
fi

# Copy the script folder to TMPDIR
# Check for updates regularly
cp -r ${HOME}/feature_extraction $TMPDIR

# Sanity check - should always pass
bash ${TMPDIR}/feature_extraction/check_global_vars.sh

# Setup node
bash ${TMPDIR}/feature_extraction/node_setup.sh

# Copy the hf_models_bench folder
cp -r ${BENCH}/hf_models_bench ${TMPDIR}

# Move imgs for each of histai, cobra and pp
bash ${TMPDIR}/feature_extraction/move_img_folder_to_node.sh ${BENCH}/histai ${TMPDIR}/histai/data "tiff"
bash ${TMPDIR}/feature_extraction/move_img_folder_to_node.sh ${BENCH}/cobra ${TMPDIR}/cobra/data "tif"
bash ${TMPDIR}/feature_extraction/move_img_folder_to_node.sh ${BENCH}/pp ${TMPDIR}/pp/data "isyntax"

# Create wsi,mpp lists for feature extraction
bash ${TMPDIR}/feature_extraction/create_list_of_files.sh ${TMPDIR}/histai/data "tiff" 0.5
bash ${TMPDIR}/feature_extraction/create_list_of_files.sh ${TMPDIR}/cobra/data "tif" 0.5
bash ${TMPDIR}/feature_extraction/create_list_of_files.sh ${TMPDIR}/pp/data "isyntax" 0.25

# Run feature extraction
bash ${TMPDIR}/feature_extraction/extract_features.sh ${TMPDIR}/histai/data ${TMPDIR}/histai/output 8
bash ${TMPDIR}/feature_extraction/extract_features.sh ${TMPDIR}/cobra/data ${TMPDIR}/cobra/output 8
bash ${TMPDIR}/feature_extraction/extract_features.sh ${TMPDIR}/pp/data ${TMPDIR}/pp/output 1

# Copy data from node to bench
bash ${TMPDIR}/feature_extraction/move_node_to_bench.sh

# Clean node
bash ${TMPDIR}/feature_extraction/node_cleanup.sh
