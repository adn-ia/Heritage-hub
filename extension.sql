-- Heritage Hub — Modules M1 à M34

-- M1 · Planches cliquables
CREATE TABLE IF NOT EXISTS m1_zone (
  id INTEGER PRIMARY KEY,
  nomenclature_id INTEGER NOT NULL REFERENCES nomenclature(id) ON DELETE CASCADE,
  media_id INTEGER REFERENCES media(id) ON DELETE CASCADE,
  polygone TEXT NOT NULL,
  ancre_x REAL,
  ancre_y REAL,
  origine TEXT NOT NULL DEFAULT 'manuel',
  confiance REAL,
  valide_par TEXT,
  valide_le TEXT
);

-- M2 · Équivalences modernes
CREATE TABLE IF NOT EXISTS m2_equivalence (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  categorie TEXT NOT NULL CHECK (categorie IN ('normalise','refabrication','adaptation','fabrication_atelier')),
  designation TEXT NOT NULL,
  norme TEXT,
  fournisseur TEXT,
  prix_indicatif REAL,
  devise TEXT DEFAULT 'EUR',
  reserve TEXT,
  verifie INTEGER NOT NULL DEFAULT 0,
  verifie_par TEXT
);

-- M3 · Veille marché
CREATE TABLE IF NOT EXISTS m3_annonce (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER REFERENCES piece(id) ON DELETE SET NULL,
  site TEXT NOT NULL,
  url TEXT NOT NULL UNIQUE,
  titre TEXT,
  prix REAL,
  devise TEXT DEFAULT 'EUR',
  etat TEXT,
  lot INTEGER DEFAULT 1,
  pays TEXT,
  vue_le TEXT NOT NULL DEFAULT (datetime('now')),
  disparue_le TEXT,
  rapprochement TEXT CHECK (rapprochement IN ('auto','manuel','incertain'))
);

-- M4 · Carnet de chantier
CREATE TABLE IF NOT EXISTS m4_vehicule (
  id INTEGER PRIMARY KEY,
  nom TEXT NOT NULL,
  modele_id INTEGER REFERENCES modele(id),
  no_serie TEXT,
  no_moteur TEXT,
  annee INTEGER,
  lieu TEXT
);

CREATE TABLE IF NOT EXISTS m4_ligne (
  id INTEGER PRIMARY KEY,
  vehicule_id INTEGER NOT NULL REFERENCES m4_vehicule(id) ON DELETE CASCADE,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  statut TEXT NOT NULL CHECK (statut IN ('a_evaluer','a_refaire','au_bain','commandee','recue','reposee','manquante','ecartee')),
  quantite INTEGER NOT NULL DEFAULT 1,
  fournisseur TEXT,
  cout REAL,
  date_statut TEXT NOT NULL DEFAULT (datetime('now')),
  note TEXT
);

-- M5 · Reproduction 3D
CREATE TABLE IF NOT EXISTS m5_modele (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  version TEXT NOT NULL,
  etape TEXT NOT NULL CHECK (etape IN ('scan_brut','mesh_nettoye','cao_parametrique','valide')),
  format TEXT NOT NULL CHECK (format IN ('stl','step','fcstd','obj','3mf')),
  media_id INTEGER REFERENCES media(id) ON DELETE SET NULL,
  procede TEXT,
  retrait_pct REAL,
  imprime_teste INTEGER NOT NULL DEFAULT 0,
  monte_teste INTEGER NOT NULL DEFAULT 0,
  auteur TEXT,
  licence TEXT,
  note TEXT,
  cree_le TEXT NOT NULL DEFAULT (datetime('now'))
);

-- M6 · Modération et contributions (fusion M6 + M25)
CREATE TABLE IF NOT EXISTS m6_proposition (
  id INTEGER PRIMARY KEY,
  table_cible TEXT NOT NULL,
  ligne_id INTEGER,
  champ TEXT,
  valeur_avant TEXT,
  valeur_apres TEXT NOT NULL,
  justification TEXT,
  piece_jointe INTEGER REFERENCES media(id) ON DELETE SET NULL,
  auteur TEXT NOT NULL,
  statut TEXT NOT NULL DEFAULT 'en_attente' CHECK (statut IN ('en_attente','acceptee','refusee','doublon')),
  reviseur TEXT,
  motif_refus TEXT,
  cree_le TEXT NOT NULL DEFAULT (datetime('now')),
  traite_le TEXT
);

