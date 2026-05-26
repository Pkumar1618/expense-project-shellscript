
#!/bin/bash

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

apt install -y curl >> "$LOG_FILE" 2>&1
VALIDATE $? "Installing curl"

curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >> "$LOG_FILE" 2>&1
VALIDATE $? "Adding NodeSource repo"

apt install -y nodejs >> "$LOG_FILE" 2>&1
VALIDATE $? "Installing Node.js"

id expense > /dev/null 2>&1
if [ $? -ne 0 ]; then
    useradd -m expense >> "$LOG_FILE" 2>&1
    VALIDATE $? "Creating expense user"
else
    echo "Expense user already exists ... SKIPPED" | tee -a "$LOG_FILE"
fi

  mkdir -p /app
  VALIDATE $? "Creating /app folder"

  apt install -y unzip &>> "$LOG_FILE"
  VALIDATE $? "Installing unzip"

  curl -f -L -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> "$LOG_FILE"
  VALIDATE $? "Downloading backend application code"

if [ ! -f /tmp/backend.zip ]; then
    echo "backend.zip not found... FAILED" | tee -a "$LOG_FILE"
    exit 1
fi

    cd /app

    unzip -o /tmp/backend.zip &>> "$LOG_FILE"
    VALIDATE $? "Extracting"
    npm install &>>$LOG_FILE
    cp -p /home/prashanth/expense-project-shellscript/backend.services /etc/systemd/system/backend.service

# load the data before backend running


apt install mysql-client -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL Client"

mysql -h 192.168.251.172 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Schema loading"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabled backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarted Backend"