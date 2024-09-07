#!/bin/bash

# Stop all services

source config/config.sh

echo "Stopping server at $(hostname)"

for script in $(find . -name 'stop-*.sh'); do
    bash "$script"
    script_name=$(basename "$script")
    echo "Stopping $script_name"

    logServer "Stopping $script_name"
done

echo "Server stopped"

logServer "Server stopped"