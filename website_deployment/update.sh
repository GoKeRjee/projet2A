#!/bin/bash

# Check if the number of arguments is correct
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <path/to/directory> <oldPort> <newPort> <newName>"
  exit 1
fi

# Store the command-line arguments in variables
directory="$1"
old_port="$2"
new_port="$3"
new_name="$4"

# Stop the site using the old port
fuser -k $old_port/tcp

# Modify the port in the server.js file
sed -i "s/$old_port/$new_port/g" "$directory/server.js"

# Escape special characters in the new name
escaped_new_name=$(echo "$new_name" | sed -e 's/[\/&]/\\&/g')

# Modify the title in the template.pug file
sed -i "s/\(^[\t ]*h1#title\).*\$/\1 $escaped_new_name/" "$directory/template.pug"
sed -i "s/\(^[\t ]*title\).*\$/\1 $escaped_new_name/" "$directory/template.pug"

# Start the site with the new port
node "$directory/server.js" &
sleep 2
firefox http://localhost:$new_port/