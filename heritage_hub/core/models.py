# heritage_hub/core/models.py
from .db import get_db

def get_text(table_name, record_id, champ, langue="fr"):
    """Récupère une valeur traduite ou le fallback."""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT valeur FROM traduction
        WHERE table_name = ? AND record_id = ? AND langue = ? AND champ = ?
    """, (table_name, record_id, langue, champ))
    row = cursor.fetchone()
    
    if row:
        return row[0]
    
    # Fallback
    if table_name == "piece":
        cursor.execute("SELECT designation FROM piece WHERE id = ?", (record_id,))
    elif table_name == "planche":
        cursor.execute("SELECT titre FROM planche WHERE id = ?", (record_id,))
    elif table_name == "catalogue":
        cursor.execute("SELECT nom FROM catalogue WHERE id = ?", (record_id,))
    else:
        return None
    
    row = cursor.fetchone()
    return row[0] if row else None

def insert_piece(ref, designation, matiere=None, normalisee=0, catalogue_id=1):
    """Ajoute une pièce et sa traduction française."""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("""
        INSERT OR IGNORE INTO piece (catalogue_id, reference, designation, matiere, normalisee)
        VALUES (?, ?, ?, ?, ?)
    """, (catalogue_id, ref, designation, matiere, normalisee))
    
    cursor.execute("SELECT id FROM piece WHERE reference = ?", (ref,))
    row = cursor.fetchone()
    if not row:
        return None
    piece_id = row[0]
    
    cursor.execute("""
        INSERT OR IGNORE INTO traduction (table_name, record_id, langue, champ, valeur)
        VALUES ('piece', ?, 'fr', 'designation', ?)
    """, (piece_id, designation))
    
    conn.commit()
    return piece_id

def get_piece_by_ref(ref):
    """Récupère une pièce par sa référence."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, reference, designation FROM piece WHERE reference = ?", (ref,))
    return cursor.fetchone()

def get_or_create_catalogue(nom, marque, edition=None):
    """Récupère ou crée un catalogue."""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM catalogue WHERE nom = ? AND marque = ?", (nom, marque))
    row = cursor.fetchone()
    if row:
        return row[0]
    
    cursor.execute("""
        INSERT INTO catalogue (nom, marque, edition)
        VALUES (?, ?, ?)
    """, (nom, marque, edition))
    catalogue_id = cursor.lastrowid
    
    cursor.execute("""
        INSERT OR IGNORE INTO traduction (table_name, record_id, langue, champ, valeur)
        VALUES ('catalogue', ?, 'fr', 'nom', ?)
    """, (catalogue_id, nom))
    
    conn.commit()
    return catalogue_id
