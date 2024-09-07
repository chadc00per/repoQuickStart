#!/bin/bash

# Get config file 
source config/config.sh

read_config_json() {
    local json_file="$1"
    if [[ ! -f "$json_file" ]]; then
        echo "Error: $json_file not found"
        exit 1
    fi
    jq -r '.repositories | to_entries[] | "\(.key) \(.value)"' "$json_file"
}

get_error_log_file() {
    if [[ -z "$LOG_FILE" ]]; then
        echo "Error: LOG_FILE is not set in the config"
        exit 1
    fi
    echo "$LOG_FILE"
}

generate_nginx_locations() {
    local repos="$1"
    while read -r repo_name repo_path; do
        echo "location /$repo_name/ {"
        echo "    alias /$repo_path;"
        echo "    try_files \$uri \$uri/ =404;"
        echo "}"
        echo ""
    done <<< "$repos"
}

generate_error_page() {
    cat <<EOF
error_page   500 502 503 504  /50x.html;
location = /50x.html {
    root /Users/chad/repoQuickStart/public;
}
EOF
}

generate_nginx_server() {
    local repos="$1"
    local server_name="$2"
    local port="$3"
    echo "server {"
    echo "    listen $port;"
    echo "    server_name $server_name;"
    generate_root_location "$REPO_CONFIG_JSON"
    generate_nginx_locations "$repos"
    generate_error_page
    echo "}"
}

generate_root_location() {
    local json_file="$1"
    local root_path=$(jq -r '.root["/"]' "$json_file")
    cat <<EOF
location / {
    root $root_path;
    index index.html index.htm;
}
EOF
}

generate_nginx_conf() {
    local repos="$1"
    local server_name="$2"
    local port="$3"
    local error_log_file=$(get_error_log_file)
    cat <<EOF
#user  nobody;
worker_processes  1;

#error_log  $error_log_file;
#error_log  $error_log_file  notice;
#error_log  $error_log_file  info;

#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    #                  '\$status \$body_bytes_sent "\$http_referer" '
    #                  '"\$http_user_agent" "\$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    gzip  on;
    gzip_min_length 1000;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    $(generate_nginx_server "$repos" "$server_name" "$port")

    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
    include servers/*;
}
EOF
}

# Main script
NGINX_CONF=$(generate_nginx_conf "$(read_config_json "$REPO_CONFIG_JSON")" "$(jq -r '.serverName' "$REPO_CONFIG_JSON")" "$(jq -r '.port' "$REPO_CONFIG_JSON")")
echo "$NGINX_CONF"
export NGINX_CONF