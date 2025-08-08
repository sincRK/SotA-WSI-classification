#!/bin/bash

# move output to bench
# check if output is written to project
FEATURES="${BENCH}/features"
HISTAI=${TMPDIR}/histai/output
COBRA=${TMPDIR}/cobra/output
PP=${TMPDIR}/pp/output

# for histai
if [ -d "$HISTAI" ] && find "$HISTAI" -type f -name '*.h5' | grep -q .; then
    echo "Folder ${HISTAI} exists and contains .h5 files"
    mkdir -p "${FEATURES}/histai"
    cp -r "${HISTAI}/*" "${FEATURES}/histai/"
else
    echo "Folder ${HISTAI} does not exist or contains no .h5 files"
    archive_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$archive_name" -C "$(dirname "${HISTAI}")" "$(basename "${HISTAI}")"
    mv "$archive_name" "$FEATURES"
fi

# for cobra
if [ -d "$COBRA" ] && find "$COBRA" -type f -name '*.h5' | grep -q .; then
    echo "Folder ${COBRA} exists and contains .h5 files"
    mkdir -p "${FEATURES}/cobra"
    cp -r "${COBRA}/*" "${FEATURES}/cobra/"
else
    echo "Folder ${COBRA} does not exist or contains no .h5 files"
    archive_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$archive_name" -C "$(dirname "${COBRA}")" "$(basename "${COBRA}")"
    mv "$archive_name" "$FEATURES"
fi

# for pp
if [ -d "$PP" ] && find "$PP" -type f -name '*.h5' | grep -q .; then
    echo "Folder ${PP} exists and contains .h5 files"
    mkdir -p "${FEATURES}/pp"
    cp -r "${PP}/*" "${FEATURES}/pp/"
else
    echo "Folder ${PP} does not exist or contains no .h5 files"
    archive_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$archive_name" -C "$(dirname "${PP}")" "$(basename "${PP}")"
    mv "$archive_name" "$FEATURES"
fi
