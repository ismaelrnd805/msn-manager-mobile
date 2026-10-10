#!/usr/bin/env python3
"""Patch idempotent du manifeste Android généré par `flutter create`.

- Ajoute la permission INTERNET (absente du template en release ;
  l'app synchronise avec le serveur Laravel, spéc. §8).
- Force le libellé applicatif « MSN Manager ».
"""
import re
import sys
from pathlib import Path

MANIFESTE = Path(__file__).resolve().parents[2] / "apps" / "mobile" / "android" / "app" / "src" / "main" / "AndroidManifest.xml"


def main() -> int:
    if not MANIFESTE.exists():
        print(f"!! manifeste introuvable : {MANIFESTE}")
        return 1
    texte = MANIFESTE.read_text(encoding="utf-8")

    # 1. Permission INTERNET (une seule fois)
    if "android.permission.INTERNET" not in texte:
        texte = re.sub(
            r"(<manifest[^>]*>)",
            r'\1\n    <uses-permission android:name="android.permission.INTERNET"/>',
            texte,
            count=1,
        )
        print("  + uses-permission INTERNET")
    else:
        print("  = INTERNET déjà présent")

    # 2. Libellé « MSN Manager »
    texte, n = re.subn(
        r'android:label="[^"]*"',
        'android:label="MSN Manager"',
        texte,
        count=1,
    )
    print(f"  {'~' if n else '='} libellé {'appliqué' if n else 'déjà correct'}")

    MANIFESTE.write_text(texte, encoding="utf-8")
    print(f"OK {MANIFESTE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
