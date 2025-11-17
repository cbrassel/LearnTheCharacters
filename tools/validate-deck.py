#!/usr/bin/env python3
"""
Script de validation pour les decks LearnTheCharacters
Usage: python validate-deck.py path/to/deck.json
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Any
import re

def validate_uuid(uuid_string: str) -> bool:
    """Valide le format UUID"""
    uuid_pattern = re.compile(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        re.IGNORECASE
    )
    return bool(uuid_pattern.match(uuid_string))

def validate_deck_structure(deck: Dict[str, Any]) -> List[str]:
    """Valide la structure du deck"""
    errors = []

    # Champs obligatoires
    required_fields = ['id', 'name', 'description', 'category', 'version', 'createdDate', 'characters']
    for field in required_fields:
        if field not in deck:
            errors.append(f"❌ Champ obligatoire manquant: {field}")

    # Validation de l'ID
    if 'id' in deck and not validate_uuid(deck['id']):
        errors.append(f"❌ ID invalide: {deck['id']}")

    # Validation du nom
    if 'name' in deck:
        if len(deck['name']) < 3:
            errors.append(f"❌ Nom trop court: {deck['name']} (minimum 3 caractères)")
        if len(deck['name']) > 100:
            errors.append(f"❌ Nom trop long: {deck['name']} (maximum 100 caractères)")

    # Validation de la description
    if 'description' in deck:
        if len(deck['description']) < 10:
            errors.append(f"❌ Description trop courte (minimum 10 caractères)")
        if len(deck['description']) > 500:
            errors.append(f"❌ Description trop longue (maximum 500 caractères)")

    # Validation de la catégorie
    valid_categories = ['HSK1', 'HSK2', 'HSK3', 'HSK4', 'HSK5', 'HSK6', 'Thematic', 'Custom']
    if 'category' in deck and deck['category'] not in valid_categories:
        errors.append(f"❌ Catégorie invalide: {deck['category']} (doit être l'une de: {', '.join(valid_categories)})")

    # Validation de la version
    if 'version' in deck:
        version_pattern = re.compile(r'^\d+\.\d+$')
        if not version_pattern.match(deck['version']):
            errors.append(f"❌ Format de version invalide: {deck['version']} (doit être X.Y)")

    # Validation des caractères
    if 'characters' in deck:
        if not isinstance(deck['characters'], list):
            errors.append(f"❌ 'characters' doit être une liste")
        elif len(deck['characters']) == 0:
            errors.append(f"❌ Le deck doit contenir au moins 1 caractère")
        elif len(deck['characters']) > 500:
            errors.append(f"❌ Le deck contient trop de caractères: {len(deck['characters'])} (maximum 500)")
        else:
            char_errors = validate_characters(deck['characters'])
            errors.extend(char_errors)

    return errors

def validate_characters(characters: List[Dict[str, Any]]) -> List[str]:
    """Valide chaque caractère"""
    errors = []

    for idx, char in enumerate(characters, 1):
        char_id = f"Caractère #{idx}"

        # Champs obligatoires
        required_fields = ['id', 'simplified', 'pinyin', 'meaning', 'frequency']
        for field in required_fields:
            if field not in char:
                errors.append(f"❌ {char_id}: Champ obligatoire manquant: {field}")

        # Validation ID
        if 'id' in char and not validate_uuid(char['id']):
            errors.append(f"❌ {char_id}: ID invalide")

        # Validation du caractère simplifié
        if 'simplified' in char:
            if not char['simplified']:
                errors.append(f"❌ {char_id}: Le caractère simplifié est vide")
            if len(char['simplified']) > 10:
                errors.append(f"❌ {char_id}: Caractère simplifié trop long")

        # Validation du pinyin
        if 'pinyin' in char:
            if not char['pinyin']:
                errors.append(f"❌ {char_id}: Le pinyin est vide")
            if len(char['pinyin']) > 50:
                errors.append(f"❌ {char_id}: Pinyin trop long")

        # Validation des traductions
        if 'meaning' in char:
            if not isinstance(char['meaning'], list):
                errors.append(f"❌ {char_id}: 'meaning' doit être une liste")
            elif len(char['meaning']) == 0:
                errors.append(f"❌ {char_id}: Au moins une traduction est requise")
            else:
                for meaning in char['meaning']:
                    if not meaning or not isinstance(meaning, str):
                        errors.append(f"❌ {char_id}: Traduction invalide")

        # Validation de la fréquence
        if 'frequency' in char:
            if not isinstance(char['frequency'], int):
                errors.append(f"❌ {char_id}: La fréquence doit être un nombre entier")
            elif char['frequency'] < 1 or char['frequency'] > 10000:
                errors.append(f"❌ {char_id}: Fréquence hors limites (1-10000)")

        # Validation du niveau HSK (optionnel)
        if 'hskLevel' in char and char['hskLevel'] is not None:
            if not isinstance(char['hskLevel'], int):
                errors.append(f"❌ {char_id}: Le niveau HSK doit être un nombre entier")
            elif char['hskLevel'] < 1 or char['hskLevel'] > 6:
                errors.append(f"❌ {char_id}: Niveau HSK invalide (1-6)")

        # Validation des exemples (optionnel)
        if 'examples' in char and char['examples']:
            if not isinstance(char['examples'], list):
                errors.append(f"❌ {char_id}: 'examples' doit être une liste")
            elif len(char['examples']) > 5:
                errors.append(f"❌ {char_id}: Trop d'exemples (maximum 5)")

    return errors

def validate_deck_file(file_path: str) -> bool:
    """Valide un fichier de deck"""
    print(f"\n🔍 Validation de: {file_path}")
    print("-" * 60)

    # Vérifier que le fichier existe
    if not Path(file_path).exists():
        print(f"❌ Fichier introuvable: {file_path}")
        return False

    # Vérifier l'extension
    if not file_path.endswith('.json'):
        print(f"❌ Le fichier doit avoir l'extension .json")
        return False

    # Charger le JSON
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            deck = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ Erreur de parsing JSON: {e}")
        return False
    except Exception as e:
        print(f"❌ Erreur de lecture du fichier: {e}")
        return False

    # Valider la structure
    errors = validate_deck_structure(deck)

    # Afficher les résultats
    if errors:
        print(f"\n❌ {len(errors)} erreur(s) trouvée(s):\n")
        for error in errors:
            print(f"  {error}")
        print(f"\n❌ Validation échouée")
        return False
    else:
        # Afficher les statistiques
        print(f"✅ Structure valide")
        print(f"\n📊 Statistiques:")
        print(f"  • Nom: {deck['name']}")
        print(f"  • Catégorie: {deck['category']}")
        print(f"  • Nombre de caractères: {len(deck['characters'])}")
        print(f"  • Auteur: {deck.get('author', 'Non spécifié')}")
        print(f"  • Version: {deck['version']}")

        # Statistiques sur les caractères
        chars_with_examples = sum(1 for c in deck['characters'] if c.get('examples'))
        chars_with_mnemonics = sum(1 for c in deck['characters'] if c.get('mnemonics'))
        chars_with_traditional = sum(1 for c in deck['characters'] if c.get('traditional'))

        print(f"\n📝 Détails:")
        print(f"  • Caractères avec exemples: {chars_with_examples}/{len(deck['characters'])}")
        print(f"  • Caractères avec mnémoniques: {chars_with_mnemonics}/{len(deck['characters'])}")
        print(f"  • Caractères avec forme traditionnelle: {chars_with_traditional}/{len(deck['characters'])}")

        print(f"\n✅ Validation réussie!")
        return True

def main():
    """Point d'entrée principal"""
    if len(sys.argv) < 2:
        print("Usage: python validate-deck.py path/to/deck.json")
        sys.exit(1)

    file_path = sys.argv[1]
    success = validate_deck_file(file_path)

    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
