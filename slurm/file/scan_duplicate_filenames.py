#!/usr/bin/env python3
"""
Scan a directory for duplicate filenames.

Usage:
    python scan_duplicates.py /path/to/dir
"""

import argparse
import os
from collections import Counter
from typing import Dict, List


def scan_for_duplicate_filenames(directory: str) -> Dict[str, List[str]]:
    """Scan a directory recursively for duplicate filenames.

    Args:
        directory (str): Path to the directory to scan.

    Returns:
        Dict[str, List[str]]: Mapping from filename to list of full paths for duplicates.
    """
    filename_map: Dict[str, List[str]] = {}
    for root, _, files in os.walk(directory):
        for fname in files:
            filename_map.setdefault(fname, []).append(os.path.join(root, fname))

    duplicates = {fname: paths for fname, paths in filename_map.items() if len(paths) > 1}
    return duplicates


def main() -> None:
    """Parse arguments and run duplicate scan."""
    parser = argparse.ArgumentParser(description="Scan directory for duplicate filenames.")
    parser.add_argument("directory", type=str, help="Path to directory to scan")
    args = parser.parse_args()

    if not os.path.isdir(args.directory):
        raise NotADirectoryError(f"Path does not exist or is not a directory: {args.directory}")

    duplicates = scan_for_duplicate_filenames(args.directory)

    if duplicates:
        print("Found duplicate filenames:")
        for fname, paths in duplicates.items():
            print(f"\nFilename: {fname}")
            for path in paths:
                print(f"  {path}")
    else:
        print("No duplicate filenames found.")


if __name__ == "__main__":
    main()
