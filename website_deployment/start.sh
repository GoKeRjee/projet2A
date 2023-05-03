#!/bin/bash

# Vérifier si le nombre d'arguments est correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path/to/server.js>  <port>"
    exit 1
fi

directory_name="$1"
port="$2"

node "$directory_name"/server.js & 
sleep 2
google-chrome http://localhost:$port/

