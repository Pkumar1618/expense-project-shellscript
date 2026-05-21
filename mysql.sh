LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

mkdir -p "$LOGS_FOLDER"

CHECK_ROOT() {
    if [ "$USERID" -ne 0 ]; then
        echo -e "$R Please run this script with root privileges $N" | tee -a "$LOG_FILE"
        exit 1
    fi
}

VALIDATE() {
    if [ $1 -ne 0 ]; then 
        echo -e "$2 ... $R FAILED $N" | tee -a "$LOG_FILE" # tee command using for write logs on terminal and log file both 
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a "$LOG_FILE"
    fi
}

echo "Script started executing at: $(date)" &>>$LOG_FILE

CHECK_ROOT

apt update

apt install mysql-server -y
VALIDATE $? "Installing MYSQL Server"

systemctl enabled mysqld
VALIDATE $? "Enables MYSQL Server"

systemctl start mysqld
VALIDATE $? "started MYSQL Server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "setting up root password"
