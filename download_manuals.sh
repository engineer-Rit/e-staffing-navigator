#!/bin/bash

# This script downloads all PDF files listed in pdf_download_list.md

# Exit immediately if a command exits with a non-zero status.
set -e

OUTPUT_DIR="manuals_pdf"
INPUT_FILE="pdf_download_list.md"

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

echo "Starting download process..."
echo "Files will be saved in the '$OUTPUT_DIR' directory."
echo "========================================"

# Use grep to find lines containing '.pdf' links.
# Use sed to clean up the line, removing markdown table formatting and backticks,
# and separating the filename and URL with a semicolon.
# The `while read` loop then processes each line.
grep '\.pdf' "$INPUT_FILE" | \
sed -e 's/^[[:space:]]*|[[:space:]]*//' \
    -e 's/[[:space:]]*|[[:space:]]*/;/' \
    -e 's/[[:space:]]*|[[:space:]]*$//' \
    -e 's/`//g' | \
while IFS=';' read -r filename url; do
    # Trim leading/trailing whitespace from filename and URL
    filename=$(echo "$filename" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    url=$(echo "$url" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Proceed only if both filename and URL are non-empty
    if [ -n "$filename" ] && [ -n "$url" ]; then
        echo "Downloading: $filename"

        # Download the file using curl.
        # -L: Follows redirects.
        # -sS: Silent mode but still shows errors.
        # -o: Specifies the output file path.
        # --fail: Makes curl return an error on server errors (like 404).
        if curl -sS -L --fail -o "$OUTPUT_DIR/$filename" "$url"; then
            echo "Successfully saved to $OUTPUT_DIR/$filename"
        else
            echo "Warning: Failed to download '$filename' from '$url'. It might be a broken link."
        fi
        echo "----------------------------------------"
    fi
done

echo "All download tasks finished."
echo "Please check the '$OUTPUT_DIR' directory for the downloaded files."
