#!/bin/bash

# This script is executed on Redhat using aws cloud;

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

echo "Script started executing at: $(date)">>$LOG_FILE

CHECK_ROOT

dnf module disabled nodejs -y
VALIDATE $? "Disable default nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y
VALIDATE $? "Install nodejs"

useradd expense
VALIDATE $? "Creating expense user"