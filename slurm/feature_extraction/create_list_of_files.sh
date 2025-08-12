#!/bin/bash

# Usage: ./create_list_of_files.sh /path/to/dir tiff 0.25

target_dir="$1"
extension="$2"
mpp="$3" #mpp stands for microns per pixel

output_csv="${target_dir%/}/list_of_files.csv"

echo "Writing ${output_csv} of ${target_dir}"

# CSV-Header schreiben
echo "wsi,mpp" > "$output_csv"

# Dateien mit passender Extension rekursiv finden und in CSV schreiben
find "$target_dir" -type f -name "*.${extension}" | while read -r file; do
  abs_path=$(realpath "$file")
  echo "$abs_path,$mpp" >> "$output_csv"
done

echo "Created list_of_files.csv at ${output_csv}"


