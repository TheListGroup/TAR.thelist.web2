import mysql.connector
from mysql.connector import Error

def get_db():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="real-dev",
            password="6Yh#H4L5Zk9jYMe0gr@X",
            database="realist_office",
            charset="utf8mb4",
            collation="utf8mb4_unicode_ci"
        )
        return conn
    except Error as e:
        print(f"Error connecting to database: {e}")
        raise e