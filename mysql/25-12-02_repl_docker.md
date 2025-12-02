# Docker를 이용한 MySQL replication test

상태: 완료
작업일자: 2025/12/02

## **Docker 기반 MySQL 8.0 Replication 구성 TEST**

해당 서버 github codespace 사용

### 1. Docker로 MySQL master & slave 서버 구동

```bash
## docker network 생성
@movetoday ➜ /workspaces/dev-lab (main) $ docker network create mysql-net
7cac26a45ed67a44cd347db427857560b3c71fa58947963753b63e242adbba85

@movetoday ➜ /workspaces/dev-lab (main) $ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

## master 서버 실행
@movetoday ➜ /workspaces/dev-lab (main) $ docker run --name mysql-master \
  --network mysql-net \
  -e MYSQL_ROOT_PASSWORD=mysql1234 \
  -p 3306:3306 \
  -d mysql:8.0 \
  --server-id=1 \
  --log-bin=mysql-bin \
  --binlog-format=ROW
9686686b5efe1ad6cce26cd67991a3852eadcc2a4ec7e687a4ea7b1a8816e313

## master 서버 구동 확인
@movetoday ➜ /workspaces/dev-lab (main) $ docker ps -a
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                                                    NAMES
9686686b5efe   mysql:8.0   "docker-entrypoint.s…"   3 seconds ago   Up 2 seconds   0.0.0.0:3306->3306/tcp, [::]:3306->3306/tcp, 33060/tcp   mysql-master

## slave 서버 실행
@movetoday ➜ /workspaces/dev-lab (main) $ docker run --name mysql-slave \
  --network mysql-net \
  -e MYSQL_ROOT_PASSWORD=mysql1234 \
  -p 3307:3306 \
  -d mysql:8.0 \
  --server-id=2
2691c636271b264d106870821f4f5ae41376fd239032a0dcf10e68255bf1d4b1

## master & slave 서버 실행 확인
@movetoday ➜ /workspaces/dev-lab (main) $ docker ps -a
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                                                    NAMES
2691c636271b   mysql:8.0   "docker-entrypoint.s…"   6 seconds ago   Up 5 seconds   33060/tcp, 0.0.0.0:3307->3306/tcp, [::]:3307->3306/tcp   mysql-slave
9686686b5efe   mysql:8.0   "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   0.0.0.0:3306->3306/tcp, [::]:3306->3306/tcp, 33060/tcp   mysql-master
```

### 2. MySQL Replication 구성

```bash
## MySQL master 서버 접속
@movetoday ➜ /workspaces/dev-lab (main) $ docker exec -it mysql-master mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.44 MySQL Community Server - GPL

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 

## master에서 replication용 유저 생성
mysql> CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY 'repl';
Query OK, 0 rows affected (0.26 sec)

mysql> grant replication slave on *.* to 'repl'@'%';
Query OK, 0 rows affected (0.01 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

## binary log status 확인
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000003 |      827 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```

```bash
@movetoday ➜ /workspaces/dev-lab/mysql (main) $ docker ps -a
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                                                    NAMES
2691c636271b   mysql:8.0   "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes   33060/tcp, 0.0.0.0:3307->3306/tcp, [::]:3307->3306/tcp   mysql-slave
9686686b5efe   mysql:8.0   "docker-entrypoint.s…"   8 minutes ago   Up 8 minutes   0.0.0.0:3306->3306/tcp, [::]:3306->3306/tcp, 33060/tcp   mysql-master

## MySQL slave 서버 접속
@movetoday ➜ /workspaces/dev-lab/mysql (main) $ docker exec -it mysql-slave mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.44 MySQL Community Server - GPL

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 

## replication 연결

mysql> change master to
    -> master_host='mysql-master', master_user='repl',master_password='mysql1234', master_log_file='mysql-bin.000003', master_log_pos=827;
Query OK, 0 rows affected, 8 warnings (0.02 sec)

mysql> start slave;
Query OK, 0 rows affected, 1 warning (0.02 sec)

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: mysql-master
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 827
               Relay_Log_File: 2691c636271b-relay-bin.000002
                Relay_Log_Pos: 326
        Relay_Master_Log_File: mysql-bin.000003
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
          Exec_Master_Log_Pos: 827
              Relay_Log_Space: 543
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
                  Master_UUID: f7f53cf4-cf6d-11f0-b11a-e65c52e9100e
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
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
1 row in set, 1 warning (0.01 sec)

mysql> 
```

master에서 DB 생성 후 slave에서 조회

```sql
## master에서 database 생성
mysql> create database db_repl;
Query OK, 1 row affected (0.01 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
**| db_repl            |**
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

## slave에서 생성된 database 확인
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
**| db_repl            |**
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.01 sec)

mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: mysql-master
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 1021
               Relay_Log_File: 2691c636271b-relay-bin.000002
                Relay_Log_Pos: 520
        Relay_Master_Log_File: mysql-bin.000003
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
          Exec_Master_Log_Pos: 1021
              Relay_Log_Space: 737
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
                  Master_UUID: f7f53cf4-cf6d-11f0-b11a-e65c52e9100e
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
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
1 row in set, 1 warning (0.00 sec)

mysql> 

```

→ MySQL Replication 구성 완료
