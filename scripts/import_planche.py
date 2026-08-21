#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from heritage_hub.modules.m1_planches.import import importer_zones

if len(sys.argv) < 2:
    print("Usage: python scripts/import_planche.py chemin/vers/fichier.json [numero_planche]")
    sys.exit(1)

json_path = sys.argv[1]
planche_num = sys.argv[2] if len(sys.argv) > 2 else "1"

importer_zones(json_path, planche_num)
