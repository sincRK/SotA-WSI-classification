#!/bin/bash

#SBATCH --job-name=download_histai_test
#SBATCH --output=download_histai_test.out
#SBATCH --error=download_histai_test.err
module load devel/miniforge/24.9.2
module load devel/python/3.12_gnu_11.4

ROOT_DIR="/pfs/10/project/bw16k010/benchmark/histai"

conda env create -f "${ROOT_DIR}/environment.yml" --yes
conda activate histai

huggingface-cli login --token $(cat "${ROOT_DIR}/.hf_token")

python -c "from huggingface_hub import snapshot_download"

python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='histai/histai-mixed', repo_type='dataset', local_dir='${ROOT_DIR}/mixed')"
