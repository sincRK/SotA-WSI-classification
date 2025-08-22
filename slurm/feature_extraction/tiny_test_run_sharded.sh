#!/bin/bash

#SBATCH --job-name=tiny_test_run_sharded
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --mem=10000m
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:a30:1          # Request 1x A30 GPU
#SBATCH --partition=gpu          # Force job onto the A30 GPU nodes

echo "Job started at: $(date)"
start_time=$SECONDS

# Set global vars the first two should be set per default
# export HOME=
# export TMPDIR=
export BENCH=/pfs/10/project/bw16k010/benchmark/tiny_test

# Pipeline requires
# $TMPDIR (node scratch dir) and
# $BENCH (project base folder) and
# $HOME (config and scripts folder)
# as global variables
if [ -z "${TMPDIR+x}" ]; then
    echo "TMPDIR not set. Where is the scratch folder?"
    exit 1
else
    echo "TMPDIR set to ${TMPDIR}."
fi

if [ -z "${BENCH+x}" ]; then
    echo "BENCH not set. Where is the project base folder?"
    exit 1
else
    echo "BENCH path set to ${BENCH}."
fi

if [ -z "${HOME+x}" ]; then
    echo "HOME not set. Where is the config and script folder?"
    exit 1
else
    echo "HOME path set to ${HOME}."
fi

# Copy the script folder to TMPDIR
# Check for updates regularly
cp -r ${HOME}/SotA-WSI-classification/slurm/feature_extraction $TMPDIR

inter_time=$SECONDS
duration=$(( inter_time - start_time ))
echo "time passed: ${duration}"

# Setup node
bash ${TMPDIR}/feature_extraction/node_setup.sh

inter_time=$SECONDS
duration=$(( inter_time - start_time ))
echo "time passed: ${duration}"

# Copy the specific folder from /hf_models_bench
cp -r "${BENCH}/hf_models_bench/uni_v2/" "${TMPDIR}/hf_models_bench/uni_v2/"

inter_time=$SECONDS
duration=$(( inter_time - start_time ))
echo "time passed: ${duration}"

# Move imgs
bash ${TMPDIR}/feature_extraction/move_img_folder_to_node.sh ${BENCH}/histai ${TMPDIR}/histai/data "tiff"
#bash ${TMPDIR}/feature_extraction/move_img_folder_to_node.sh ${BENCH}/cobra ${TMPDIR}/cobra/data "tif"
#bash ${TMPDIR}/feature_extraction/move_img_folder_to_node.sh ${BENCH}/pp ${TMPDIR}/pp/data "isyntax"

inter_time=$SECONDS
duration=$(( inter_time - start_time ))
echo "time passed: ${duration}"

# Create wsi,mpp lists for feature extraction
bash ${TMPDIR}/feature_extraction/create_list_of_files.sh ${TMPDIR}/histai/data "tiff" 0.5
#bash ${TMPDIR}/feature_extraction/create_list_of_files.sh ${TMPDIR}/cobra/data "tif" 0.5
#bash ${TMPDIR}/feature_extraction/create_list_of_files.sh ${TMPDIR}/pp/data "isyntax" 0.25

inter_time=$SECONDS
duration=$(( inter_time - start_time ))
echo "time passed: ${duration}"

# Run feature extraction
bash "${TMPDIR}/feature_extraction/feature_extraction_sharded.sh" "${TMPDIR}/histai/data" "${TMPDIR}/histai/output" 8 4
mkdir -p ${BENCH}/features/histai/
mv ${TMPDIR}/histai/output ${BENCH}/features/histai/

inter_time=$SECONDS
duration=$(( inter_time - start_time ))
echo "time passed: ${duration}"

# Copy data from node to bench
#bash ${TMPDIR}/feature_extraction/move_node_to_bench.sh

# Clean node
bash ${TMPDIR}/feature_extraction/node_cleanup.sh

inter_time=$SECONDS
duration=$(( inter_time - start_time ))
echo "time passed: ${duration}"