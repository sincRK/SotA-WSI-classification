#!/usr/bin/env python3
"""
Rename all files of a given type in a directory (recursively) to UUIDv4 names.

Usage:
    python rename_to_uuid.py /path/to/dir .jpg
"""

import argparse
import uuid
import os
from pathlib import Path


def rename_files_to_uuid(directory: Path, extension: str) -> None:
    """Recursively rename files with the given extension to UUIDv4.

    Args:
        directory: Root directory to scan.
        extension: File extension to match (e.g., '.jpg').
    """
    if not extension.startswith("."):
        extension = "." + extension

    for file_path in directory.rglob(f"*{extension}"):
        if file_path.is_file():
            new_name = f"{uuid.uuid4()}{extension}"
            new_path = file_path.with_name(new_name)
            counter = 1
            # Avoid accidental overwrite if UUID happens to exist already
            while new_path.exists():
                new_name = f"{uuid.uuid4()}{extension}"
                new_path = file_path.with_name(new_name)
                counter += 1
            file_path.rename(new_path)


def main() -> None:
    parser = argparse.ArgumentParser(description="Rename files of a given type to UUIDv4.")
    parser.add_argument("directory", type=Path, help="Path to root directory")
    parser.add_argument("extension", type=str, help="File extension (e.g., 'jpg' or '.jpg')")
    args = parser.parse_args()

    if not args.directory.is_dir():
        raise NotADirectoryError(f"{args.directory} is not a valid directory")

    rename_files_to_uuid(args.directory, args.extension)


if __name__ == "__main__":
    main()
