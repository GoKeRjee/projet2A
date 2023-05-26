#!/bin/bash

# Check if an argument has been supplied
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory_to_delete>"
    exit 1
fi

# Retrieve the supplied argument (the directory to be deleted)
directory_to_delete=$1

# Check if the directory exists
if [ ! -d "$directory_to_delete" ]; then
    echo "Error: The directory $directory_to_delete does not exist."
    exit 1
fi

# Delete the contents of the specified directory
echo "Deleting the contents of $directory_to_delete..."
rm -r "${directory_to_delete:?}"/*

# Delete the directory itself
echo "Deleting of $directory_to_delete..."
rmdir "${directory_to_delete:?}"

# Check if the deletion was successful
if [ $? -eq 0 ]; then
    echo "The contents of $directory_to_delete have been successfully deleted."
else
    echo "An error occurred while deleting the contents of $directory_to_delete."
    exit 1
fi