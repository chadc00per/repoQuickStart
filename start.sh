source config/config.sh

#source repo-start/repo-start.sh

if validate_json_config; then
    echo "Server started at $(hostname)"
    logServer "Server started at $(hostname)"

    cd ~/repoQuickStart

    # repo-start && \
    bash repo-pullsync/checks.sh && \
    bash repo-pullsync/sync-repos.sh

    echo "Syncing started"
    logServer "Syncing started"
else
    echo "Error: Invalid JSON configuration."
    logServer "Error: Invalid JSON configuration."
    exit 1
fi