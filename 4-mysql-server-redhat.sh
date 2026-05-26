#!/bin/bash

# this script exectes in my local linux machine after dns configuration;

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

dnf install mysql-server -y >>$LOG_FILE
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysql >>$LOG_FILE

VALIDATE $? "Enabled MYSQL Server"

systemctl start mysql >>$LOG_FILE
VALIDATE $? "Started MYSQL Server"

# Check root login
mysql -h mysql.daws81.online -u root -pExpenseApp@1 -e 'show databases;' >>$LOG_FILE

if [ $? -ne 0 ]
then
   echo "MySQL root password is not setup, setting now" >>$LOG_FILE
   mysql_secure_installation --set-root-password ExpenseApp@1
   VALIDATE $? "Setting up root password"
else
   echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi