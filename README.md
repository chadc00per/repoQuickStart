# Repo Sync
This program will automatically pull remote repositories & sync them to local. It will also quick start a selected repository.

# Installation
## Open Terminal and run the following command:
```sh
cd ~/Desktop && \
git clone https://github.com/chadc00per/repoQuickStart.git && sleep 2 && \
cp ~/Desktop/repoQuickStart/run.command ~/Desktop/repoQuickStart.command && sleep 1 && \
chmod +x ~/Desktop/repoQuickStart.command
```

# Usage
Double click the `repoQuickStart.command` file to run!

# Known Issues
- Only tested on Mac M1/M3

# Nginx Server

## Running nginx

### Install
- Mac: `brew install nginx`
- Linux: `sudo apt install nginx`

### Auto start at login
- Mac: `brew services start nginx`
- Linux: `sudo systemctl enable nginx`

### If you want to change this later & prevent auto start at login
- Mac: `brew services stop nginx`
- Linux: `sudo systemctl disable nginx`

### Restart nginx
- Mac: `brew services restart nginx`
- Linux: `sudo systemctl restart nginx`

### Manually run
Start: `sudo nginx`
Stop: `sudo nginx -s stop`

### Check status
- Linux: `sudo systemctl status nginx`
- Mac: `brew services list`

## Configuration
*Edit the `config.json` & the `config.sh` files*
### Load configuration: `./nginx/load-config.sh`
 - Reload config: `sudo nginx -s reload`
 - Reset config to default: `./nginx/reset-config-default.sh`
 - Verify config: `nginx -t`