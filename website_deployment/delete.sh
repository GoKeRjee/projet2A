#!/bin/bash

# Vérifier si un argument a été fourni
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <répertoire_à_supprimer>"
    exit 1
fi

# Récupérer l'argument fourni (le répertoire à supprimer)
repertoire_a_supprimer=$1

# Vérifier si le répertoire existe
if [ ! -d "$repertoire_a_supprimer" ]; then
    echo "Erreur: Le répertoire $repertoire_a_supprimer n'existe pas."
    exit 1
fi

# Supprimer le contenu du répertoire spécifié
echo "Suppression du contenu de $repertoire_a_supprimer..."
rm -r "${repertoire_a_supprimer:?}"/*

# Supprimer le répertoire lui-même
echo "Suppression de $repertoire_a_supprimer..."
rmdir "${repertoire_a_supprimer:?}"

# Vérifier si la suppression a réussi
if [ $? -eq 0 ]; then
    echo "Le contenu de $repertoire_a_supprimer a été supprimé avec succès."
else
    echo "Une erreur s'est produite lors de la suppression du contenu de $repertoire_a_supprimer."
    exit 1
fi
