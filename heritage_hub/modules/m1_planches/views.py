# M1 · Vues pour l'affichage des planches
import json
from flask import jsonify, render_template
from heritage_hub.core.db import get_db

def get_planche_data(numero):
    """Récupère toutes les données d'une planche"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute("SELECT id, titre FROM planche WHERE numero = ?", (numero,))
    planche = cursor.fetchone()
    if not planche:
        return None
    
    planche_id = planche[0]
    
    cursor.execute("""
        SELECT 
            p.reference,
            COALESCE(t.valeur, p.designation) AS designation,
            n.repere,
            n.quantite,
            m.ancre_x,
            m.ancre_y,
            m.polygone
        FROM nomenclature n
        JOIN piece p ON p.id = n.piece_id
        LEFT JOIN m1_zone m ON m.nomenclature_id = n.id
        LEFT JOIN traduction t
            ON t.table_name = 'piece' AND t.record_id = p.id
            AND t.langue = 'fr' AND t.champ = 'designation'
        WHERE n.planche_id = ?
    """, (planche_id,))
    
    repères = []
    for row in cursor.fetchall():
        repères.append({
            "reference": row[0],
            "designation": row[1],
            "repere": row[2],
            "quantite": row[3],
            "ancre": [row[4], row[5]] if row[4] is not None else None,
            "polygone": json.loads(row[6]) if row[6] else None
        })
    
    conn.close()
    return {
        "numero": numero,
        "titre": planche[1],
        "reperes": repères
    }

def register_routes(app):
    """Enregistre les routes du module M1"""
    
    @app.route("/planche/<numero>")
    def planche(numero):
        data = get_planche_data(numero)
        if not data:
            return "Planche non trouvée", 404
        return render_template("planche.html", planche=data)
    
    @app.route("/api/planche/<numero>")
    def api_planche(numero):
        data = get_planche_data(numero)
        if not data:
            return jsonify({"error": "Planche non trouvée"}), 404
        return jsonify(data)
