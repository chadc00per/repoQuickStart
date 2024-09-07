#!/bin/bash

## This script will load your modified nginx config in this repo to the nginx.conf file on server

source config/config.sh

# Generate the nginx config and print its output to nginx.conf
nginx/nginx-conf.sh > $NGINX_CONFIG_DIR/nginx.conf

# Verify the config
nginx -t

# Reload nginx
sudo nginx -s reload

# Print the new config to the console
cat $NGINX_CONFIG_DIR/nginx.conf