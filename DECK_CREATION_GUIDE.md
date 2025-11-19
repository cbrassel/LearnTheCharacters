# 📖 Guide Complet de Création de Deck

## ⚠️ IMPORTANT: Les UUID

### Qu'est-ce qu'un UUID ?

Un UUID (Universally Unique IDentifier) est un identifiant unique au format standardisé. Il doit respecter **EXACTEMENT** le format suivant :

```
XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

Où chaque `X` est un caractère **hexadécimal** : `0-9` ou `A-F` (majuscules ou minuscules)

### ✅ Exemples d'UUID VALIDES

```json
"id": "A1B2C3D4-5678-4ABC-9DEF-123456789ABC"
"id": "12345678-90AB-CDEF-1234-567890ABCDEF"
"id": "F9E8D7C6-B5A4-3210-9876-543210FEDCBA"
"id": "00000000-0000-0000-0000-000000000001"
```

### ❌ Exemples d'UUID INVALIDES

```json
❌ "id": "n01a1234-5678-4abc-9def-000000112233"  // 'n' n'est pas hexadécimal
❌ "id": "12345678-90ab-cdef-1234"                // Trop court
❌ "id": "12345678-90ab-cdef-1234-567890abcdefg" // 'g' n'est pas hexadécimal
❌ "id": "A1B2C3D4_5678_4ABC_9DEF_123456789ABC"  // Underscores au lieu de tirets
❌ "id": "A1B2C3D456784ABC9DEF123456789ABC"      // Manque les tirets
```

### 🔧 Comment Générer un UUID Valide ?

#### Option 1: En ligne de commande (Mac/Linux)
```bash
uuidgen
# Résultat: A1B2C3D4-5678-4ABC-9DEF-123456789ABC
```

#### Option 2: Python
```python
import uuid
print(str(uuid.uuid4()).upper())
# Résultat: F9E8D7C6-B5A4-3210-9876-543210FEDCBA
```

#### Option 3: Site web
- https://www.uuidgenerator.net/
- Copiez l'UUID Version 4 généré

#### Option 4: Dans le code Swift
```swift
import Foundation
let newUUID = UUID().uuidString
print(newUUID)  // Ex: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
```

### 🎯 UUID par Deck vs UUID par Caractère

**Chaque deck doit avoir un UUID unique:**
```json
{
  "id": "A1B2C3D4-5678-4ABC-9DEF-123456789ABC",  // UUID du deck
  "name": "Mon Deck",
  "characters": [...]
}
```

**Chaque caractère doit avoir un UUID unique:**
```json
{
  "characters": [
    {
      "id": "F9E8D7C6-B5A4-3210-9876-543210FEDCBA",  // UUID du caractère 1
      "simplified": "学"
    },
    {
      "id": "12345678-90AB-CDEF-1234-567890ABCDEF",  // UUID du caractère 2
      "simplified": "习"
    }
  ]
}
```

⚠️ **ATTENTION:** Ne réutilisez JAMAIS le même UUID pour deux decks ou deux caractères différents!

---

## 📋 Template de Deck Complet

Voici un template complet que vous pouvez copier et remplir :

```json
{
  "id": "GÉNÉREZ-UN-UUID-ICI",
  "name": "Nom Court et Descriptif",
  "description": "Description détaillée du contenu du deck en 1-2 phrases",
  "category": "HSK1",
  "version": "1.0",
  "author": "Votre Nom",
  "createdDate": "2025-11-19T10:00:00Z",
  "characters": [
    {
      "id": "GÉNÉREZ-UN-UUID-ICI",
      "simplified": "学",
      "traditional": "學",
      "pinyin": "xué",
      "meaning": ["apprendre", "étudier"],
      "frequency": 50,
      "hskLevel": 1,
      "examples": [
        "学习 (xuéxí) - étudier",
        "我学中文 (wǒ xué zhōngwén) - J'apprends le chinois"
      ],
      "mnemonics": "学 = enfant (子) sous un toit (⺍) qui apprend"
    }
  ]
}
```

---

## 🔍 Validation de votre Deck

### Étape 1: Vérifier le format JSON

```bash
# Installer jq (outil de validation JSON)
brew install jq

# Valider votre fichier
jq empty mon-deck.json

# Si pas d'erreur = JSON valide ✅
# Si erreur = corriger le JSON ❌
```

### Étape 2: Vérifier les UUID

```bash
# Vérifier que tous les UUID sont valides
grep -o '"id": "[^"]*"' mon-deck.json
```

Chaque UUID doit correspondre au pattern:
- 8 caractères hexadécimaux
- tiret
- 4 caractères hexadécimaux
- tiret
- 4 caractères hexadécimaux
- tiret
- 4 caractères hexadécimaux
- tiret
- 12 caractères hexadécimaux

### Étape 3: Valider avec le schéma

```bash
# Installer jsonschema (Python)
pip install jsonschema

