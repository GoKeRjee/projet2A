#!/bin/bash

# Check if the command-line argument for port is provided
if [ -z "$1" ]
then
  echo "Usage: $0 <port>"
  exit 1
fi

# Store the port value from the command-line argument
port="$1"

# Find and kill the process running on the specified port
pid=$(fuser -n tcp -k $port 2> /dev/null)

# Check if the process has been found and killed
if [ -n "$pid" ]
then
  echo "Process stopped successfully (PID: $pid)"
else
  echo "No processes running on the port $port"
fi