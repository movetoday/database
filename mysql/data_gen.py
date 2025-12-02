import pymysql
from faker import Faker
import time

# ==========================================
# [설정] AWS RDS 접속 정보
# ==========================================
DB_HOST = 'db-mysql-1.crogy8okot0y.ap-northeast-2.rds.amazonaws.com'  # ★ 아까 복사한 AWS 엔드포인트 주소!
DB_USER = 'admin'          # AWS 아이디 
DB_PASS = 'mysql1234'   # 비밀번호
DB_NAME = 'mytest'     # DB 이름

# Faker 객체 생성 (한국어 데이터)
fake = Faker('ko_KR')

def connect_db():
    conn = pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, charset='utf8mb4')
    cursor = conn.cursor()
    return conn, cursor

def generate_data(count=100000):
    conn, cursor = connect_db()
    
    # 1. DB 및 테이블 생성
    print("🔄 초기화 중...")
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
    cursor.execute(f"USE {DB_NAME}")
    cursor.execute("DROP TABLE IF EXISTS users")
    cursor.execute("""
        CREATE TABLE users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(50),
            email VARCHAR(100),
            phone VARCHAR(20),
            address VARCHAR(255),
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # 2. 데이터 생성 및 삽입 (Batch Insert)
    print(f"🚀 {count}건의 데이터 생성을 시작합니다... (약 10~20초 소요)")
    start_time = time.time()
    
    data = []
    for i in range(count):
        data.append((fake.name(), fake.email(), fake.phone_number(), fake.address()))
        
        # 1000건씩 모아서 한 번에 Insert (속도 향상)
        if (i + 1) % 1000 == 0:
            cursor.executemany("INSERT INTO users (username, email, phone, address) VALUES (%s, %s, %s, %s)", data)
            conn.commit()
            data = [] # 비우기
            if (i + 1) % 10000 == 0:
                print(f"   - {i+1}건 저장 중...")

    end_time = time.time()
    print(f"✅ 완료! 총 소요 시간: {end_time - start_time:.2f}초")
    conn.close()

if __name__ == "__main__":
    generate_data(100000) # 10만 건 생성