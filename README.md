# Repo Quick Start
## Overview
This will automatically configure & run an Nginx server & keep it up to date with remote repositories.

## Installation
Open Terminal and run the following command:
```sh
cd ~/Desktop && \
git clone https://github.com/chadc00per/repoQuickStart.git && sleep 2 && \
cp ~/Desktop/repoQuickStart/run.command ~/Desktop/repoQuickStart.command && sleep 1 && \
chmod +x ~/Desktop/repoQuickStart.command
```
#### Install Nginx:
- Mac: `brew install nginx`
- Linux: `sudo apt install nginx`

## Usage
Double click the `repoQuickStart.command` file to run!

#### Auto start Nginx at login
- Mac: `brew services start nginx`
- Linux: `sudo systemctl enable nginx`

###### If you want to change this later & prevent auto start at login
- Mac: `brew services stop nginx`
- Linux: `sudo systemctl disable nginx`

#### Restart Nginx
- Mac: `brew services restart nginx`
- Linux: `sudo systemctl restart nginx`

#### Manually run Nginx
Start: `sudo nginx`
Stop: `sudo nginx -s stop`

#### Check Nginx status
- Linux: `sudo systemctl status nginx`
- Mac: `brew services list`

#### Nginx Configuration
 - Load JSON configuration manually: `./nginx/load-config.sh`
 - Reload config: `sudo nginx -s reload`
 - Reset config to default: `./nginx/reset-config-default.sh`
 - Verify config: `nginx -t`

###### Known Issues
- Only tested on Mac M1/M3