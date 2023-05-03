#!/bin/bash

if [ -z "$1" ]
then
  echo "Usage: $0 <port>"
  exit 1
fi

port="$1"

pid=$(fuser -n tcp -k $port 2> /dev/null)

if [ -n "$pid" ]
then
  echo "Processus arrêté avec succès (PID : $pid)"
else
  echo "Aucun processus en cours d'exécution sur le port $port"
fi