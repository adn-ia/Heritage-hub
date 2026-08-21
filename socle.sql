-- Heritage Hub — Socle
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS catalogue (
  id INTEGER PRIMARY KEY,
  nom TEXT NOT NULL,
  marque TEXT NOT NULL,
  edition TEXT,
  annee_debut INTEGER,
  annee_fin INTEGER,
  note TEXT
);

CREATE TABLE IF NOT EXISTS modele (
  id INTEGER PRIMARY KEY,
  catalogue_id INTEGER NOT NULL REFERENCES catalogue(id),
  nom TEXT NOT NULL,
  annee_debut INTEGER,
  annee_fin INTEGER,
  note TEXT
);

CREATE TABLE IF NOT EXISTS planche (
  id INTEGER PRIMARY KEY,
  catalogue_id INTEGER NOT NULL REFERENCES catalogue(id),
  numero TEXT NOT NULL,
  titre TEXT NOT NULL,
  ensemble TEXT,
  page INTEGER,
  note TEXT
);

CREATE TABLE IF NOT EXISTS piece (
  id INTEGER PRIMARY KEY,
  catalogue_id INTEGER NOT NULL REFERENCES catalogue(id),
  reference TEXT NOT NULL,
  designation TEXT NOT NULL,
  matiere TEXT,
  masse_g REAL,
  normalisee INTEGER NOT NULL DEFAULT 0,
  note TEXT
);

CREATE TABLE IF NOT EXISTS nomenclature (
  id INTEGER PRIMARY KEY,
  planche_id INTEGER NOT NULL REFERENCES planche(id) ON DELETE CASCADE,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  repere TEXT NOT NULL,
  quantite INTEGER NOT NULL DEFAULT 1,
  observation TEXT,
  UNIQUE(planche_id, repere)
);

CREATE TABLE IF NOT EXISTS applicabilite (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id),
  modele_id INTEGER NOT NULL REFERENCES modele(id),
  serie TEXT,
  no_chassis_debut TEXT,
  no_chassis_fin TEXT,
  date_debut TEXT,
  date_fin TEXT,
  condition TEXT,
  note TEXT
);

CREATE TABLE IF NOT EXISTS cote (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER NOT NULL REFERENCES piece(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('dimension','filetage','couple','jeu','tolerance','matiere_durete')),
  nom TEXT NOT NULL,
  valeur REAL,
  mini REAL,
  maxi REAL,
  unite TEXT,
  source TEXT NOT NULL CHECK (source IN ('catalogue','manuel_atelier','releve_atelier','club','deduit')),
  confiance INTEGER NOT NULL DEFAULT 3,
  note TEXT
);

CREATE TABLE IF NOT EXISTS media (
  id INTEGER PRIMARY KEY,
  piece_id INTEGER REFERENCES piece(id) ON DELETE CASCADE,
  planche_id INTEGER REFERENCES planche(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('scan_planche','photo','mesh','cao','stl','step','pdf')),
  chemin TEXT NOT NULL,
  largeur_px INTEGER,
  hauteur_px INTEGER,
  licence TEXT NOT NULL DEFAULT 'usage_prive',
  auteur TEXT,
  ajoute_le TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS traduction (
  id INTEGER PRIMARY KEY,
  table_name TEXT NOT NULL,
  record_id INTEGER NOT NULL,
  langue TEXT NOT NULL,
  champ TEXT NOT NULL,
  valeur TEXT NOT NULL,
  UNIQUE(table_name, record_id, langue, champ)
);
