#!/bin/bash

# Script to find and list files within a specified directory.
# Allows user to specify a positive size.

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Function to print the results in a human-readable format with colors
print_results() {
    echo -e "${GREEN}Files larger than $size in directory ${YELLOW}$directory${GREEN}:${NC}"
    printf "${ORANGE}%-10s | %-70s | %-10s${NC}\n" "Size" "File" "Owner"
    printf "${ORANGE}%-10s | %-70s | %-10s${NC}\n" "----------" "----------------------------------------------------------------------" "----------"
    local count=0
    while IFS= read -r line; do
        filesize=$(echo "$line" | cut -f1)
        filename=$(echo "$line" | cut -f2-)
        fileowner=$(stat -c '%U' "$filename")
        printf "${YELLOW}%-10s ${ORANGE}| ${NC}%-70s ${ORANGE}| ${RED}%-10s${NC}\n" "$filesize" "$filename" "$fileowner"
        ((count++))
    done <<< "$1"
    echo -e "\n${GREEN}Search complete. Total files found: ${YELLOW}$count${NC}"
}

# Prompt user for directory and size
read -rp $'Enter the directory path to search in (Ex: /home): ' directory
read -rp $'Enter the minimum file size to search for (Ex: 20M, 1G): ' size

# Ensure the directory exists
if [ ! -d "$directory" ]; then
    echo -e "${RED}The directory $directory does not exist.${NC}"
    exit 1
fi

# Execute the search
result=$(find "$directory" -type f -size +"$size" -exec du -h {} + 2>/dev/null | sort -hr)

# Check if the result is empty
if [ -z "$result" ]; then
    echo -e "${RED}No files larger than $size found in directory $directory.${NC}"
else
    print_results "$result"
fi
