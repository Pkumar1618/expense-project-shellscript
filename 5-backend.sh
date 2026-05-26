
#!/bin/bash

# This script is executed on Ubuntu 20.04.6

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

USERID=$(id -u)

mkdir -p "$LOGS_FOLDER"


CHECK_ROOT() {
    if [ "$USERID" -ne 0 ]; then
        echo "Run as root" | tee -a "$LOG_FILE"
        exit 1
    fi
}

VALIDATE() {
    if [ $1 -ne 0 ]; then 
        echo "$2 ... FAILED" | tee -a "$LOG_FILE"
        exit 1
    else
        echo "$2 ... SUCCESS" | tee -a "$LOG_FILE"
    fi
}

echo "Script started at: $(date)" | tee -a "$LOG_FILE"

CHECK_ROOT

apt update -y
VALIDATE $? "Updating packages"

# ✅ Install curl first
apt install -y curl
VALIDATE $? "Installing curl"

# ✅ Add NodeSource repo properly
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
VALIDATE $? "Adding NodeSource repo"

apt install -y nodejs
VALIDATE $? "Installing Node.js"

# ✅ FIX: POSIX compatible redirection (works in sh/bash)
id expense > /dev/null 2>&1
if [ $? -ne 0 ]; then
    useradd -m expense
    VALIDATE $? "Creating expense user"
else
    echo "Expense user already exists ... SKIPPED" | tee -a "$LOG_FILE"
fi

