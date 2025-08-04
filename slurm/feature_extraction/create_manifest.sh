#!/bin/bash

# Ausgangsverzeichnis
src_root="${1:-.}"  # kann per Argument überschrieben werden
file_type="${2:-tiff}"
manifest="manifest.csv"

# Manifest initialisieren
echo "target_filename,original_path" > "$manifest"

# Alle .tiff-Dateien im Quellverzeichnis rekursiv durchlaufen
find "$src_root" -type f -name "*.${file_type}" | while read -r filepath; do
    # relativer Pfad ohne führendes foo/
    rel_path="${filepath#$src_root/}"

    # Zielname aus Pfad generieren, Trennzeichen: _
    new_name="${rel_path//\//_}"

    # Eintrag ins Manifest schreiben
    echo "$new_name,$filepath" >> "$manifest"
done

echo "Manifest geschrieben: $manifest"
