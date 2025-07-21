#!/bin/bash

#SBATCH --job-name=download_histai_mixed
#SBATCH --output=download_histai_mixed.out
#SBATCH --error=download_histai_mixed.err
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --mem=5000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH -c 1

module load devel/miniforge/24.9.2
module load devel/python/3.12_gnu_11.4

ROOT_DIR="/pfs/10/project/bw16k010/benchmark/histai"

conda env create -f "${ROOT_DIR}/environment.yml" --yes
conda activate histai

huggingface-cli login --token $(cat "${ROOT_DIR}/.hf_token")
huggingface-cli download histai/HISTAI-mixed --repo-type dataset --local-dir ${ROOT_DIR}/mixed/


