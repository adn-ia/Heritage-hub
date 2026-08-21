# Heritage-hub
Heritage Hub — Modular, open-source, offline-first platform for managing parts catalogs, technical plates, 3D models, and restoration projects. Core + modules, multi-model, multi-language
## Philosophy

- **Core + modules**: The core is stable. Modules can be added or removed without breaking anything.
- **Multi-model**: Adaptable to any brand (Peugeot, Citroën, Renault, Ferrari, tractor, motorcycle…).
- **Multi-language**: No language is a key — translations are stored externally in a `traduction` table.
- **Offline-first**: Works without an internet connection (except optional M10 module).
- **Copyright safe**: Scans are never redistributed — only factual data (references, designations, coordinates) is shared.

## Modules (M1 to M34)

| Module | Function |
|---|---|
| M1 | Clickable plates |
| M2 | Modern equivalents |
| M3 | Market watch |
| M4 | Workshop logbook |
| M5 | 3D reproduction |
| M6 | Moderation & contributions |
| M7 | Directory |
| M8 | AI search |
| M9 | Cart & purchases |
| M10 | Collector & feed |
| M11 | Automatic backup |
| M12 | CAD integration |
| M13 | Parts versioning |
| M14 | Audit history |
| M15 | Mass import |
| M16 | Visual search |
| M18 | Data quality |
| M19 | Tips & techniques |
| M20 | Cross-references & adaptations |
| M21 | External resources |
| M22 | Events & gatherings |
| M23 | Document repository |
| M24 | Experience sharing (restoration logbook) |
| M26 | Photo gallery (community showcase) |
| M27 | Terms & GDPR |
| M28 | Support & reporting |
| M29 | Credits & licenses |
| M30 | Stock & locations |
| M31 | Stock alerts |
| M32 | QR / barcode scanning |
| M33 | Stock entries & exits |
| M34 | Duplicates & surplus parts |
| M35 | Inventory & audit |
| M36 | Purchase history & suppliers |

## Installation

```bash
git clone https://github.com/your-username/Heritage-hub.git
cd Heritage-hub
python3 -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
python3 scripts/init_db.py
python3 heritage_hub/server.py
