#!/bin/bash

source config/config.sh

PID_FILE="/tmp/sync_repo.pid"
export PID_FILE

set -e
cleanup() {
    rm -f "$PID_FILE"
    exit
}

trap cleanup SIGINT SIGTERM

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null; then
        echo "Script is already running (PID: $PID). Exiting."
        logServer "Script is already running (PID: $PID). Exiting."
        exit 1
    else
        echo "Removing stale PID file."
        logServer "Removing stale PID file."
        rm -f "$PID_FILE"
    fi
fi

echo $$ > "$PID_FILE"

cd "$REPO_DIR_USAGE"

while true; do
    echo "Syncing repositories in: $REPO_DIR_USAGE at $(date)"
    logServer "Syncing repositories in: $REPO_DIR_USAGE"

    REPOS=$(find . -type d -name ".git" -exec dirname {} \;)

    for REPO in $REPOS; do
        echo "Syncing repository: $REPO at $(date)"
        logServer "Syncing repository: $REPO"

        if ! git -C "$REPO" fetch --all --prune; then
            REPO_NAME=$(basename "$REPO")
            MESSAGE="Repo $REPO_NAME failed: git fetch error"
            if [ "$ERROR_NOTIFICATIONS" = true ]; then
                send_alert "$MESSAGE" "$REPO_NAME" "Sync Error"
            fi
            logServer "$MESSAGE"
            continue
        fi

        ERROR_MESSAGES=""
        CHANGES_MADE=false

        for REMOTE_BRANCH in $(git -C "$REPO" branch -r | grep -v '\->'); do
            LOCAL_BRANCH=${REMOTE_BRANCH#origin/}

            if git -C "$REPO" show-ref --verify --quiet refs/heads/$LOCAL_BRANCH; then
                if ! git -C "$REPO" checkout $LOCAL_BRANCH || ! git -C "$REPO" pull --ff-only origin $LOCAL_BRANCH; then
                    ERROR_MESSAGES+="git pull error on branch $LOCAL_BRANCH\n"
                    continue
                else
                    if [ "$(git -C "$REPO" rev-parse HEAD)" != "$(git -C "$REPO" rev-parse @{u})" ]; then
                        CHANGES_MADE=true
                    fi
                fi
            else
                if ! git -C "$REPO" checkout --track $REMOTE_BRANCH || ! git -C "$REPO" pull --ff-only origin $LOCAL_BRANCH; then
                    ERROR_MESSAGES+="git checkout error on branch $LOCAL_BRANCH\n"
                    continue
                else
                    CHANGES_MADE=true
                fi
            fi
        done

        if [ -n "$ERROR_MESSAGES" ]; then
            REPO_NAME=$(basename "$REPO")
            MESSAGE="Repo $REPO_NAME failed:\n$ERROR_MESSAGES"
            if [ "$ERROR_NOTIFICATIONS" = true ]; then
                send_alert "$MESSAGE" "$REPO_NAME" "Sync Error"
            fi
            logServer "$MESSAGE"
        else
            REPO_NAME=$(basename "$REPO")
            if $CHANGES_MADE; then
                MESSAGE="Synced repo $REPO_NAME with changes"
                if [ "$SUCCESS_NOTIFICATIONS" = true ]; then
                    send_alert "$MESSAGE" "$REPO_NAME" "Successfully pulled with changes!"
                fi
                logServer "$MESSAGE"
            else
                MESSAGE="Repo $REPO_NAME is already up to date"
                logServer "$MESSAGE"
            fi
        fi
    done

    echo "Sync complete. 1 minute until next sync..."
    logServer "Sync complete. 1 minute until next sync..."
    sleep $INTERVAL
done