#!/bin/bash

# thsi script executed my local ubuntu linux machine

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

USERID=$(id -u)

mkdir -p "$LOGS_FOLDER"

CHECK_ROOT() {
    if [ "$USERID" -ne 0 ]; then
        echo "Please run this script with root privileges" | tee -a "$LOG_FILE"
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

apt update >>"$LOG_FILE" 2>&1

apt install mysql-server -y >>"$LOG_FILE" 2>&1
VALIDATE $? "Installing MySQL Server"


systemctl enable mysql >>"$LOG_FILE" 2>&1
VALIDATE $? "Enabling MySQL Server"

systemctl start mysql >>"$LOG_FILE" 2>&1
VALIDATE $? "Starting MySQL Server"

# Set root password
mysql -u root <<EOF >>"$LOG_FILE" 2>&1
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ExpenseApp@1';
FLUSH PRIVILEGES;
EOF

VALIDATE $? "Setting root password"
