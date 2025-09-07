#!/bin/bash

# Take any number of shard folders and merge them into a single output folder.
# Usage: merge_shards.sh /path/to/shard1 /path/to/shard2 ... /path/to/output
# Example:
#   bash merge_shards.sh /path/to/shard_00 /path/to/shard_01 /path/to/output

# Merge strategy:
# expected folders are:
# contours/*.jpg
# contours_geojson/*.geojson
# thumbnails/*.jpg
# {Magnification}x_{PatchSize}px_{Overlap}px_overlap/ containing
# .../features_{patch_encoder}/*.h5
# .../patches/*.h5
# .../visualization/*.jpg
#
# Other files are:
# list_of_files.csv
# _config_....json
# _logs_....txt
#
# These files may be on any level of the shard folder
# The content of the folders should be merged into the corresponding folder in the output dir
# the logs and config files should be copied to the output dir 
# and prefixed with the shard folder name to avoid overwriting
# same for the list_of_files.csv files.
# Before copying the folder contents, check if duplicates exists in the target folder
# if finding duplicates abort the merging process
# and inform the user to resolve the issue manually

set -euo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 /path/to/shard1 /path/to/shard2 ... /path/to/output"
    exit 1
fi

OUTPUT_DIR="${!#}"  # Last argument is the output directory
mkdir -p "$OUTPUT_DIR"

# Setup output subdirectories
mkdir -p "$OUTPUT_DIR/contours"
mkdir -p "$OUTPUT_DIR/contours_geojson"
mkdir -p "$OUTPUT_DIR/thumbnails"

# Loop over all arguments except the last one
for SHARD_DIR in "$@"; do
    if [ "$SHARD_DIR" != "$OUTPUT_DIR" ]; then
        if [ -d "$SHARD_DIR" ]; then
            echo "Merging from $SHARD_DIR to $OUTPUT_DIR"
            SHARD_NAME=$(basename "$SHARD_DIR")
            # Merge known subdirectories
            for SUBDIR in contours contours_geojson thumbnails; do
                if [ -d "$SHARD_DIR/$SUBDIR" ]; then
                    echo "Merging $SUBDIR"
                    for FILE in "$SHARD_DIR/$SUBDIR"/*; do
                        if [ -e "$OUTPUT_DIR/$SUBDIR/$(basename "$FILE")" ]; then
                            echo "Duplicate file found: $OUTPUT_DIR/$SUBDIR/$(basename "$FILE")"
                            echo "Aborting merge. Please resolve duplicates manually."
                            exit 1
                        else
                            cp "$FILE" "$OUTPUT_DIR/$SUBDIR/"
                        fi
                    done
                fi
            done
            # Prefix the shard name to the _logs and _config files in the output dir
            for FILE in "$SHARD_DIR"/_config_*.json "$SHARD_DIR"/_logs_*.txt "$SHARD_DIR"/list_of_files.csv; do
                if [ -e "$FILE" ]; then
                    cp "$FILE" "$OUTPUT_DIR/${SHARD_NAME}_$(basename "$FILE")"
                fi
            done
            # Merge magnification-specific directories
            for MAG_DIR in "$SHARD_DIR"/*x_*px_*px_overlap; do
                if [ -d "$MAG_DIR" ]; then
                    echo "Merging magnification directory $MAG_DIR"
                    MAG_DIR_NAME=$(basename "$MAG_DIR")
                    # If magnification dir does not exist in output, copy it entirely
                    if [ ! -d "$OUTPUT_DIR/$MAG_DIR_NAME" ]; then
                        echo "Copying entire directory $MAG_DIR to output"
                        cp -r "$MAG_DIR" "$OUTPUT_DIR/"
                        # Add shard name prefix to the _config and _logs files if they exist
                        for FILE in "$OUTPUT_DIR/$MAG_DIR_NAME"/_config_*.json "$OUTPUT_DIR/$MAG_DIR_NAME"/_logs_*.txt; do
                            if [ -e "$FILE" ]; then
                                mv "$FILE" "$OUTPUT_DIR/$MAG_DIR_NAME/${SHARD_NAME}_$(basename "$FILE")"
                            fi
                        done
                    else
                        # Merge features, patches, visualization
                        for SUBDIR in features_* patches visualization; do
                            if [ -d "$MAG_DIR/$SUBDIR" ]; then
                                echo "Merging $SUBDIR in $MAG_DIR_NAME"
                                for FILE in "$MAG_DIR/$SUBDIR"/*; do
                                    if [ -e "$OUTPUT_DIR/$MAG_DIR_NAME/$SUBDIR/$(basename "$FILE")" ]; then
                                        echo "Duplicate file found: $OUTPUT_DIR/$MAG_DIR_NAME/$SUBDIR/$(basename "$FILE")"
                                        echo "Aborting merge. Please resolve duplicates manually."
                                        exit 1
                                    else
                                        cp "$FILE" "$OUTPUT_DIR/$MAG_DIR_NAME/$SUBDIR/"
                                    fi
                                done
                            fi
                        done
                        # Add shard name prefix to the _config and _logs files if they exist
                        for FILE in "$MAG_DIR"/_config_*.json "$MAG_DIR"/_logs_*.txt; do
                            if [ -e "$FILE" ]; then
                                cp "$FILE" "$OUTPUT_DIR/$MAG_DIR_NAME/${SHARD_NAME}_$(basename "$FILE")"
                            fi
                        done
                    fi
                fi
            done
        else
            echo "Warning: $SHARD_DIR is not a directory. Skipping."
        fi
    fi
done
