import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import subprocess
import os

def reset_db():
    db_name = 'metabrass'
    user = 'postgres'
    password = '1234'
    host = 'localhost'
    port = '5432'

    try:
        # Connect to default postgres DB to drop the target DB
        con = psycopg2.connect(user=user, password=password, host=host, port=port, database='postgres')
        con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = con.cursor()

        # Terminate other connections to the database
        print(f"Terminating connections to '{db_name}'...")
        cur.execute(f"""
            SELECT pg_terminate_backend(pg_stat_activity.pid)
            FROM pg_stat_activity
            WHERE pg_stat_activity.datname = '{db_name}'
              AND pid <> pg_backend_pid();
        """)

        # Drop the database
        print(f"Dropping database '{db_name}'...")
        cur.execute(f"DROP DATABASE IF EXISTS {db_name}")

        # Create the database
        print(f"Creating fresh database '{db_name}'...")
        cur.execute(f"CREATE DATABASE {db_name}")
        
        cur.close()
        con.close()
        print("Database reset successfully.")

        # Run migrations
        print("Running migrations...")
        subprocess.run(["python", "manage.py", "migrate"], check=True)

        print("\n" + "="*50)
        print("Success! Database is now EMPTY.")
        print("Please run the following command to create a new Admin account for the client:")
        print("python manage.py createsuperuser")
        print("="*50)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reset_db()
