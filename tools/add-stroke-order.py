#!/usr/bin/env python3
"""
Script pour ajouter les données stroke order de Make Me a Hanzi aux fichiers JSON des decks.
Usage: python3 add-stroke-order.py <deck-file.json>

Prérequis:
1. Cloner Make Me a Hanzi: git clone https://github.com/skishore/makemeahanzi.git
2. Le dossier makemeahanzi/ doit être au même niveau que tools/
"""

import json
import sys
from pathlib import Path

def load_makemeahanzi_data(graphics_file: str) -> dict:
    """Charger graphics.txt et créer un mapping caractère -> données de traits"""
    stroke_data = {}
    print(f"📖 Lecture de {graphics_file}...")

    with open(graphics_file, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f, 1):
            if not line.strip():
                continue
            try:
                data = json.loads(line)
                char = data['character']

                # Convertir medians en format [[x,y], [x,y], ...]
                medians = []
                if 'medians' in data:
                    for stroke_median in data['medians']:
                        medians.append([[pt[0], pt[1]] for pt in stroke_median])

                stroke_data[char] = {
                    'strokes': data['strokes'],
                    'medians': medians if medians else None,
                    'source': 'makemeahanzi',
                    'viewBox': {'width': 1024, 'height': 1024}
                }
            except json.JSONDecodeError as e:
                print(f"⚠️  Erreur ligne {line_num}: {e}")
                continue

    print(f"✅ {len(stroke_data)} caractères chargés")
    return stroke_data

def update_deck_with_strokes(deck_path: str, stroke_data: dict):
    """Ajouter le champ strokeOrder à chaque caractère dans le deck"""
    print(f"\n📝 Mise à jour de {deck_path}...")

    with open(deck_path, 'r', encoding='utf-8') as f:
        deck = json.load(f)

    updated_count = 0
    missing_chars = []

    for char in deck['characters']:
        simplified = char['simplified']
        if simplified in stroke_data:
            char['strokeOrder'] = stroke_data[simplified]
            updated_count += 1
            print(f"  ✓ {simplified}")
        else:
            missing_chars.append(simplified)
            print(f"  ✗ {simplified} (données manquantes)")

    # Sauvegarder le deck mis à jour
    with open(deck_path, 'w', encoding='utf-8') as f:
        json.dump(deck, f, ensure_ascii=False, indent=2)

    print(f"\n✅ {updated_count} caractères mis à jour")
    if missing_chars:
        print(f"⚠️  Données manquantes pour : {', '.join(missing_chars)}")
        print(f"   ({len(missing_chars)} caractères)")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 add-stroke-order.py <deck-file.json>")
        print("\nExemple:")
        print("  python3 add-stroke-order.py decks/community/nombres-0-20.json")
        sys.exit(1)

    # Vérifier que graphics.txt existe
    graphics_file = Path(__file__).parent.parent / 'makemeahanzi' / 'graphics.txt'

    if not graphics_file.exists():
        print(f"❌ {graphics_file} introuvable.")
        print("\nPour obtenir les données:")
        print("  cd /Users/cbrassel/Projet/LearnTheCharacters/LearnTheCharacters-Decks-Repo")
        print("  git clone https://github.com/skishore/makemeahanzi.git")
        sys.exit(1)

    deck_file = sys.argv[1]
    deck_path = Path(deck_file)

    if not deck_path.exists():
        print(f"❌ Deck introuvable: {deck_file}")
        sys.exit(1)

    # Charger les données de Make Me a Hanzi
    stroke_data = load_makemeahanzi_data(str(graphics_file))

    # Mettre à jour le deck
    update_deck_with_strokes(str(deck_path), stroke_data)

    print("\n✅ Terminé !")

if __name__ == '__main__':
    main()
