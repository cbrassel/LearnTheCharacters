# 🔗 Référence Rapide - URLs des Decks

## 📚 Decks Disponibles

### HSK Niveau 1

#### Verbes de Base (20 caractères)
```
https://raw.githubusercontent.com/cbrassel/LearnTheCharacters-Decks/main/decks/hsk1/basic-verbs.json
```
Contenu: être, avoir, aller, venir, voir, écouter, dire, manger, boire, faire, acheter, vendre, étudier, travailler, habiter, s'asseoir, se tenir debout, marcher, courir, dormir

---

### Thématiques

#### Restaurant (20 caractères)
```
https://raw.githubusercontent.com/cbrassel/LearnTheCharacters-Decks/main/decks/thematic/restaurant.json
```
Contenu: riz, plat, viande, poisson, poulet, eau, thé, café, bière, nouilles, soupe, raviolis, brioche, sucre, sel, épicé, serveur, menu, baguettes, addition

---

## 🔧 Comment Utiliser ces URLs

### Dans l'Application

1. Ouvrir **LearnTheCharacters**
2. Aller dans **"Importer un Deck"**
3. **Copier-coller** l'URL
4. Cliquer **"Télécharger"**
5. Le deck s'importe automatiquement!

### En Développement

```swift
let url = "https://raw.githubusercontent.com/cbrassel/LearnTheCharacters-Decks/main/decks/hsk1/basic-verbs.json"
let deck = try await DeckImportExportService.shared.importDeckFromURL(url)
```

### Via cURL (Test)

```bash
curl -H "Authorization: Bearer VOTRE_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://raw.githubusercontent.com/cbrassel/LearnTheCharacters-Decks/main/decks/hsk1/basic-verbs.json
```

---

## 📋 Format des URLs

### Structure Générale
```
https://raw.githubusercontent.com/cbrassel/LearnTheCharacters-Decks/main/decks/{category}/{filename}.json
```

### Catégories Disponibles
- `hsk1` - Caractères HSK niveau 1
- `hsk2` - Caractères HSK niveau 2
- `hsk3` - Caractères HSK niveau 3
- `thematic` - Decks thématiques
- `community` - Contributions communautaires

### Exemples
```
/decks/hsk1/basic-verbs.json
/decks/hsk1/numbers.json
/decks/hsk2/adjectives.json
/decks/thematic/restaurant.json
/decks/thematic/travel.json
/decks/community/user-contributed.json
```

---

## 🌐 URLs de l'API GitHub

### Lister les fichiers d'une catégorie

**HSK1:**
```
https://api.github.com/repos/cbrassel/LearnTheCharacters-Decks/contents/decks/hsk1
```

**Thematic:**
```
https://api.github.com/repos/cbrassel/LearnTheCharacters-Decks/contents/decks/thematic
```

**Community:**
```
https://api.github.com/repos/cbrassel/LearnTheCharacters-Decks/contents/decks/community
```

### Authentification Requise

Headers nécessaires:
```
Authorization: Bearer github_pat_11ABEJ6SY0...
Accept: application/vnd.github.v3+json
X-GitHub-Api-Version: 2022-11-28
```

---

## 🚀 Liens Rapides

### Documentation
- **Repository:** https://github.com/cbrassel/LearnTheCharacters-Decks
- **README:** https://github.com/cbrassel/LearnTheCharacters-Decks/blob/main/README.md
- **Contributing:** https://github.com/cbrassel/LearnTheCharacters-Decks/blob/main/CONTRIBUTING.md
- **Schema:** https://github.com/cbrassel/LearnTheCharacters-Decks/blob/main/schema.json

### Navigation GitHub
- **Browse Decks:** https://github.com/cbrassel/LearnTheCharacters-Decks/tree/main/decks
- **HSK1 Folder:** https://github.com/cbrassel/LearnTheCharacters-Decks/tree/main/decks/hsk1
- **Thematic Folder:** https://github.com/cbrassel/LearnTheCharacters-Decks/tree/main/decks/thematic
- **Community Folder:** https://github.com/cbrassel/LearnTheCharacters-Decks/tree/main/decks/community

### Issues & Discussions
- **Report Issue:** https://github.com/cbrassel/LearnTheCharacters-Decks/issues/new
- **Discussions:** https://github.com/cbrassel/LearnTheCharacters-Decks/discussions

---

## 💡 Raccourcis Code

### Configuration dans le Code

```swift
// Toutes ces URLs sont générées automatiquement via GitHubConfiguration

// URL d'un deck spécifique
let url = GitHubConfiguration.deckURL(category: "hsk1", filename: "basic-verbs.json")

// URL de l'API pour une catégorie
let apiURL = GitHubConfiguration.apiURL(forCategory: "thematic")

// Requête authentifiée
let request = GitHubConfiguration.authenticatedRequest(url: url)
```

### Import Rapide

```swift
// Import direct
let deck = try await DeckImportExportService.shared.importDeckFromURL(
    GitHubConfiguration.deckURL(category: "hsk1", filename: "basic-verbs.json")
)

// Lister tous les decks d'une catégorie
let decks = try await DeckImportExportService.shared.fetchAvailableDecks(category: "thematic")

// Lister TOUTES les catégories
let allDecks = try await DeckImportExportService.shared.fetchAllCategories()
```

---

## 📊 Statistiques Actuelles

- **Total decks:** 2
- **Total caractères:** 40
- **Catégories:** 2 (HSK1, Thematic)
- **Contributeurs:** 1 (LearnTheCharacters Community)

---

## 🔄 Mise à Jour

Ce fichier sera mis à jour à chaque ajout de nouveau deck.

**Dernière mise à jour:** 17 novembre 2025

---

**Besoin d'un deck qui n'existe pas?** [Créez une Issue](https://github.com/cbrassel/LearnTheCharacters-Decks/issues/new) ou contribuez!
