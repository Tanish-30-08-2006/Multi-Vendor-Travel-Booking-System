import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

import psycopg2
import os
from dotenv import load_dotenv

# Load the variables from your .env file
load_dotenv()

def get_db_connection():
    """
    This function acts like a 'Battery'. 
    When we call it, it gives us power (the connection) 
    to talk to the database.
    """
    try:
        # This line actually creates the bridge to PostgreSQL
        conn = psycopg2.connect(
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASS"),
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT"),
            database=os.getenv("DB_NAME")
        )
        return conn
        
    except Exception as e:
        print(f" Could not connect to the database: {e}")
        return None

# Simple test to make sure CONNECTION is working 
if __name__ == "__main__":
    connection = get_db_connection()
    if connection:
        print("Database Successfully Connected to Tanish_Local_Server.")
        connection.close() 
        # We Always close the connection when done testing