CREATE TABLE IF NOT EXISTS m6_moderation (
  id INTEGER PRIMARY KEY,
  table_cible TEXT NOT NULL,
  ligne_id INTEGER NOT NULL,
  signalement_par TEXT NOT NULL,
  motif TEXT,
  date_signalement TEXT NOT NULL DEFAULT (datetime('now')),
  statut TEXT CHECK (statut IN ('ouvert','traite','rejete')) DEFAULT 'ouvert',
  traite_par TEXT,
  date_traitement TEXT,
  decision TEXT
);

-- M7 · Annuaire
CREATE TABLE IF NOT EXISTS m7_ressource (
  id INTEGER PRIMARY KEY,
  nom TEXT NOT NULL,
  url TEXT,
  pays TEXT,
  ville TEXT,
  langue TEXT,
  portee TEXT CHECK (portee IN ('203','peugeot_ancienne','francaise_ancienne','generaliste')),
  description TEXT,
  note_perso TEXT,
  cote INTEGER CHECK (cote BETWEEN 1 AND 5),
  actif INTEGER NOT NULL DEFAULT 1,
  verifie_le TEXT,
  cree_le TEXT NOT NULL DEFAULT (datetime('now'))
);

-- M8 · Recherche IA (FTS5)
CREATE VIRTUAL TABLE m8_index USING fts5(
  reference,
  designation,
  synonymes,
  norme,
  matiere,
  content='piece',
  content_rowid='id'
);

-- M9 · Panier
CREATE TABLE IF NOT EXISTS m9_panier (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  quantite INTEGER NOT NULL DEFAULT 1,
  source TEXT,
  prix_unitaire REAL,
  devise TEXT DEFAULT 'EUR',
  ajoute_le TEXT NOT NULL DEFAULT (datetime('now')),
  commande_id INTEGER
);

-- M10 · Collecteur
CREATE TABLE IF NOT EXISTS m10_source (
  id INTEGER PRIMARY KEY,
  nom TEXT NOT NULL,
  url TEXT NOT NULL,
  type TEXT CHECK (type IN ('pdf','html','api','rss','csv','excel')),
  actif INTEGER NOT NULL DEFAULT 1,
  frequence_veille INTEGER DEFAULT 24,
  derniere_collecte TEXT,
  parametres TEXT,
  note TEXT
);

CREATE TABLE IF NOT EXISTS m10_resultat (
  id INTEGER PRIMARY KEY,
  source_id INTEGER NOT NULL REFERENCES m10_source(id),
  collecte_le TEXT NOT NULL DEFAULT (datetime('now')),
  reference TEXT,
  designation TEXT,
  cotes TEXT,
  prix REAL,
  devise TEXT DEFAULT 'EUR',
  disponibilite TEXT,
  source_url TEXT,
  donnees_brutes TEXT,
  confiance REAL DEFAULT 0.5
);

-- M11 · Sauvegarde
CREATE TABLE IF NOT EXISTS m11_sauvegarde (
  id INTEGER PRIMARY KEY,
  date TEXT NOT NULL DEFAULT (datetime('now')),
  type TEXT CHECK (type IN ('json','sqlite','csv','pdf')),
  chemin TEXT NOT NULL,
  taille INTEGER,
  note TEXT
);

-- M13 · Versioning des pièces (fusion M13 + M17)
CREATE TABLE IF NOT EXISTS m13_version (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  version TEXT NOT NULL,
  date TEXT NOT NULL DEFAULT (datetime('now')),
  auteur TEXT,
  modifications TEXT,
  piece_id_parent INTEGER REFERENCES piece(id) ON DELETE SET NULL,
  UNIQUE(piece_id, version)
);

-- M14 · Historique
CREATE TABLE IF NOT EXISTS m14_audit (
  id INTEGER PRIMARY KEY,
  table_name TEXT NOT NULL,
  record_id INTEGER NOT NULL,
  action TEXT CHECK (action IN ('insert','update','delete')),
  champ TEXT,
  ancienne_valeur TEXT,
  nouvelle_valeur TEXT,
  utilisateur TEXT,
  date TEXT NOT NULL DEFAULT (datetime('now'))
);

