#!/bin/bash

#SBATCH --job-name=download_cobra
#SBATCH --output=download_cobra.out
#SBATCH --error=download_cobra.err
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --mem=5000m
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=sinclair.rockwell-kollmann@pharmazie.uni-freiburg.de
#SBATCH -c 8

module load devel/miniforge/24.9.2
module load devel/python/3.12_gnu_11.4

ROOT_DIR="/pfs/10/project/bw16k010/benchmark/cobra"

conda env create -f "${ROOT_DIR}/environment.yml" --yes
conda activate cobra

bash ${ROOT_DIR}/parallel_download_wrapper.sh 8 ${ROOT_DIR} "${ROOT_DIR}/filelist.json"

