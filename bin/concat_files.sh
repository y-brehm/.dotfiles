#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <root_directory> <file_extension> <output_file>"
    exit 1
fi

ROOT_DIR="$1"
FILE_EXT="$2"
OUTPUT_FILE="$3"

# Ensure the root directory exists
if [ ! -d "$ROOT_DIR" ]; then
    echo "Error: Root directory '$ROOT_DIR' not found."
    exit 1
fi

# Remove the output file if it already exists to start fresh
if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE"
fi

# Find files and process them
# The '-print0' and 'while IFS= read -r -d $'\0'' construct is a safe way
# to handle filenames that might contain spaces or newlines.
find "$ROOT_DIR" -type f -name "*.$FILE_EXT" -print0 | while IFS= read -r -d $'\0' file; do
    # Append the filename to the output file
    echo "File: $file" >> "$OUTPUT_FILE"
    # Append an empty line
    echo "" >> "$OUTPUT_FILE"
    # Append the content of the file
    cat "$file" >> "$OUTPUT_FILE"
    # Append an extra newline for separation after the content, if desired
    echo "" >> "$OUTPUT_FILE"
done

echo "Concatenation complete. Output saved to '$OUTPUT_FILE'"
