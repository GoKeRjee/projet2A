#!/bin/bash

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <path/to/directory> <oldPort> <newPort> <newName>"
  exit 1
fi

directory="$1"
old_port="$2"
new_port="$3"
new_name="$4"

# Arrêter le site qui utilise l'ancien port
fuser -k $old_port/tcp

# Modifier le port dans le fichier server.js
sed -i "s/$old_port/$new_port/g" "$directory/server.js"

# Échapper les caractères spéciaux dans le nouveau titre
escaped_new_name=$(echo "$new_name" | sed -e 's/[\/&]/\\&/g')

# Modifier le titre dans le fichier template.pug
sed -i "s/\(^[\t ]*h1#title\).*\$/\1 $escaped_new_name/" "$directory/template.pug"

# Démarrer le site avec le nouveau port
node "$directory/server.js" &
sleep 2
google-chrome http://localhost:$new_port/
