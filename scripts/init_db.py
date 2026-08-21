#!/usr/bin/env python3
# scripts/init_db.py
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from heritage_hub.core.db import init_db, init_extensions

if __name__ == "__main__":
    print("🔧 Initialisation de la base Heritage Hub...")
    init_db()
    init_extensions()
    print("✅ Base initialisée avec succès.")