-- M19 · Astuces
CREATE TABLE IF NOT EXISTS m19_astuce (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER REFERENCES piece(id),
  titre TEXT NOT NULL,
  description TEXT NOT NULL,
  materiel TEXT,
  difficulte TEXT CHECK (difficulte IN ('facile','moyen','difficile','expert')),
  temps_estime TEXT,
  auteur TEXT,
  source TEXT,
  valide INTEGER NOT NULL DEFAULT 0,
  date TEXT NOT NULL DEFAULT (datetime('now'))
);

-- M20 · Correspondances
CREATE TABLE IF NOT EXISTS m20_correspondance (
  id INTEGER PRIMARY KEY,
  piece_source_id INTEGER NOT NULL REFERENCES piece(id),
  piece_cible_id INTEGER NOT NULL REFERENCES piece(id),
  type TEXT CHECK (type IN ('interchangeable','adaptable','montable_sur','remplace')),
  adaptation TEXT,
  source TEXT,
  valide INTEGER NOT NULL DEFAULT 0,
  note TEXT
);

-- M21 · Ressources externes
CREATE TABLE IF NOT EXISTS m21_ressource (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER REFERENCES piece(id),
  titre TEXT NOT NULL,
  url TEXT NOT NULL,
  type TEXT CHECK (type IN ('forum','video','pdf','magasin','article','blog','doc')),
  description TEXT,
  auteur TEXT,
  date TEXT,
  valide INTEGER NOT NULL DEFAULT 0
);

-- M22 · Événements
CREATE TABLE IF NOT EXISTS m22_evenement (
  id INTEGER PRIMARY KEY,
  nom TEXT NOT NULL,
  description TEXT,
  type TEXT CHECK (type IN ('bourse','festival','rassemblement','exposition','vente_aux_encheres','sortie')),
  lieu TEXT,
  ville TEXT,
  pays TEXT,
  date_debut TEXT NOT NULL,
  date_fin TEXT,
  url TEXT,
  contact TEXT,
  note TEXT
);

-- M23 · Dépôt de documents
CREATE TABLE IF NOT EXISTS m23_depot (
  id INTEGER PRIMARY KEY,
  auteur TEXT NOT NULL,
  titre TEXT NOT NULL,
  description TEXT,
  type TEXT CHECK (type IN ('pdf','photo','modele_3d','video','audio','document','autre')),
  chemin_fichier TEXT NOT NULL,
  licence TEXT DEFAULT 'CC-BY-SA',
  attribution TEXT,
  date_depot TEXT NOT NULL DEFAULT (datetime('now')),
  statut TEXT CHECK (statut IN ('en_attente','publie','refuse','archive')) DEFAULT 'en_attente',
  modere_par TEXT,
  date_moderation TEXT,
  note_moderation TEXT,
  tags TEXT
);

-- M24 · Retours d'expérience
CREATE TABLE IF NOT EXISTS m24_retour (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER REFERENCES piece(id),
  auteur TEXT NOT NULL,
  titre TEXT NOT NULL,
  contenu TEXT NOT NULL,
  photos TEXT,
  date_publication TEXT NOT NULL DEFAULT (datetime('now')),
  statut TEXT CHECK (statut IN ('brouillon','publie','modere','supprime')) DEFAULT 'publie',
  nb_vues INTEGER DEFAULT 0,
  nb_likes INTEGER DEFAULT 0,
  modere_par TEXT,
  date_moderation TEXT
);

CREATE TABLE IF NOT EXISTS m24_commentaire (
  id INTEGER PRIMARY KEY,
  retour_id INTEGER NOT NULL REFERENCES m24_retour(id),
  auteur TEXT NOT NULL,
  contenu TEXT NOT NULL,
  date TEXT NOT NULL DEFAULT (datetime('now')),
  statut TEXT CHECK (statut IN ('publie','modere','supprime')) DEFAULT 'publie',
  modere_par TEXT
);

