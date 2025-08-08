#!/bin/bash

# Usage create_manifest.sh /path/image_folder image_ext
# manifest.csv will be created in same folder as $(pwd)
# the file names in manifest.csv will be relative to /path/image
# and will start with _path_image_folder_...

# Ausgangsverzeichnis
src_root="${1:-.}"  # kann per Argument überschrieben werden
file_type="${2:-tiff}"
manifest="manifest.csv"

# Manifest initialisieren
echo "target_filename,original_path" > "$manifest"

# Alle .file_type-Dateien im Quellverzeichnis rekursiv durchlaufen
find "$src_root" -type f -name "*.${file_type}" | while read -r filepath; do
    # relativer Pfad ohne führendes foo/
    rel_path="${filepath#$src_root/}"
    real_path=$(realpath "${filepath}")

    # Zielname aus Pfad generieren, Trennzeichen: _
    new_name="${rel_path//\//_}"

    # Eintrag ins Manifest schreiben
    echo "$new_name,$real_path" >> "$manifest"
done

echo "Manifest geschrieben: $manifest"
