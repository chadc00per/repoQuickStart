# Configuration file

# The folder where repositories are stored, relative to the home directory
# Cannot be your home directory.
REPO_DIR="test"

# The log file name
LOG_FILE="serverlog.log"

# The interval between checks in seconds
INTERVAL=10  # 10 seconds

# Alert on errors?
ERROR_NOTIFICATIONS=true

# Alert on success?
SUCCESS_NOTIFICATIONS=false

# Record logging of this app?
LOGGING_ENABLED=true

export REPO_DIR LOG_FILE INTERVAL ERROR_NOTIFICATIONS SUCCESS_NOTIFICATIONS LOGGING_ENABLED