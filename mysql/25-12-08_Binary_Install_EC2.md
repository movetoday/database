
# 🛠️ MySQL 8.0 Binary Installation on AWS EC2


> **Summary:**
> Deployment of MySQL 8.0 on AWS EC2 using the **Binary method** instead of package managers (APT/YUM).
---

## 1. Environment Specs

| Category | Details |
|:---:|:---|
| **Cloud** | AWS EC2 (t2.micro / Free Tier) |
| **OS** | Ubuntu 22.04 LTS |
| **Database** | MySQL 8.0.44 (Linux - Generic, glibc 2.28) |
| **Method** | **Binary Install** (Compressed TAR Archive) |
| **Directories** | Base: `/mysql`<br>Data: `/DATA/mysql_data`<br>Logs: `/DATA/mysql_logs` |

---
## 2. Why Binary Install?

In a production DBA environment, package managers (like `apt-get`) are convenient but limit control. I chose the Binary Installation method to verify the following capabilities:
1.  **Directory Control:** Manually separating the engine, data, and log directories for better I/O management.
2.  **Multi-Instance Readiness:** Gaining the ability to run multiple MySQL instances on a single server by managing independent configuration files (`my.cnf`).
3.  **Deep Understanding:** Learning the core OS dependencies and permission structures required by the MySQL engine.

---
## 3. Installation Log & Procedure

### 3.1 Download & Setup
Running on an EC2 instance with `glibc 2.39`, I selected the **Generic Linux (glibc 2.28)** version for maximum compatibility and stability.

```bash
# 1. Download & Extract
wget [https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.44-linux-glibc2.28-x86_64.tar.xz](https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.44-linux-glibc2.28-x86_64.tar.xz)
tar -xvf mysql-8.0.44-linux-glibc2.28-x86_64.tar.xz
sudo mv mysql-8.0.44-linux-glibc2.28-x86_64 /mysql

# 2. Create Dedicated User & Directories
sudo useradd -r -s /bin/false mysql
sudo mkdir -p /DATA/mysql_data
sudo mkdir -p /DATA/mysql_logs

# 3. Permission Setup
sudo chown -R mysql:mysql /mysql
sudo chown -R mysql:mysql /DATA

---
## 4. 🚨 Troubleshooting (Key Challenges)

During the manual installation, I encountered and resolved three major issues.

### ❌ Issue 1: Missing Shared Libraries
* **Error:** `./bin/mysqld: error while loading shared libraries: libaio.so.1: cannot open shared object file`
* **Cause:** Unlike APT installation, the binary method does not automatically install OS dependencies. The Async I/O library (`libaio`) required by InnoDB was missing.
* **Resolution:** Manually installed the required libraries.
    ```bash
    sudo apt-get update
    sudo apt-get install libaio1 libncurses5 -y
    ```

### ❌ Issue 2: Initialization Failure (Permission & Directory State)
* **Error:** `[MY-010457] --initialize specified but the data directory has files in it.` / `OS errno 13 - Permission denied`
* **Cause:**
    1. The `mysql` user did not have write permissions to the data directory.
    2. After a failed attempt, residual files remained in the data directory, preventing re-initialization.
* **Resolution:** Cleared the directory and reapplied ownership.
    ```bash
    rm -rf /DATA/mysql_data/* # Clean up residual files
    chown -R mysql:mysql /DATA      # Re-grant permissions
    ```

### ❌ Issue 3: Socket Path Mismatch
* **Error:** `Can't connect to local MySQL server through socket '/tmp/mysql.sock'`
* **Cause:** The server (`mysqld`) was configured to create the socket in `/DATA/mysql_data/mysql.sock`, but the client (`mysql` command) was looking in the default `/tmp` location.
* **Resolution:** Unified the socket path in `my.cnf` for both `[mysqld]` and `[client]` sections.

---

## 5. Configuration (my.cnf)

I created a custom `/etc/my.cnf` optimized for the **EC2 t2.micro (1GB RAM)** environment and pre-configured for future **Replication/HA** labs.

```ini
[client]
port = 3306
socket = /DATA/mysql_data/mysql.sock

[mysql]
no-auto-rehash  # 접속 시 테이블 자동완성 끄기 (속도 향상)

[mysqld]
# --- Basic Settings ---
user     = mysql
port     = 3306
basedir  = /mysql
datadir  = /DATA/mysql_data
socket   = /DATA/mysql_data/mysql.sock
pid-file = /DATA/mysql_logs/mysqld.pid

# 로그 설정 (Logging)
log-error = /DATA/mysql_logs/mysql.err
slow_query_log = 1
slow_query_log_file = /DATA/mysql_logs/slow_query.log
long_query_time = 3.0  # 3초 이상 걸리는 쿼리는 기록

# --- Network & Security ---
# EC2 외부 접속을 위해 0.0.0.0 설정 (실무에선 특정 IP만 허용하거나 VPN 사용)
bind-address = 0.0.0.0
# MySQL 8.0의 기본 인증 플러그인 (구버전 클라이언트 호환성 위해 native 사용 가능)
authentication_policy = mysql_native_password

# --- Replication & HA Ready ---
server-id = 1
log-bin = /DATA/mysql_logs/mysql-bin
binlog_format = ROW          # 8.0 표준 (데이터 일관성 최고)
binlog_expire_logs_seconds = 604800  # 7일 보관 후 자동 삭제

sync_binlog = 1
innodb_flush_log_at_trx_commit = 1

# [GTID 설정] HA 구성(MHA, 자동복구)을 위해 필수 ⭐
#gtid_mode = ON
#enforce_gtid_consistency = ON

# [Relay Log] 나중에 이 서버가 Slave가 될 수도 있으므로 미리 설정
#relay_log = /mysql/logs/mysql-relay-bin
#log_replica_updates = ON     # (구 log_slave_updates) 체인 복제 지원


# 문자셋 설정 (Character Set)
character-set-server = utf8mb4
collation-server     = utf8mb4_general_ci
init_connect         = 'SET NAMES utf8mb4'


# --- Performance (t2.micro) ---
innodb_buffer_pool_size = 256M
max_connections = 100
# 대소문자 구분 안 함 (윈도우랑 호환성 유지, 보통 1로 설정)
lower_case_table_names = 1

```

---

## 6. Final Result
* **Initialization:** Successfully initialized via `mysqld --defaults-file=/etc/my.cnf --initialize`.
* **Service Start:** Started using `mysqld_safe`.
* **Connection:** Verified connection from both local shell and remote DBeaver client.

```bash
# Process Verification
ps -ef | grep mysqld
# Output: /bin/sh /mysql/bin/mysqld_safe --defaults-file=/etc/my.cnf ...
```





