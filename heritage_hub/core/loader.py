# heritage_hub/core/loader.py
import importlib
import os

MODULES_DIR = "modules"
MODULES_ACTIFS = [
    "m1_planches",
    "m2_equivalences",
    # "m3_veille",
    # "m4_chantier",
    # "m5_reproduction_3d",
    # "m6_moderation",
    # ... à activer au fur et à mesure
]

def charger_modules():
    """Charge et initialise les modules actifs."""
    for nom_module in MODULES_ACTIFS:
        try:
            module = importlib.import_module(f"heritage_hub.modules.{nom_module}")
            if hasattr(module, "install"):
                module.install()
            if hasattr(module, "run"):
                module.run()
            print(f"✅ Module {nom_module} chargé")
        except ImportError as e:
            print(f"❌ Import {nom_module}: {e}")
        except Exception as e:
            print(f"❌ Erreur {nom_module}: {e}")