-- M26 · Galerie photo
CREATE TABLE IF NOT EXISTS m26_galerie (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER REFERENCES piece(id),
  auteur TEXT NOT NULL,
  titre TEXT NOT NULL,
  description TEXT,
  chemin_image TEXT NOT NULL,
  date_upload TEXT NOT NULL DEFAULT (datetime('now')),
  statut TEXT CHECK (statut IN ('en_attente','publie','refuse')) DEFAULT 'en_attente',
  tags TEXT,
  licence TEXT DEFAULT 'CC-BY-SA'
);

-- M27 · CGU et RGPD
CREATE TABLE IF NOT EXISTS m27_consentement (
  id INTEGER PRIMARY KEY,
  utilisateur TEXT NOT NULL,
  type TEXT CHECK (type IN ('cgu','rgpd','donnees','cookies')),
  accepte INTEGER NOT NULL DEFAULT 0,
  date TEXT NOT NULL DEFAULT (datetime('now')),
  version TEXT NOT NULL,
  ip TEXT
);

-- M28 · Support et reporting
CREATE TABLE IF NOT EXISTS m28_ticket (
  id INTEGER PRIMARY KEY,
  auteur TEXT NOT NULL,
  email TEXT NOT NULL,
  sujet TEXT NOT NULL,
  message TEXT NOT NULL,
  statut TEXT CHECK (statut IN ('ouvert','en_cours','resolu','ferme')) DEFAULT 'ouvert',
  date TEXT NOT NULL DEFAULT (datetime('now')),
  priorite TEXT CHECK (priorite IN ('basse','normale','haute','critique')) DEFAULT 'normale'
);

-- M29 · Licences
CREATE TABLE IF NOT EXISTS m29_licence (
  id INTEGER PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  nom TEXT NOT NULL,
  description TEXT,
  url TEXT
);

-- M30 · Stock
CREATE TABLE IF NOT EXISTS m30_stock (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  quantite INTEGER NOT NULL DEFAULT 0,
  quantite_minimale INTEGER DEFAULT 1,
  quantite_maximale INTEGER,
  emplacement TEXT,
  zone TEXT,
  code_barre TEXT UNIQUE,
  date_maj TEXT NOT NULL DEFAULT (datetime('now')),
  note TEXT
);

-- M31 · Alertes
CREATE TABLE IF NOT EXISTS m31_alerte (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  type_alerte TEXT CHECK (type_alerte IN ('manquant','trop','expiration')),
  seuil INTEGER NOT NULL,
  active INTEGER NOT NULL DEFAULT 1,
  derniere_alerte TEXT,
  note TEXT
);

-- M32 · Scan QR
CREATE TABLE IF NOT EXISTS m32_scan (
  id INTEGER PRIMARY KEY,
  code TEXT NOT NULL,
  piece_id INTEGER REFERENCES piece(id),
  emplacement TEXT,
  date_scan TEXT NOT NULL DEFAULT (datetime('now')),
  utilisateur TEXT
);

-- M33 · Entrées/sorties
CREATE TABLE IF NOT EXISTS m33_mouvement (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('entree','sortie','retour','perte','vente','don')),
  quantite INTEGER NOT NULL,
  date TEXT NOT NULL DEFAULT (datetime('now')),
  source TEXT,
  destination TEXT,
  reference TEXT,
  note TEXT
);

-- M34 · Doublons
CREATE TABLE IF NOT EXISTS m34_doublon (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  statut TEXT CHECK (statut IN ('a_conserver','a_vendre','a_echanger','a_donner')),
  prix_estime REAL,
  note TEXT
);

-- M35 · Inventaire
CREATE TABLE IF NOT EXISTS m35_inventaire (
  id INTEGER PRIMARY KEY,
  date TEXT NOT NULL DEFAULT (datetime('now')),
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  quantite_theorique INTEGER NOT NULL,
  quantite_reelle INTEGER NOT NULL,
  ecart INTEGER,
  responsable TEXT,
  note TEXT
);

-- M36 · Achats
CREATE TABLE IF NOT EXISTS m36_achat (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  fournisseur TEXT,
  prix_unitaire REAL,
  devise TEXT DEFAULT 'EUR',
  quantite INTEGER NOT NULL,
  date_achat TEXT NOT NULL DEFAULT (datetime('now')),
  facture TEXT,
  note TEXT
);
