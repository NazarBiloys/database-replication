#!/bin/bash

docker-compose down -v
rm -rf ./master/data/*
rm -rf ./slave-1/data/*
rm -rf ./slave-2/data/*
docker-compose build
docker-compose up -d

until docker exec mysql-master sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql-master database connection..."
    sleep 4
done

echo "Start making first user..."
priv_stmt='CREATE USER "mydb_slave_user"@"%" IDENTIFIED BY "mydb_slave_pwd"; GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user"@"%"; FLUSH PRIVILEGES;'
docker exec mysql-master sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt'"
echo "Finished making..."

echo "Start making second user..."
priv_stmt='CREATE USER "mydb_slave_user_second"@"%" IDENTIFIED BY "mydb_slave_pwd_second"; GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user_second"@"%"; FLUSH PRIVILEGES;'
docker exec mysql-master sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt'"
echo "Finished making..."

until docker-compose exec mysql-slave-first sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql-slave-first database connection..."
    sleep 4
done

echo "Start reading master status..."
MS_STATUS=`docker exec mysql-master sh -c 'export MYSQL_PWD=111; mysql -u root -e "SHOW MASTER STATUS"'`
echo "Finished reading..."

CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

echo "Start setup first slave..."
start_slave_stmt="CHANGE MASTER TO MASTER_HOST='mysql-master',MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
docker exec mysql-slave-first sh -c "$start_slave_cmd"
echo "Finished setup..."

docker exec mysql-slave-first sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"

until docker-compose exec mysql-slave-second sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql-slave-second database connection..."
    sleep 4
done

echo "Start setup second slave..."
start_slave_stmt="CHANGE MASTER TO MASTER_HOST='mysql-master',MASTER_USER='mydb_slave_user_second',MASTER_PASSWORD='mydb_slave_pwd_second',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=111; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
docker exec mysql-slave-second sh -c "$start_slave_cmd"
echo "Finished setup..."

docker exec mysql-slave-second sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
