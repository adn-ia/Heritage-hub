# heritage_hub/core/db.py
import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "atelier.db")

def get_db():
    """Retourne une connexion à la base SQLite."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Crée les tables du socle si elles n'existent pas."""
    conn = get_db()
    with open(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "socle.sql"), "r") as f:
        conn.executescript(f.read())
    conn.commit()
    conn.close()
    print("✅ Socle initialisé.")

def init_extensions():
    """Crée les tables des modules si elles n'existent pas."""
    conn = get_db()
    with open(os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "extension.sql"), "r") as f:
        conn.executescript(f.read())
    conn.commit()
    conn.close()
    print("✅ Modules initialisés.")
