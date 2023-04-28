#!/bin/bash

# Vérifier si le nombre d'arguments est correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path/to/server.js> <start|stop>"
    exit 1
fi

# Récupérer les arguments
fichier_server=$1
action=$2

# Vérifier si le fichier server.js existe
if [ ! -f "$fichier_server" ]; then
    echo "Erreur: Le fichier $fichier_server n'existe pas."
    exit 1
fi

# Récupérer le répertoire du fichier server.js
repertoire_server=$(dirname "$fichier_server")

# Créer un fichier pour stocker le PID du processus
pid_file="$repertoire_server/node_server.pid"

# Exécuter l'action demandée
case $action in
    start)
        echo "Démarrage du serveur Node.js..."
        cd "$repertoire_server"
        nohup node "$(basename "$fichier_server")" > /dev/null 2>&1 &
        echo $! > "$pid_file"
        echo "Serveur Node.js démarré avec succès."
        ;;
    stop)
        if [ ! -f "$pid_file" ]; then
            echo "Erreur: Le fichier PID n'existe pas. Le serveur n'a peut-être pas été démarré avec ce script."
            exit 1
        fi
        echo "Arrêt du serveur Node.js..."
        kill "$(cat "$pid_file")"
        rm "$pid_file"
        echo "Serveur Node.js arrêté avec succès."
        ;;
    *)
        echo "Action invalide. Les actions valides sont 'start' ou 'stop'."
        exit 1
        ;;
esac
