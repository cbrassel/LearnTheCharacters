# 🤝 Guide de Contribution

Merci de vouloir contribuer au repository **LearnTheCharacters-Decks**!

## 📝 Comment créer un bon Deck?

### 1. Choisir un thème cohérent

Votre deck doit avoir un thème clair:
- ✅ "Vocabulaire du médecin" - Thème précis
- ✅ "HSK2 - Adjectifs" - Catégorie claire
- ❌ "Caractères aléatoires" - Trop vague
- ❌ "Mes favoris" - Pas assez descriptif

### 2. Sélectionner des caractères pertinents

- **Quantité:** Entre 10 et 100 caractères par deck
- **Qualité:** Préférez la pertinence à la quantité
- **Cohérence:** Tous les caractères doivent être liés au thème

### 3. Fournir des informations complètes

Chaque caractère doit avoir:
- ✅ Forme simplifiée (obligatoire)
- ✅ Pinyin avec tons (obligatoire)
- ✅ Au moins une traduction française (obligatoire)
- ✅ Au moins un exemple d'utilisation (recommandé)
- ⚠️ Forme traditionnelle (optionnel)
- ⚠️ Mnémonique (optionnel mais apprécié)

## 🔧 Processus de Contribution

### Étape 1: Créer votre deck dans l'app

1. Ouvrez **LearnTheCharacters**
2. Allez dans **"Créer un Deck"**
3. Ajoutez vos caractères
4. Testez le deck en jouant quelques sessions
5. Exportez en JSON

### Étape 2: Préparer votre contribution

```bash
# Fork le repository
git clone https://github.com/VOTRE_USERNAME/LearnTheCharacters-Decks.git
cd LearnTheCharacters-Decks

# Créer une branche
git checkout -b add-mon-nouveau-deck

# Ajouter votre deck dans le bon dossier
# decks/hsk1/, decks/thematic/, ou decks/community/
```

### Étape 3: Valider votre deck

```bash
# Installer les dépendances
pip install jsonschema

# Valider le format JSON
python tools/validate-deck.py decks/community/mon-deck.json

# Vérifier qu'il n'y a pas d'erreurs
```

### Étape 4: Commit et Push

```bash
git add decks/community/mon-deck.json
git commit -m "feat: ajout du deck 'Mon Nouveau Deck' avec 30 caractères sur [thème]"
git push origin add-mon-nouveau-deck
```

### Étape 5: Créer une Pull Request

1. Allez sur GitHub
2. Créez une Pull Request depuis votre branche
3. Remplissez le template de PR:

```markdown
## Description
Deck sur le thème des [thème]

## Détails
- **Nombre de caractères:** 30
- **Niveau:** HSK2
- **Catégorie:** Thématique
- **Testé dans l'app:** Oui

## Checklist
- [x] Format JSON valide
- [x] Tous les caractères ont une traduction
- [x] Pinyin avec tons inclus
- [x] Testé dans l'app
- [x] Nom de fichier descriptif
```

## ✅ Standards de Qualité

### Nommage des fichiers

```
✅ restaurant-basics.json
✅ hsk2-verbs.json
✅ business-meetings.json

❌ Deck1.json
❌ MyDeck.json
❌ caractères chinois.json (pas d'espaces ou accents)
```

### Format du JSON

```json
{
  "id": "uuid-valide",
  "name": "Nom Court et Descriptif",
  "description": "Description détaillée en 1-2 phrases maximum",
  "category": "HSK1|HSK2|HSK3|Custom|Thematic",
  "version": "1.0",
  "author": "Votre Nom ou Pseudo",
  "createdDate": "2025-11-17T10:00:00Z",
  "characters": [...]
}
```

### Qualité des traductions

```json
✅ "meaning": ["manger", "nourriture", "repas"]
✅ "meaning": ["grand", "gros"]

❌ "meaning": ["manger/nourriture/repas"]  // Pas de slash
❌ "meaning": ["Grand"]  // Majuscule inappropriée
❌ "meaning": []  // Vide interdit
```

### Exemples d'utilisation

```json
✅ "examples": [
  "我吃饭 (Wǒ chī fàn) - Je mange",
  "吃早饭 (chī zǎofàn) - Prendre le petit-déjeuner"
]

❌ "examples": ["我吃饭"]  // Manque la prononciation et la traduction
```

## 🎯 Types de Contributions Acceptées

### 🟢 Hautement Encouragées

- Decks HSK officiels (niveaux 1-6)
- Decks thématiques utiles (voyage, restaurant, business)
- Corrections de bugs dans les decks existants
- Améliorations des traductions
- Ajout d'exemples manquants

### 🟡 Acceptées sous Conditions

- Decks de niche (doivent être bien documentés)
- Decks de grande taille (>100 caractères, doivent être justifiés)
- Decks en langues autres que français (pour futures extensions)

### 🔴 Non Acceptées

- Decks avec contenu offensant
- Decks dupliqués sans amélioration
- Decks générés automatiquement sans vérification
- Contenu protégé par droits d'auteur sans permission
- Decks de test ou de démo

## 🐛 Reporter un Bug

Si vous trouvez une erreur dans un deck existant:

1. Ouvrez une **Issue** sur GitHub
2. Indiquez:
   - Le nom du fichier du deck
   - Le caractère problématique
   - La nature de l'erreur
   - La correction proposée

Exemple:
```
**Deck:** hsk1/basic-verbs.json
**Caractère:** 是
**Erreur:** Traduction incorrecte
**Correction proposée:** "être" au lieu de "avoir"
```

## 🏆 Devenir Contributeur Régulier

Si vous contribuez régulièrement avec des decks de qualité, nous vous ajouterons:
- Dans la section "Remerciements" du README
- Comme collaborateur du repository
- Dans les crédits de l'application

## 📚 Ressources Utiles

### Dictionnaires

- [MDBG Chinese Dictionary](https://www.mdbg.net/)
- [Pleco](https://www.pleco.com/)
- [CC-CEDICT](https://cc-cedict.org/)

### Outils HSK

- [HSK Academy](https://www.hskhsk.com/)
- [HSK Vocabulary Lists](https://www.digmandarin.com/hsk-vocabulary-list.html)

### Pinyin

- [Pinyin Converter](https://www.pinyinput.com/)
- [Chinese Tone Trainer](https://www.dong-chinese.com/learn/sounds/tones)

## 💬 Besoin d'Aide?

- **Questions:** [GitHub Discussions](https://github.com/YOUR_USERNAME/LearnTheCharacters-Decks/discussions)
- **Bugs:** [GitHub Issues](https://github.com/YOUR_USERNAME/LearnTheCharacters-Decks/issues)
- **Email:** support@charactercards.app

## 🙏 Merci!

Chaque contribution aide des milliers d'apprenants à maîtriser le chinois. Merci de faire partie de cette communauté! 🎉

---

**Code of Conduct:** Soyez respectueux, constructif, et bienveillant avec les autres contributeurs.
