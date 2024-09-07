#!/bin/bash

source config/config.sh

# Reset the nginx config to the default
sudo cp nginx/default.conf $NGINX_CONFIG_DIR/nginx.conf

# Verify the config
nginx -t

# Reload nginx
sudo nginx -s reload

# Print the new config to the console
cat $NGINX_CONFIG_DIR/nginx.conf