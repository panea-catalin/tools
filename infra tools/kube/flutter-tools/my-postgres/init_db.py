apiVersion: v1
kind: ConfigMap
metadata:
  name: init-db-config
  namespace: flask-app
data:
  init_db.py: |
    import sqlite3

    connection = sqlite3.connect('/app/database.db')

    with open('/app/schema.sql') as f:
        connection.executescript(f.read())

    cur = connection.cursor()

    cur.execute("INSERT INTO posts (title, content) VALUES (?, ?)",
                ('First Post', 'Content for the first post')
                )

    cur.execute("INSERT INTO posts (title, content) VALUES (?, ?)",
                ('Second Post', 'Content for the second post')
                )

    connection.commit()
    connection.close()
  schema.sql: |
    CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
    );
