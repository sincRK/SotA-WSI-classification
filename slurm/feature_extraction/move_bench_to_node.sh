#!/bin/bash

# move data to $TMPDIR
HISTAI=/pfs/10/project/bw16k010/benchmark/histai
COBRA=/pfs/10/project/bw16k010/benchmark/cobra/packages
PP=/pfs/10/project/bw16k010/benchmark/pp
# for histai
bash ${TMPDIR}/copy_from_manifest.sh ${HISTAI}/manifest.csv ${TMPDIR}/histai/data
# for cobra
bash ${TMPDIR}/copy_from_manifest.sh ${COBRA}/manifest.csv ${TMPDIR}/cobra/data
# for pp
bash ${TMPDIR}/copy_from_manifest.sh ${PP}/manifest.csv ${TMPDIR}/pp/data
# for hf_bench_models
cp -r /pfs/10/project/bw16k010/benchmark/hf_bench_models/ ${TMPDIR}/hf_bench_models/
