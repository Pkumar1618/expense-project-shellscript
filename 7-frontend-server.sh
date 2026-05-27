
#!/bin/bash

# This script is for Ubuntu Linux frontend setup

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


apt update -y >> "$LOG_FILE" 2>&1
VALIDATE $? "Updating packages"

apt install nginx -y >> "$LOG_FILE" 2>&1
VALIDATE $? "Installing Nginx"

systemctl enable nginx >> "$LOG_FILE" 2>&1
VALIDATE $? "Enable Nginx"

rm -rf /usr/share/nginx/html/* >> "$LOG_FILE" 2>&1
VALIDATE $? "Removing default website"

apt install -y curl >> "$LOG_FILE" 2>&1
VALIDATE $? "Installing curl"

apt install -y unzip >> "$LOG_FILE" 2>&1
VALIDATE $? "Installing unzip"


curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip >> "$LOG_FILE" 2>&1
VALIDATE $? "Downloading frontend code"

if [ ! -f /tmp/frontend.zip ]; then
    echo "frontend.zip not found... FAILED" | tee -a "$LOG_FILE"
    exit 1
fi

cd /usr/share/nginx/html || exit

unzip -o /tmp/frontend.zip >> "$LOG_FILE" 2>&1
VALIDATE $? "Extract frontend code"

cp -p /home/prashanth/expense-project-shellscript/expense.conf /etc/nginx/default.d/expense.conf >> "$LOG_FILE" 2>&1
VALIDATE $? "Copied expense config"

systemctl restart nginx >> "$LOG_FILE" 2>&1

