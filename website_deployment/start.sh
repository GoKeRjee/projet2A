#!/bin/bash

# Check if the number of arguments is correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path/to/server.js>  <port>"
    exit 1
fi

# Store the directory name and port from the command-line arguments
directory_name="$1"
port="$2"

# Start the server.js script
node "$directory_name"/server.js & 
sleep 2
firefox http://localhost:$port/

