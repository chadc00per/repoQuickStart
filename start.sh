source config.sh
echo "Server started at $(hostname)"

if [ "$LOGGING_ENABLED" = true ]; then
    echo "$(date): Server started at $(hostname)" >> "$LOG_FILE"
fi

cd ~/repoQuickStart

bash repo-start/repo-start.sh & \
bash repo-pullsync/sync-repos.sh

echo "Syncing started"

if [ "$LOGGING_ENABLED" = true ]; then
    echo "$(date): Syncing started" >> "$LOG_FILE"
fi