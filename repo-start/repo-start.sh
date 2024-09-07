#!/bin/bash

## Get REPO DIR & CONFIG FILE
source config/config.sh
source config/logging.sh

REPO_DIR_USAGE="$(cd ~/$REPO_DIR && pwd)"
repo-start() {
    REPOS=$(find $REPO_DIR_USAGE -type d -name ".git" \
        -not -path "$REPO_DIR_USAGE/Library/*" \
        -not -path "$REPO_DIR_USAGE/Application Support/*" \
        -not -path "$REPO_DIR_USAGE/.DS_Store/*" \
        -exec dirname {} \; | xargs -I {} stat -f "%m %N" {} | sort -nr | cut -d' ' -f2-)

    REPO_LIST=""
    for REPO in $REPOS; do
        REPO_LIST+="$REPO\n"
    done

    REPO_NAME=$(basename "$REPO_DIR_USAGE")
    SELECTED_REPO=$(osascript -e 'try
        tell app "System Events"
            set repoList to "'"$REPO_LIST"'"
            set repoArray to paragraphs of repoList
            set selectedRepo to choose from list repoArray with title "Run Repository" with prompt "Select a repository:" default items {""} cancel button name "Cancel" OK button name "OK"
            if selectedRepo is false then error number -128
            return item 1 of selectedRepo
        end tell
    on error number -128
        return
    end try')

    if [ -n "$SELECTED_REPO" ]; then
        logServer "Selected repository: $SELECTED_REPO"
        PACKAGE_JSON_PATH="$SELECTED_REPO/package.json"
        if [ -f "$PACKAGE_JSON_PATH" ]; then
            SCRIPTS=$(jq -r '.scripts | to_entries | map("\(.key): \(.value)") | .[]' "$PACKAGE_JSON_PATH")
            RELATIVE_REPO_PATH="${SELECTED_REPO/#$HOME/~}"
            SELECTED_SCRIPT=$(osascript -e 'try
                tell app "System Events"
                    set scriptList to "'"$SCRIPTS"'"
                    set scriptArray to paragraphs of scriptList
                    set selectedScript to choose from list scriptArray with title "Run Repository" with prompt "Choose a script from '"$RELATIVE_REPO_PATH"' to run:" default items {""} cancel button name "Cancel" OK button name "OK"
                    if selectedScript is false then error number -128
                    return item 1 of selectedScript
                end tell
            on error number -128
                return
            end try')
            if [ -n "$SELECTED_SCRIPT" ]; then
                SCRIPT_NAME=$(echo "$SELECTED_SCRIPT" | cut -d':' -f1)
                logServer "Selected script: $SCRIPT_NAME"
                osascript -e 'tell application "Terminal"
                    do script "cd '"$SELECTED_REPO"' && npm run '"$SCRIPT_NAME"'"
                    activate
                end tell'
            fi
        else
            osascript -e 'tell app "System Events" to display dialog "No package.json found in '"$SELECTED_REPO"'" buttons {"OK"} default button "OK"'
            logServer "No package.json found in $SELECTED_REPO"
        fi
    fi
}

export -f repo-start