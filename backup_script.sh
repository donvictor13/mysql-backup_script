
#!/bin/bash                                                                                                                   

# Setting Date variables

date=`/bin/date "+%Y%m%d"`   # Setting date to name the backupfile with todays date
DOW=`date +%A`              # Day of the week, if Sunday?                          
DNOW=`date +%u` # Day number of the week                                           
DOM=`date +%d` # Date of the month                                                 
DOWEEKLY=6                  # Weekly backup to be done on Monday                   

# Local directory where the backupfiles will be temporarily placed

backupdir="/home/sqlbackups"
MYSQL_VAR_D="/var/lib/mysql" 


# Check directories #

if [ ! -e "$BACKUPDIR/daily" ] # Check if Daily Directory exists.
then                                                             
mkdir -p "$BACKUPDIR/daily"                                      
fi                                                               

if [ ! -e "$BACKUPDIR/weekly" ] # Check if Weekly Directory exists.
then                                                               
mkdir -p "$BACKUPDIR/weekly"                                       
fi                                                                 

if [ ! -e "$BACKUPDIR/monthly" ] # Check if Monthly Directory exists.
then                                                                 
mkdir -p "$BACKUPDIR/monthly"                                        
fi                                                                   


# Monthly Full Backup #

if [ $DOM = "01" ]; then

find $backupdir/monthly/* -maxdepth 0 -type f -mtime +50 -exec rm -rf {} \; # Delete last month's backup

mkdir -p "$backupdir/monthly/backup$date/sql";
for i in `mysql -u da_admin -pFqQ7Wvvq7-3F5 -e 'show databases;' | awk {'print $1'}`; do `mysqldump -u da_admin -pFqQ7Wvvq7-3F5 $i > $backupdir/monthly/backup$date/sql/$i.sql`; done
tar -zcf "$backupdir/monthly/backup$date.tgz" "$backupdir/monthly/backup$date";
rm -rf "$backupdir/monthly/backup$date";
exit
fi

# Weekly Backup

if [ $DNOW = $DOWEEKLY ]; then

find $backupdir/weekly/* -maxdepth 0 -type f -mtime +8 -exec rm -rf {} \;   # Delete last weeks backup

mkdir -p "$backupdir/weekly/backup$date";
mkdir -p "$backupdir/weekly/backup$date/sql";

for i in `mysql -u da_admin -pFqQ7Wvvq7-3F5  -e 'show databases;' | awk {'print $1'}`; do `mysqldump -u da_admin -pFqQ7Wvvq7-3F5 $i > $backupdir/weekly/backup$date/sql/$i.sql`; done
tar -zcf "$backupdir/weekly/backup$date.tgz" "$backupdir/weekly/backup$date";
rm -rf "$backupdir/weekly/backup$date";
exit

else

find $backupdir/daily/* -maxdepth 0 -type f -mtime +0 -exec rm -rf {} \;    # Delete backups older than 2 days

mkdir -p "$backupdir/daily/backup$date";
mkdir -p "$backupdir/daily/backup$date/sql";
for i in `mysql -u da_admin -pFqQ7Wvvq7-3F5 -e 'show databases;' | awk {'print $1'}`; do `mysqldump -u da_admin -pFqQ7Wvvq7-3F5 $i > $backupdir/daily/backup$date/sql/$i.sql`; done
tar -zcf "$backupdir/daily/backup$date.tgz" "$backupdir/daily/backup$date";
rm -rf "$backupdir/daily/backup$date";
fi