# Valider votre deck
python -c "
import json
import jsonschema

with open('schema.json') as f:
    schema = json.load(f)

with open('mon-deck.json') as f:
    deck = json.load(f)

try:
    jsonschema.validate(deck, schema)
    print('✅ Deck valide!')
except jsonschema.exceptions.ValidationError as e:
    print(f'❌ Erreur: {e.message}')
"
```

---

## 📊 Checklist de Validation

Avant de soumettre votre deck, vérifiez:

### UUID
- [ ] Deck ID est un UUID valide (format: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX)
- [ ] Chaque caractère a un UUID unique et valide
- [ ] Tous les caractères hexadécimaux (0-9, A-F)
- [ ] Aucun UUID dupliqué dans le deck

### Métadonnées
- [ ] Nom du deck entre 3 et 100 caractères
- [ ] Description entre 10 et 500 caractères
- [ ] Catégorie valide (HSK1-6, Thematic, Custom)
- [ ] Version au format X.Y (ex: "1.0", "2.3")
- [ ] Date au format ISO 8601 (ex: "2025-11-19T10:00:00Z")

### Caractères
- [ ] Au moins 1 caractère, maximum 500
- [ ] Tous les caractères ont: id, simplified, pinyin, meaning, frequency
- [ ] Pinyin avec tons (ex: "xué", pas "xue")
- [ ] Au moins une traduction française par caractère
- [ ] Frequency entre 1 et 10000
- [ ] HSK level entre 1 et 6 (si applicable)

### Format
- [ ] JSON valide (pas d'erreur de syntaxe)
- [ ] Encodage UTF-8
- [ ] Nom de fichier sans espaces ni accents (ex: "mon-deck.json")
- [ ] Indentation propre (2 ou 4 espaces)

---

## 🛠️ Script de Génération d'UUID

Pour vous aider, voici un script qui génère tous les UUID nécessaires :

```bash
#!/bin/bash
# generate-uuids.sh

echo "Combien de caractères dans votre deck?"
read count

echo ""
echo "UUID du deck:"
uuidgen

echo ""
echo "UUID des caractères:"
for i in $(seq 1 $count); do
  echo "  Caractère $i: $(uuidgen)"
done
```

Utilisation:
```bash
chmod +x generate-uuids.sh
./generate-uuids.sh
```

---

## ❓ FAQ

### Q: Puis-je utiliser des UUID en minuscules ?
**R:** Oui, `a1b2c3d4-...` et `A1B2C3D4-...` sont tous deux valides.

### Q: Dois-je générer un nouvel UUID si je modifie mon deck ?
**R:** Non, gardez le même UUID de deck. Changez seulement la version (ex: 1.0 → 1.1).

### Q: Que faire si j'ai accidentellement utilisé le même UUID deux fois ?
**R:** Générez un nouveau UUID pour l'une des deux entités et remplacez-le.

### Q: Les UUID doivent-ils être en majuscules ?
**R:** Non, majuscules et minuscules sont acceptées. Par convention, on utilise souvent les majuscules.

### Q: Puis-je inventer un UUID "à la main" ?
**R:** Techniquement oui si vous respectez le format, mais il est **FORTEMENT RECOMMANDÉ** d'utiliser un générateur pour garantir l'unicité.

---

## 🚨 Erreurs Courantes et Solutions

### Erreur: "Attempted to decode UUID from invalid UUID string"

**Cause:** L'UUID contient des caractères non-hexadécimaux (G-Z) ou n'est pas au bon format.

**Solution:**
1. Vérifiez que tous les caractères sont 0-9, A-F
2. Vérifiez le format: 8-4-4-4-12 caractères séparés par des tirets
3. Régénérez l'UUID avec `uuidgen`

### Erreur: "Version must match pattern ^\d+\.\d+$"

**Cause:** La version n'est pas au format "X.Y"

**Solutions:**
- ✅ "1.0"
- ✅ "2.5"
- ❌ "1" (manque le .0)
- ❌ "v1.0" (pas de lettre)

### Erreur: "createdDate must be date-time format"

**Cause:** La date n'est pas au format ISO 8601

**Solutions:**
- ✅ "2025-11-19T10:30:00Z"
- ✅ "2025-11-19T10:30:00+01:00"
- ❌ "19/11/2025"
- ❌ "2025-11-19"

---

## 📞 Besoin d'Aide ?

Si vous rencontrez des problèmes:
1. Vérifiez cette documentation en détail
2. Utilisez le validateur JSON
3. Ouvrez une [Issue sur GitHub](https://github.com/cbrassel/LearnTheCharacters-Decks/issues)
4. Demandez dans les [Discussions](https://github.com/cbrassel/LearnTheCharacters-Decks/discussions)

---

**Dernière mise à jour:** 19 novembre 2025
