#!/bin/bash

# Usage: ./duplicate_json_structure.sh SOURCE_DIR TARGET_DIR
SOURCE_DIR=$1
TARGET_DIR=$2

if [ -z "$SOURCE_DIR" ] || [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 <SOURCE_DIR> <TARGET_DIR>"
    echo "  SOURCE_DIR: Base directory to search for .json files"
    echo "  TARGET_DIR: Target directory to recreate the structure"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

# Convert to absolute paths to avoid issues
SOURCE_DIR=$(realpath "$SOURCE_DIR")
TARGET_DIR=$(realpath "$TARGET_DIR")

echo "Source directory: $SOURCE_DIR"
echo "Target directory: $TARGET_DIR"
echo "----------------------------------------"

# Find all .json files
json_files=$(find "$SOURCE_DIR" -type f -name "*.json")

if [ -z "$json_files" ]; then
    echo "No .json files found in $SOURCE_DIR"
    exit 0
fi

# Convert to array for counting
json_array=($json_files)
total_files=${#json_array[@]}

echo "Found $total_files .json files"
echo "Creating target directory structure..."

# Create target base directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Process each JSON file
copied_files=0
for json_file in $json_files; do
    # Get relative path from source directory
    relative_path="${json_file#$SOURCE_DIR/}"

    # Get the directory part of the relative path
    relative_dir=$(dirname "$relative_path")

    # Create target directory structure
    target_dir="$TARGET_DIR/$relative_dir"
    mkdir -p "$target_dir"

    # Copy the JSON file
    target_file="$TARGET_DIR/$relative_path"
    cp "$json_file" "$target_file"

    echo "Copied: $relative_path"
    copied_files=$((copied_files + 1))
done

echo "----------------------------------------"
echo "Structure duplication complete!"
echo "Files copied: $copied_files / $total_files"
echo "Target structure created at: $TARGET_DIR"

# Optional: Show the created directory structure
echo
echo "Created directory structure:"
find "$TARGET_DIR" -type d | sort | sed "s|^$TARGET_DIR|.|"
