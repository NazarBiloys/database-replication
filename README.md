# database-replication

Test Master-Slave replication in MySQL

- run sh `./build.sh`

- in mysql-master container make a user table:

```
CREATE TABLE users (
id INT NOT NULL AUTO_INCREMENT,
firstname VARCHAR(50) NOT NULL,
lastname VARCHAR(50) NOT NULL,
email VARCHAR(255) NOT NULL,
password VARCHAR(255) NOT NULL,
date_of_birth DATE NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (id)
);

```

- generate some users use endpoint `http://localhost:90/` (you can use siege for this)

- ensure that replications are working. You can see it on output by `build.sh` command, or use comamnd `docker exec mysql-slave-second sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"`

```
Slave_IO_State: Waiting for source to send event
Master_Host: mysql-master
Master_User: mydb_slave_user_second
Master_Port: 3306
Connect_Retry: 60
Master_Log_File: 1.000003
Read_Master_Log_Pos: 2023
Relay_Log_File: 87178ec761e7-relay-bin.000002
Relay_Log_Pos: 786
Relay_Master_Log_File: 1.000003
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
Replicate_Do_DB:
Replicate_Ignore_DB:
Replicate_Do_Table:
Replicate_Ignore_Table:
Replicate_Wild_Do_Table:
Replicate_Wild_Ignore_Table:
Last_Errno: 0
Last_Error:
Skip_Counter: 0
Exec_Master_Log_Pos: 2023
Relay_Log_Space: 1003
Until_Condition: None
Until_Log_File:
Until_Log_Pos: 0
Master_SSL_Allowed: No
Master_SSL_CA_File:
Master_SSL_CA_Path:
Master_SSL_Cert:
Master_SSL_Cipher:
Master_SSL_Key:
Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
Last_IO_Errno: 0
Last_IO_Error:
Last_SQL_Errno: 0
Last_SQL_Error:
Replicate_Ignore_Server_Ids:
Master_Server_Id: 1
Master_UUID: 991ec49c-e200-11ed-954a-0242c0a88002
Master_Info_File: mysql.slave_master_info
SQL_Delay: 0
SQL_Remaining_Delay: NULL
Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
Master_Retry_Count: 86400
...
```

- turn off `mysql-slave-second` and look on changing `Seconds_Behind_Master`
- for example you can stop container and start siege again

I got difference

`Seconds_Behind_Master: 13`

- in test when i changes structure in slave database i had next output with slave status

```
*************************** 1. row ***************************
Slave_IO_State: Waiting for source to send event
Master_Host: mysql-master
Master_User: mydb_slave_user_second
Master_Port: 3306
Connect_Retry: 60
Master_Log_File: 1.000003
Read_Master_Log_Pos: 10151284
Relay_Log_File: 0ceb82488081-relay-bin.000006
Relay_Log_Pos: 4830318
Relay_Master_Log_File: 1.000003
Slave_IO_Running: Yes
Slave_SQL_Running: No
Replicate_Do_DB:
Replicate_Ignore_DB:
Replicate_Do_Table:
Replicate_Ignore_Table:
Replicate_Wild_Do_Table:
Replicate_Wild_Ignore_Table:
Last_Errno: 1054
Last_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 1 failed executing transaction 'ANONYMOUS' at master log 1.000003, end_log_pos 9668736. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
Skip_Counter: 0
Exec_Master_Log_Pos: 9668284
Relay_Log_Space: 5319189
Until_Condition: None
Until_Log_File:
Until_Log_Pos: 0
Master_SSL_Allowed: No
Master_SSL_CA_File:
Master_SSL_CA_Path:
Master_SSL_Cert:
Master_SSL_Cipher:
Master_SSL_Key:
Seconds_Behind_Master: NULL
Master_SSL_Verify_Server_Cert: No
Last_IO_Errno: 0
Last_IO_Error:
Last_SQL_Errno: 1054
Last_SQL_Error: Coordinator stopped because there were error(s) in the worker(s). The most recent failure being: Worker 1 failed executing transaction 'ANONYMOUS' at master log 1.000003, end_log_pos 9668736. See error log and/or performance_schema.replication_applier_status_by_worker table for more details about this failure or others, if any.
Replicate_Ignore_Server_Ids:
Master_Server_Id: 1
Master_UUID: a986d2ea-e207-11ed-948f-0242c0a8c002
Master_Info_File: mysql.slave_master_info
SQL_Delay: 0
SQL_Remaining_Delay: NULL
Slave_SQL_Running_State:
Master_Retry_Count: 86400
Master_Bind:
Last_IO_Error_Timestamp:
Last_SQL_Error_Timestamp: 230423 18:59:30
Master_SSL_Crl:
Master_SSL_Crlpath:
Retrieved_Gtid_Set:
Executed_Gtid_Set:
Auto_Position: 0
Replicate_Rewrite_DB:
Channel_Name:
Master_TLS_Version:
Master_public_key_path:
Get_master_public_key: 0
Network_Namespace:
```
