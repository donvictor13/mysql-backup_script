#!/bin/bash

# Check disk usage
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "70" ]; then
    echo "Disk usage is above 70%. Backup script will not run."
    exit 1
fi

# Remove previous day's backup
yesterday=$(date -d "yesterday" '+%Y%m%d')
rm -f "$backupdir/daily/backup$yesterday.tgz"

# Set log file names
LOG_FILE="/tmp/mysql-bakp.log"
REPORT_FILE="/tmp/mysql-bakpreport.txt"
DETAIL_FILE="/tmp/mysql-bakpdetail.txt"
BACKUP_REPORT="/tmp/backup_report.txt"

# Clear log files
> "$LOG_FILE"
> "$REPORT_FILE"
> "$DETAIL_FILE"
> "$BACKUP_REPORT"

# Set date variables
date=$(date "+%Y%m%d")
DOW=$(date "+%A")
DNOW=$(date "+%u")
DOM=$(date "+%d")

# Set backup directory
BACKUPDIR="/home/DBBACKUPS"
backupdir="/home/DBBACKUPS"
MYSQL_VAR_D="/var/lib/mysql"

# Check directories
if [ ! -e "$BACKUPDIR/daily" ]; then
    mkdir -p "$BACKUPDIR/daily"
fi

# Daily backup
find "$backupdir/daily/*" -maxdepth 0 -type f -mtime +15 -exec rm -rf {} \; # Delete backups older than 1 week

mkdir -p "$backupdir/daily/backup$date"
mkdir -p "$backupdir/daily/backup$date/sql"

for i in $(mysql -e "show databases" | awk '{print $1}' | grep -v Database); do
    mysqldump "$i" > "$backupdir/daily/backup$date/sql/$i.sql"
done

SUBJECT="Daily Backup Report : $date"
ls -al "$backupdir/daily/backup$date/sql/" | awk -v size="0" '$5 == size {print $5" "$9}' | sort -t' ' -k1,1nr > "$REPORT_FILE"
ls -al "$backupdir/daily/backup$date/sql/" | grep .sql | awk '{print $5, $9}' > "$DETAIL_FILE"
tar -zcf "$backupdir/daily/backup$date.tgz" "$backupdir/daily/backup$date"
rm -rf "$backupdir/daily/backup$date"

exit 0
