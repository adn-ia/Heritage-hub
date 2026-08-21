# M1 · Import des zones cliquables depuis un JSON
import json
import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))), "atelier.db")

def importer_zones(json_path, planche_numero, catalogue_id=1):
    """Importe un JSON exporté depuis reperes-203.html"""
    if not os.path.exists(json_path):
        print(f"❌ Fichier introuvable : {json_path}")
        return
    
    with open(json_path, "r") as f:
        data = json.load(f)
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Récupérer ou créer la planche
    cursor.execute("""
        INSERT OR IGNORE INTO planche (catalogue_id, numero, titre)
        VALUES (?, ?, ?)
    """, (catalogue_id, planche_numero, f"Planche {planche_numero}"))
    cursor.execute("SELECT id FROM planche WHERE numero = ?", (planche_numero,))
    planche_id = cursor.fetchone()[0]
    
    for rep in data.get("reperes", []):
        ref = rep.get("ref", "").strip()
        designation = rep.get("designation", "")
        repere = rep.get("repere", "")
        quantite = rep.get("quantite", "1")
        ancre = rep.get("ancre")
        
        # Insérer la pièce
        cursor.execute("""
            INSERT OR IGNORE INTO piece (catalogue_id, reference, designation)
            VALUES (?, ?, ?)
        """, (catalogue_id, ref, designation))
        cursor.execute("SELECT id FROM piece WHERE reference = ?", (ref,))
        piece = cursor.fetchone()
        if not piece:
            continue
        piece_id = piece[0]
        
        # Ajouter à la nomenclature
        try:
            qte = int(quantite)
        except:
            qte = 1
        cursor.execute("""
            INSERT OR IGNORE INTO nomenclature (planche_id, piece_id, repere, quantite)
            VALUES (?, ?, ?, ?)
        """, (planche_id, piece_id, repere, qte))
        
        # Ajouter la zone cliquable
        if ancre and len(ancre) >= 2:
            x, y = ancre[0], ancre[1]
            cursor.execute("SELECT id FROM nomenclature WHERE planche_id = ? AND repere = ?", (planche_id, repere))
            nom = cursor.fetchone()
            if nom:
                nom_id = nom[0]
                poly = f'[[{x-0.02},{y-0.02}],[{x+0.02},{y-0.02}],[{x+0.02},{y+0.02}],[{x-0.02},{y+0.02}]]'
                cursor.execute("""
                    INSERT OR IGNORE INTO m1_zone (nomenclature_id, polygone, ancre_x, ancre_y)
                    VALUES (?, ?, ?, ?)
                """, (nom_id, poly, x, y))
    
    conn.commit()
    conn.close()
    print(f"✅ Import terminé : {len(data['reperes'])} repères traités")
