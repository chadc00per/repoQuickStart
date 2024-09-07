# Configuration file

export REPO_CONFIG_JSON="./config.json"
export REPO_NAME=$(basename "$PWD")
export REPO_DIR=$(jq -r '.saveReposTo' "$REPO_CONFIG_JSON")
export LOG_FILE=$(jq -r '.logFile' "$REPO_CONFIG_JSON")
export INTERVAL=$(jq -r '.syncInterval' "$REPO_CONFIG_JSON")
export ERROR_NOTIFICATIONS=$(jq -r '.ERROR_NOTIFICATIONS' "$REPO_CONFIG_JSON")
export SUCCESS_NOTIFICATIONS=$(jq -r '.SUCCESS_NOTIFICATIONS' "$REPO_CONFIG_JSON")
export LOGGING_ENABLED=$(jq -r '.LOGGING_ENABLED' "$REPO_CONFIG_JSON")
export SYSTEM_TYPE=$(jq -r '.systemType' "$REPO_CONFIG_JSON")
export REPO_DIR_USAGE="$(cd ~/$REPO_DIR && pwd)"

logServer() {
    local message="$1"
    if [ "$LOGGING_ENABLED" = true ]; then
        echo "$(date): $message" >> "$LOG_FILE"
    fi
}

export -f logServer

set_nginx_config_dir() {
    local SYSTEM_TYPE="$SYSTEM_TYPE"

    if [ "$SYSTEM_TYPE" = "mac" ]; then
        NGINX_CONFIG_DIR="/opt/homebrew/etc/nginx/"
    else
        NGINX_CONFIG_DIR="/usr/local/etc/nginx/"
    fi

    export NGINX_CONFIG_DIR
}

export -f set_nginx_config_dir

validate_json_config() {
    local json_file="$REPO_CONFIG_JSON"
    if [[ ! -f "$json_file" ]]; then
        echo "Error: $json_file not found"
        return 1
    fi

    if ! jq empty "$json_file" >/dev/null 2>&1; then
        echo "Error: $json_file is not a valid JSON file"
        return 1
    fi

    local save_repos_to=$(jq -r '.saveReposTo' "$json_file")
    if [[ -z "$save_repos_to" || "$save_repos_to" == "/" ]]; then
        echo "Error: saveReposTo cannot be blank or /"
        return 1
    fi

    return 0
}

export -f validate_json_config

send_alert() {
    local message="$1"
    local repo_name="$2"
    local subtitle="$3"
    if [ "$SYSTEM_TYPE" = "mac" ]; then
        osascript -e 'display notification "'"$message"'" with title "Repo: '"$repo_name"'" subtitle "'"$subtitle"'"'
    fi
}

export -f send_alert
