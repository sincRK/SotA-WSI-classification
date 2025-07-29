#!/bin/bash

#1 copy image file folder into $TMPDIR
#2 compute embeddings via trident
#3 (validate?)
#4 copy embeddings from $TMPDIR to project file system

#SBATCH --job-name=trident_tryout
#SBATCH --output=trident_tryout_%j.log
#SBATCH --error=trident_tryout_err_%j.log
#SBATCH --cpus-per-task=8

SOTAWSI="https://github.com/sincRK/SotA-WSI-classification"
TRIDENT_FORK="https://github.com/sincRK/TRIDENT"

module load devel/miniforge/24.9.2
module load devel/python/3.12_gnu_11.4

IMG_DIR="/pfs/10/project/bw16k010/benchmark/histai/skin-b1"
cp -r ${IMG_DIR} "${TMPDIR}/img_files"

cd $TMPDIR
git clone ${SOTAWSI}
git clone ${TRIDENT_FORK}

TRIDENT_ENV_DIR="${TMPDIR}/SotA-WSI-classification/slurm/ymls/trident.yml"
conda activate trident || conda env create -f "$TRIDENT_ENV_DIR" --yes && conda activate trident

SITE_PACKAGES=$(python -c "import sys; print(sys.get")
cd ${TMPDIR}/TRIDENT
echo $(pwd) > $(SITE_PACKAGES)/trident.pth