#!/usr/bin/env python3
"""
Script to rename files using UUID4 from a CSV file with thread safety.
Processes files in parallel using 4 threads with proper synchronization.
"""

import os
import csv
import uuid
import threading
from concurrent.futures import ThreadPoolExecutor
import sys


class FileRenamer:
    def __init__(self, csv_file, num_threads=4):
        self.csv_file = csv_file
        self.num_threads = num_threads
        self.lock = threading.Lock()
        self.updated_rows = []

    def generate_uuid_filename(self, original_path):
        """Generate a new filename with UUID4 and preserve directory structure and extension."""
        directory = os.path.dirname(original_path)
        # Get the original file extension
        _, extension = os.path.splitext(original_path)
        # Generate UUID4 without hyphens for cleaner filenames
        new_uuid = uuid.uuid4().hex
        # Keep the original extension
        new_filename = f"{new_uuid}{extension}"
        return os.path.join(directory, new_filename)

    def rename_file(self, row_data):
        """Rename a single file and return updated row data."""
        original_path, mpp = row_data

        try:
            # Check if original file exists
            if not os.path.exists(original_path):
                print(f"Warning: File not found: {original_path}")
                return None

            # Generate new path with UUID
            new_path = self.generate_uuid_filename(original_path)

            # Ensure target directory exists
            os.makedirs(os.path.dirname(new_path), exist_ok=True)

            # Rename the file
            os.rename(original_path, new_path)

            print(f"Renamed: {os.path.basename(original_path)} -> {os.path.basename(new_path)}")

            # Return updated row data
            return [new_path, mpp]

        except OSError as e:
            print(f"Error renaming {original_path}: {e}")
            return None
        except Exception as e:
            print(f"Unexpected error with {original_path}: {e}")
            return None

    def worker_thread(self, row_data):
        """Worker function for thread pool."""
        result = self.rename_file(row_data)

        if result:
            # Thread-safe update of results
            with self.lock:
                self.updated_rows.append(result)

    def process_csv(self):
        """Read CSV, process files with threading, and update CSV."""
        print(f"Starting file renaming process with {self.num_threads} threads...")

        # Read the CSV file
        try:
            with open(self.csv_file, 'r', newline='', encoding='utf-8') as file:
                reader = csv.reader(file)
                header = next(reader)  # Read header row
                rows = list(reader)
        except FileNotFoundError:
            print(f"Error: CSV file '{self.csv_file}' not found.")
            return False
        except Exception as e:
            print(f"Error reading CSV file: {e}")
            return False

        if not rows:
            print("No data rows found in CSV file.")
            return False

        print(f"Found {len(rows)} files to process...")

        # Process files using thread pool
        with ThreadPoolExecutor(max_workers=self.num_threads) as executor:
            # Submit all tasks
            futures = [executor.submit(self.worker_thread, row) for row in rows]

            # Wait for all tasks to complete
            for future in futures:
                try:
                    future.result()  # This will raise any exceptions that occurred
                except Exception as e:
                    print(f"Thread execution error: {e}")

        # Sort updated rows to maintain some order (optional)
        self.updated_rows.sort(key=lambda x: x[0])

        # Write updated CSV
        try:
            with open(self.csv_file, 'w', newline='', encoding='utf-8') as file:
                writer = csv.writer(file)
                writer.writerow(header)  # Write header
                writer.writerows(self.updated_rows)  # Write updated rows

            print(f"Successfully updated CSV file with {len(self.updated_rows)} renamed files.")
            return True

        except Exception as e:
            print(f"Error writing updated CSV file: {e}")
            return False


def main():
    # Default CSV filename - can be modified as needed
    csv_filename = "list_of_files.csv"

    # Check if CSV file is provided as command line argument
    if len(sys.argv) > 1:
        csv_filename = sys.argv[1]

    print(f"Using CSV file: {csv_filename}")

    # Create renamer instance
    renamer = FileRenamer(csv_filename, num_threads=4)

    # Process the files
    success = renamer.process_csv()

    if success:
        print("File renaming completed successfully!")
    else:
        print("File renaming completed with errors.")
        sys.exit(1)


if __name__ == "__main__":
    main()
