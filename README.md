# 📚 LearnTheCharacters - Community Decks

Bienvenue dans le repository communautaire de decks pour **LearnTheCharacters**!

Ce repository contient des collections de caractères chinois organisées en "decks" thématiques que vous pouvez importer directement dans l'application.

## 🎯 Qu'est-ce qu'un Deck?

Un **deck** est une collection de caractères chinois organisée autour d'un thème ou d'un niveau de difficulté. Chaque deck contient:
- Les caractères chinois (simplifiés et traditionnels)
- La prononciation en pinyin
- Les traductions en français
- Des exemples d'utilisation
- Des mnémoniques pour faciliter l'apprentissage

## 📖 Documentation

- **[DECK_CREATION_GUIDE.md](./DECK_CREATION_GUIDE.md)** - Guide complet pour créer un deck (⚠️ **LIRE EN PREMIER!**)
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Comment contribuer au repository
- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - URLs et références rapides
- **[schema.json](./schema.json)** - Schéma JSON de validation

## 📂 Structure du Repository

```
LearnTheCharacters-Decks/
├── README.md
├── CONTRIBUTING.md
├── DECK_CREATION_GUIDE.md      # ⚠️ GUIDE PRINCIPAL
├── QUICK_REFERENCE.md
├── LICENSE
├── schema.json                 # Schéma JSON pour validation
├── decks/
│   ├── hsk1/                   # Decks HSK niveau 1
│   │   ├── basic-verbs.json
│   │   ├── numbers.json
│   │   ├── family.json
│   │   └── pronouns.json
│   ├── hsk2/                   # Decks HSK niveau 2
│   ├── hsk3/                   # Decks HSK niveau 3
│   ├── thematic/               # Decks thématiques
│   │   ├── restaurant.json
│   │   ├── travel.json
│   │   ├── business.json
│   │   ├── shopping.json
│   │   └── daily-life.json
│   └── community/              # Decks créés par la communauté
│       └── README.md
└── tools/
    └── validate-deck.py        # Script de validation
```

## 🚀 Comment utiliser un Deck?

### Méthode 1: Import depuis URL (Recommandé)

1. Ouvrez l'app **LearnTheCharacters**
2. Allez dans **"Importer un Deck"**
3. Collez l'URL du deck que vous voulez importer:
   ```
   https://raw.githubusercontent.com/YOUR_USERNAME/LearnTheCharacters-Decks/main/decks/hsk1/basic-verbs.json
   ```
4. Appuyez sur "Télécharger"

### Méthode 2: Téléchargement manuel

1. Téléchargez le fichier `.json` du deck
2. Utilisez AirDrop, email, ou iCloud pour l'envoyer sur votre iPhone
3. Ouvrez le fichier avec **LearnTheCharacters**
4. Le deck sera automatiquement importé

## 📋 Decks Disponibles

### HSK Niveau 1 (150 caractères)
- **basic-verbs.json** - Verbes de base (être, avoir, aller, venir, etc.) - 20 caractères
- **numbers.json** - Nombres de 0 à 100 - 15 caractères
- **family.json** - Membres de la famille - 12 caractères
- **pronouns.json** - Pronoms personnels - 8 caractères

### Thématiques
- **restaurant.json** - Vocabulaire du restaurant - 50 caractères
- **travel.json** - Vocabulaire du voyage - 60 caractères
- **business.json** - Vocabulaire des affaires - 40 caractères
- **shopping.json** - Vocabulaire des courses - 35 caractères
- **daily-life.json** - Vie quotidienne - 45 caractères

## 🤝 Contribuer

Vous voulez partager votre propre deck avec la communauté? Super!

### Étapes pour contribuer:

1. **Créez votre deck dans l'app**
2. **Exportez-le en JSON** (Menu → Exporter le deck)
3. **Forkez ce repository**
4. **Ajoutez votre deck** dans le dossier approprié:
   - `decks/hsk1/`, `decks/hsk2/`, etc. pour les decks HSK officiels
   - `decks/thematic/` pour les decks thématiques généraux
   - `decks/community/` pour vos créations personnelles
5. **Validez le format** avec le script de validation:
   ```bash
   python tools/validate-deck.py decks/community/mon-deck.json
   ```
6. **Créez une Pull Request** avec:
   - Le fichier JSON de votre deck
   - Une description claire du contenu
   - Le nombre de caractères
   - Le niveau recommandé

### Règles de contribution:

✅ **À faire:**
- Vérifier que tous les caractères ont une traduction française
- Inclure le pinyin avec les tons
- Ajouter des exemples d'utilisation
- Tester le deck dans l'app avant de contribuer
- Utiliser un nom de fichier descriptif (en minuscules, avec tirets)

❌ **À éviter:**
- Dupliquer des decks existants
- Inclure du contenu offensant
- Uploader des fichiers corrompus
- Copier du contenu protégé par droits d'auteur

## 📝 Format JSON

Voici un exemple de structure de deck:

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Verbes de Base",
  "description": "Les 20 verbes les plus utilisés en chinois mandarin",
  "category": "HSK1",
  "version": "1.0",
  "author": "Votre Nom",
  "createdDate": "2025-11-17T10:00:00Z",
  "characters": [
    {
      "id": "...",
      "simplified": "是",
      "traditional": "是",
      "pinyin": "shì",
      "meaning": ["être", "oui"],
      "frequency": 1,
      "hskLevel": 1,
      "examples": [
        "我是学生 (Wǒ shì xuéshēng) - Je suis étudiant"
      ],
      "mnemonics": "Pensez au soleil (日) au-dessus de la terre"
    }
  ]
}
```

Consultez `schema.json` pour la spécification complète.

## 🔍 Validation

Avant de contribuer, validez votre deck:

```bash
# Installer les dépendances
pip install jsonschema

# Valider un deck
python tools/validate-deck.py votre-deck.json
```

## 📊 Statistiques

- **Total de decks:** 15+
- **Total de caractères:** 500+
- **Contributeurs:** En croissance!
- **Langues supportées:** Chinois → Français

## 🌟 Decks Populaires

1. **HSK1 Complete** - Collection complète HSK niveau 1 (150 caractères)
2. **Restaurant Survival** - Survivre au restaurant en Chine (50 caractères)
3. **Travel Essentials** - L'essentiel pour voyager (60 caractères)

## 📬 Contact & Support

- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/LearnTheCharacters-Decks/issues)
- **Discussions:** [GitHub Discussions](https://github.com/YOUR_USERNAME/LearnTheCharacters-Decks/discussions)
- **Email:** support@charactercards.app

## 📜 Licence

Ce repository est sous licence **MIT**. Vous êtes libre de:
- Utiliser les decks dans vos projets personnels
- Modifier et créer des dérivés
- Partager avec attribution

Voir [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

Merci à tous les contributeurs qui partagent leurs decks avec la communauté!

- [@contributor1](https://github.com/contributor1) - Restaurant deck
- [@contributor2](https://github.com/contributor2) - Travel deck
- Et vous? 😊

---

**Note:** Ce repository est un projet communautaire indépendant. Les decks sont créés et partagés par des utilisateurs de l'application LearnTheCharacters.

---

Made with ❤️ by the LearnTheCharacters Community
