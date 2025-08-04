#!/bin/bash

# check if output is written to project
FEATURES=/pfs/10/project/bw16k010/benchmark/features
HISTAI=${FEATURES}/histai
COBRA=${FEATURES}/cobra
PP=${FEATURES}/pp

if [ -d "$HISTAI" ] && find "$HISTAI" -type f -name '*.h5' | grep -q .; then
    echo "Folder ${HISTAI} exists and contains .h5 files"
else
    echo "Folder ${HISTAI} does not exist or contains no .h5 files"
    archive_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$archive_name" -C "$(dirname "${TMPDIR}/histai/output")" "$(basename "${TMPDIR}/histai/output")"
    mv "$archive_name" "$FEATURES"
fi

if [ -d "$COBRA" ] && find "$COBRA" -type f -name '*.h5' | grep -q .; then
    echo "Folder ${COBRA} exists and contains .h5 files"
else
    echo "Folder ${COBRA} does not exist or contains no .h5 files"
    archive_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$archive_name" -C "$(dirname "${TMPDIR}/cobra/output")" "$(basename "${TMPDIR}/cobra/output")"
    mv "$archive_name" "$FEATURES"
fi

if [ -d "$PP" ] && find "$PP" -type f -name '*.h5' | grep -q .; then
    echo "Folder ${PP} exists and contains .h5 files"
else
    echo "Folder ${PP} does not exist or contains no .h5 files"
    archive_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$archive_name" -C "$(dirname "${TMPDIR}/pp/output")" "$(basename "${TMPDIR}/pp/output")"
    mv "$archive_name" "$FEATURES"
fi

# remove data structure from $TMPDIR
rm -r ${TMPDIR}/TRIDENT
rm -r ${TMPDIR}/histai
rm -r ${TMPDIR}/cobra
rm -r ${TMPDIR}/pp
rm -r ${TMPDIR}/hf_models_bench
