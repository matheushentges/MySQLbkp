#!/bin/bash
backup_path="/root"
create_backup() {
  umask 177
  FILE="$db_name-$d.sql.gz"
  mysqldump --user=$user --password=$password --host=$host $db_name | gzip --best > $FILE

  echo 'Backup concluido com sucesso'
}

clean_backup() {
  rm -f $backup_path/$FILE
  echo 'Backup removido'
}

## DADOS DO BD##
user="USERNAME HERE"
password="PASSWORD HERE"
host="IP HERE"
db_name="DATABASE NAME HERE"

##FTP LOGIN##
USERNAME="USERNAME HERE"
PASSWORD="PASSWORD HERE"
SERVER="IP HERE"
PORT="SERVER PORT HERE"

#Local do FTP ONDE O BACKUP VAI SER ARMAZENADO
REMOTEDIR="./"

#TIPO DE TRANSFERENCIA DO FTP, 1 = FTP, 2 = SFTP

TYPE=1

d=$(date --iso)
cd $backup_path
create_backup

if [ $TYPE -eq 1 ]
then
ftp -n -i $SERVER <<EOF
user $USERNAME $PASSWORD
binary
cd $REMOTEDIR
mput $FILE
quit
EOF
elif [ $TYPE -eq 2 ]
then
rsync --rsh="sshpass -p $PASSWORD ssh -p $PORT -o StrictHostKeyChecking=no -l $USERNAME" $backup_path/$FILE $SERVER:$REMOTEDIR
else
echo 'SELECIONE UM TIPO VALIDO'
fi

echo 'BACKUP ENVIADO COM SUCESSO'
clean_backup
