#!/bin/bash

# Get config file
source config/config.sh

check_repositories() {
    # Read repositories from the JSON configuration file
    REPOSITORIES=$(jq -r '.repositories | to_entries | map("\(.key): \(.value)") | .[]' "$REPO_CONFIG_JSON")

    # Read the saveReposTo value from the JSON configuration file
    SAVE_REPOS_TO=$(jq -r '.saveReposTo' "$REPO_CONFIG_JSON")

    # Check the path of the saveReposTo folder (my home directory)
    SAVE_REPOS_TO_PATH="$(cd ~/$SAVE_REPOS_TO && pwd)"

    FOUND_REPOS=()
    NOT_FOUND_REPOS=()

    # Check if repository values match directories inside the save repos to path
    for REPO in $(jq -r '.repositories | to_entries | map("\(.value)") | .[]' "$REPO_CONFIG_JSON"); do
        if [ -d "$SAVE_REPOS_TO_PATH/$REPO" ]; then
            FOUND_REPOS+=("$REPO")
        else
            NOT_FOUND_REPOS+=("$REPO")
        fi
    done

    # Create JSON output
    JSON_OUTPUT=$(jq -n \
        --argjson found "$(printf '%s\n' "${FOUND_REPOS[@]}" | jq -R . | jq -s 'map({key: ., value: .}) | from_entries')" \
        --argjson notFound "$(printf '%s\n' "${NOT_FOUND_REPOS[@]}" | jq -R . | jq -s 'map({key: ., value: .}) | from_entries')" \
        '{found: $found, notFound: $notFound}')

    echo "$JSON_OUTPUT"
}

export -f check_repositories


download_not_found_repos() {

    # Read the saveReposTo value from the JSON configuration file
    SAVE_REPOS_TO=$(jq -r '.saveReposTo' "$REPO_CONFIG_JSON")

    # Check the path of the saveReposTo folder (my home directory)
    SAVE_REPOS_TO_PATH="$(cd ~/$SAVE_REPOS_TO && pwd)"

    # Get the GitHub username from git config user.email
    GITHUB_USERNAME=$(git config user.name | cut -d'@' -f1)

    # Read the JSON configuration file
    NOT_FOUND_REPOS=$(jq -r --arg username "$GITHUB_USERNAME" '.notFound | to_entries | map("https://github.com/\($username)/\(.value // empty).git") | .[]' <<< "$JSON_OUTPUT")

    # Clone each not found repository to the save repos to path
    for REPO_URL in $NOT_FOUND_REPOS; do
        REPO_NAME=$(basename "$REPO_URL" .git)
        if [ ! -d "$SAVE_REPOS_TO_PATH/$REPO_NAME" ]; then
            git clone "$REPO_URL" "$SAVE_REPOS_TO_PATH/$REPO_NAME"
        fi
    done
}

# Generate the JSON_OUTPUT by calling check_repositories function
JSON_OUTPUT=$(check_repositories)

download_not_found_repos

export -f download_not_found_repos