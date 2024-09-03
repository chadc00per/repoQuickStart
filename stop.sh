#!/bin/bash

# Stop all services

source config.sh
echo "Stopping server at $(hostname)"

for script in $(find . -name 'stop-*.sh'); do
    bash "$script"
    script_name=$(basename "$script")
    echo "Stopping $script_name"

    if [ "$LOGGING_ENABLED" = true ]; then
        echo "$(date): Stopping $script_name" >> "$LOG_FILE"
    fi
done

echo "Server stopped"

if [ "$LOGGING_ENABLED" = true ]; then
    echo "$(date): Server stopped" >> "$LOG_FILE"
fi