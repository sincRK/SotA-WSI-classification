#!/bin/bash
# feature_extraction_sharded.sh
# Usage: feature_extraction_sharded.sh $TMPDIR
# setup the conda environment on cluster node

cd $TMPDIR

# clone TRIDENT
git clone -b dev --single-branch https://github.com/sincRK/TRIDENT.git


module load devel/miniforge/24.9.2

# clone patho_bench
git clone -b dev --single-branch https://github.com/sincRK/Patho-Bench.git

conda env create --file "${TMPDIR}/Patho-Bench/environment.yml" --yes
conda activate patho_bench
# add trident to python path
cd ${TMPDIR}/TRIDENT
SITE_PACKAGES=$(python -c "import sysconfig; print(sysconfig.get_paths()['purelib'])")
echo $(pwd) >> ${SITE_PACKAGES}/trident.pth

# add patho_bench to python path
cd ${TMPDIR}/Patho-Bench
echo $(pwd) >> ${SITE_PACKAGES}/patho_bench.pth
