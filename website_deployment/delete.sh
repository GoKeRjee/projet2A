#!/bin/bash

# Vérifier si un argument a été fourni
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory_to_delete>"
    exit 1
fi

# Récupérer l'argument fourni (le répertoire à supprimer)
directory_to_delete=$1

# Vérifier si le répertoire existe
if [ ! -d "$directory_to_delete" ]; then
    echo "Error: The directory $directory_to_delete does not exist."
    exit 1
fi

# Supprimer le contenu du répertoire spécifié
echo "Deleting the contents of $directory_to_delete..."
rm -r "${directory_to_delete:?}"/*

# Supprimer le répertoire lui-même
echo "Deleting of $directory_to_delete..."
rmdir "${directory_to_delete:?}"

# Vérifier si la suppression a réussi
if [ $? -eq 0 ]; then
    echo "The contents of $directory_to_delete have been successfully deleted."
else
    echo "An error occurred while deleting the contents of $directory_to_delete."
    exit 1
fi
