#!/bin/bash

source repo-pullsync/sync-repos.sh
source config/config.sh

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null; then
        echo "Stopping repository sync script using (PID: $PID)..."
        logServer "Stopping repository sync script using (PID: $PID)..."
        kill $PID
        rm -f "$PID_FILE"
        echo "Repository sync stopped."
        logServer "Repository sync stopped."
    else
        echo "Error: Process with PID $PID is not running. Removing stale PID file."
        logServer "Error: Process with PID $PID is not running. Removing stale PID file."
        rm -f "$PID_FILE"
    fi
else
    echo "Error: sync is not running."
    logServer "Error: sync is not running."
fi