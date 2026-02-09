# CLAUDE.md - Configuration Projet CharacterCards iOS

## 📱 Vue d'ensemble du projet

**Nom du projet**: CharacterCards  
**Plateforme**: iOS 18+  
**Type**: Application éducative gamifiée  
**Objectif**: Apprentissage des caractères chinois (extensible aux caractères asiatiques)  
**Concept**: Jeu de cartes interactif avec reconnaissance vocale et IA

---

## 🎯 Objectifs principaux

1. **Apprentissage progressif** des caractères chinois via système de cartes
2. **Reconnaissance vocale** pour validation de la prononciation
3. **Synthèse vocale IA** pour génération automatique des sons
4. **Système de scoring** et progression personnalisée
5. **Création de decks personnalisés** par l'utilisateur
6. **Catégories thématiques** générées par IA

---

## 🏗️ Architecture technique

### Stack technologique

```yaml
Frontend:
  - SwiftUI (interface native iOS)
  - Combine (gestion état réactif)
  - AVFoundation (audio)
  
Backend:
  - CloudKit (synchronisation données)
  - Core Data (stockage local)
  
Services IA:
  - Speech Framework Apple (reconnaissance vocale)
  - AVSpeechSynthesizer (synthèse vocale de base)
  - OpenAI API ou Claude API (génération contenu)
  - Whisper API (reconnaissance vocale avancée)
  
Analytics:
  - Firebase Analytics
  - StoreKit 2 (monétisation future)
```

### Architecture modulaire

```
CharacterCards/
├── Core/
│   ├── Models/
│   │   ├── Character.swift
│   │   ├── Deck.swift
│   │   ├── UserProgress.swift
│   │   └── Category.swift
│   ├── Services/
│   │   ├── AudioService.swift
│   │   ├── AIService.swift
│   │   ├── SpeechRecognition.swift
│   │   └── DataPersistence.swift
│   └── Utils/
├── Features/
│   ├── Learning/
│   │   ├── CardGameView.swift
│   │   ├── CardViewModel.swift
│   │   └── TimerManager.swift
│   ├── DeckBuilder/
│   │   ├── DeckCreatorView.swift
│   │   └── CharacterSearchView.swift
│   ├── Progress/
│   │   ├── ScoreboardView.swift
│   │   └── StatisticsView.swift
│   └── Categories/
│       ├── CategoryListView.swift
│       └── CategoryDetailView.swift
├── Resources/
│   ├── Fonts/
│   ├── Sounds/
│   └── Animations/
└── App/
    ├── CharacterCardsApp.swift
    └── Configuration.swift
```

---

## 🎮 Fonctionnalités détaillées

### 1. Mode Apprentissage - Jeu de Cartes

```swift
struct GameSession {
    let timeLimit: TimeInterval = 10.0
    let deck: Deck
    let difficulty: Difficulty

    enum Difficulty {
        case consultation // 📖 Mode consultation (pas de chrono)
        case listening    // 👂 Mode écoute (pas de chrono)
        case writing      // ✍️ Mode écriture (pas de chrono)
        case beginner     // 🌱 30 secondes
        case intermediate // 🌿 20 secondes
    }
}
```

**Flux utilisateur:**
1. Affichage du caractère chinois (recto de la carte)
2. Chronomètre démarre
3. L'utilisateur prononce le caractère
4. Validation par reconnaissance vocale
5. Si temps écoulé → affichage automatique de la solution
6. Scoring basé sur rapidité et précision

### 2. Système de Reconnaissance Vocale

```swift
class SpeechRecognitionService {
    // Configuration pour chinois mandarin
    let locale = Locale(identifier: "zh-CN")
    
    // Validation prononciation avec score de confiance
    func validatePronunciation(
        expected: String,
        audioBuffer: AVAudioPCMBuffer
    ) -> PronunciationResult {
        // Utilisation Speech Framework + Whisper API
        // Retour: score de 0 à 100
    }
}
```

### 3. Synthèse Vocale IA

```swift
class AIVoiceService {
    // Génération voix native pour chaque caractère
    func generatePronunciation(
        character: String,
        tone: ChineseTone
    ) async -> AudioFile {
        // Utilisation API TTS avancée
        // Cache local des sons générés
    }
}
```

### 4. Système de Scoring

```swift
struct ScoringSystem {
    let basePoints = 100
    
    func calculateScore(parameters: ScoreParameters) -> Int {
        var score = basePoints
        
        // Bonus rapidité
        score += parameters.timeBonus
        
        // Bonus précision prononciation
        score += parameters.pronunciationAccuracy * 2
        
        // Bonus série sans erreur
        score += parameters.streakBonus * 10
        
        // Malus indice utilisé
        if parameters.hintUsed {
            score -= 30
        }
        
        return max(0, score)
    }
}
```

**Niveaux de progression:**
- 🥉 Bronze: 0-1000 points
- 🥈 Argent: 1001-5000 points
- 🥇 Or: 5001-10000 points
- 💎 Diamant: 10001-25000 points
- 🏆 Maître: 25001+ points

### 5. Création de Decks Personnalisés

```swift
struct CustomDeck {
    let id: UUID
    let name: String
    let description: String
    let category: Category
    let characters: [Character]
    let isPublic: Bool
    let createdBy: UserID
    let tags: [String]
}
```

**Fonctionnalités:**
- Import depuis dictionnaire intégré
- Scan de caractères (OCR)
- Partage communautaire
- Export/Import format JSON

### 6. Catégories Thématiques IA

```swift
enum PresetCategory: String, CaseIterable {
    case numbers = "Compter"
    case travel = "Voyager"
    case introduction = "Se présenter"
    case food = "Nourriture"
    case family = "Famille"
    case business = "Affaires"
    case daily = "Vie quotidienne"
    case emotions = "Émotions"
    
    var characterCount: Int {
        switch self {
        case .numbers: return 20
        case .travel: return 50
        case .introduction: return 30
        default: return 40
        }
    }
}
```

**Génération automatique par IA:**
```swift
class CategoryGenerator {
    func generateCategoryContent(
        category: PresetCategory,
        level: LanguageLevel
    ) async -> [Character] {
        // Appel API Claude/OpenAI
        // Prompt: "Génère les X caractères chinois 
        // les plus importants pour [catégorie] 
        // niveau [débutant/intermédiaire/avancé]"
    }
}
```

---

## 🎨 Design UI/UX

### Thème visuel - Jeu de Cartes

```swift
struct CardDesign {
    // Apparence carte
    let cornerRadius: CGFloat = 15
    let shadowRadius: CGFloat = 10
    let cardAspectRatio: CGFloat = 0.7 // Portrait
    
    // Animations
    let flipDuration: TimeInterval = 0.6
    let shuffleAnimation: Bool = true
    let particleEffects: Bool = true
    
    // Couleurs thématiques
    let primaryColor = Color("ChineseRed")    // #C8102E
    let secondaryColor = Color("GoldenYellow") // #FFD700
    let backgroundColor = Color("InkBlack")    // #2B2B2B
}
```

### Composants UI principaux

1. **CardView**
   - Animation flip 3D
   - Effet de pile de cartes
   - Geste swipe pour passer
   - Shake pour indice

2. **TimerView**
   - Barre de progression circulaire
   - Changement couleur selon urgence
   - Animation pulsation dernières secondes

3. **ScoreView**
   - Compteur animé
   - Effets particules pour bonus
   - Badges de réussite

4. **DeckSelectorView**
   - Carrousel horizontal
   - Preview des cartes
   - Indicateur de progression

---

## 📊 Modèles de données

### Character Model

```swift
struct Character: Codable, Identifiable {
    let id: UUID
    let simplified: String      // 简体字
    let traditional: String?    // 繁體字
    let pinyin: String          // Pīnyīn
    let meaning: [String]       // Traductions
    let audioFile: URL?         // Prononciation
    let strokeOrder: [CGPath]?  // Ordre des traits
    let frequency: Int          // Fréquence usage
    let hskLevel: Int?          // Niveau HSK
    let examples: [String]      // Phrases exemples
    let mnemonics: String?      // Aide mémoire
}
```

### User Progress Model

```swift
struct UserProgress: Codable {
    let userId: UUID
    let charactersLearned: Set<UUID>
    let totalScore: Int
    let streak: Int
    let lastPracticeDate: Date
    let statistics: LearningStatistics
    let achievements: [Achievement]
    
    struct LearningStatistics {
        let totalAttempts: Int
        let successRate: Double
        let averageResponseTime: TimeInterval
        let difficultCharacters: [UUID]
        let masteredCharacters: [UUID]
    }
}
```

---

## 🔌 Intégrations API

### Configuration API

```swift
struct APIConfiguration {
    // OpenAI/Claude pour génération contenu
    static let aiAPIKey = "YOUR_API_KEY"
    static let aiEndpoint = "https://api.anthropic.com/v1/messages"
    
    // Synthèse vocale
    static let ttsService = "ElevenLabs" // ou Azure Cognitive Services
    
    // Reconnaissance vocale
    static let sttService = "Whisper"
    
    // Dictionnaire chinois
    static let dictionaryAPI = "CC-CEDICT"
}
```

### Exemples de prompts IA

```swift
class AIPromptTemplates {
    static func generateCategoryPrompt(
        category: String,
        count: Int,
        level: String
    ) -> String {
        """
        Génère \(count) caractères chinois essentiels 
        pour la catégorie "\(category)" niveau \(level).
        
        Format JSON requis:
        {
            "characters": [
                {
                    "simplified": "字",
                    "pinyin": "zì",
                    "meaning": ["caractère", "mot"],
                    "example": "这个字很难写"
                }
            ]
        }
        
        Critères:
        - Pertinence pratique
        - Fréquence d'usage élevée
        - Progression logique
        """
    }
}
```

---

## 💾 Persistance des données

### Core Data Schema

```swift
// Entités principales
- CharacterEntity
  - id: UUID
  - simplified: String
  - lastReviewed: Date
  - correctCount: Int32
  - incorrectCount: Int32
  
- DeckEntity
  - id: UUID
  - name: String
  - characters: NSSet (relation)
  - createdDate: Date
  
- ProgressEntity
  - date: Date
  - score: Int32
  - charactersStudied: Int32
  - accuracy: Double
```

### CloudKit Sync

```swift
class CloudSyncManager {
    // Synchronisation automatique
    let container = CKContainer.default()
    
    func syncUserProgress() async {
        // Upload progress vers iCloud
        // Résolution conflits
        // Backup périodique
    }
}
```

---

## 📈 Analytics & Métriques

### KPIs à tracker

```yaml
Engagement:
  - Sessions par jour
  - Durée moyenne session
  - Taux de rétention J1/J7/J30
  
Apprentissage:
  - Caractères appris par session
  - Taux de réussite global
  - Temps moyen par caractère
  
Monétisation:
  - Conversion free → premium
  - Revenue per user
  - Churn rate
```

---

## 🚀 Roadmap de développement

### Phase 1 - MVP (2 mois)
- ✅ Mode apprentissage basique
- ✅ 100 caractères de base
- ✅ Reconnaissance vocale simple
- ✅ Scoring basique

### Phase 2 - Enrichissement (1 mois)
- 🔄 Catégories thématiques
- 🔄 Création decks personnalisés
- 🔄 Synthèse vocale IA
- 🔄 Amélioration UI/UX

### Phase 3 - Social & Gamification (1 mois)
- 📋 Classements globaux
- 📋 Défis entre amis
- 📋 Partage de decks
- 📋 Achievements

### Phase 4 - Extension (2 mois)
- 📋 Support japonais (Hiragana/Katakana/Kanji)
- 📋 Support coréen (Hangul)
- 📋 Mode écriture (reconnaissance traits)
- 📋 Réalité augmentée

---

## 🔐 Sécurité & Confidentialité

```swift
struct PrivacyConfiguration {
    // Données stockées localement par défaut
    static let localFirstPolicy = true
    
    // Chiffrement des données sensibles
    static let encryptionEnabled = true
    
    // Anonymisation analytics
    static let anonymizeUserData = true
    
    // RGPD compliance
    static let gdprCompliant = true
}
```

---

## 💰 Modèle de monétisation

### Freemium Model

**Version gratuite:**
- 50 caractères de base
- 1 catégorie thématique
- Limite 10 min/jour
- Publicités non-intrusives

**Premium (4.99€/mois):**
- Tous les caractères
- Toutes les catégories
- Création decks illimitée
- Synthèse vocale premium
- Pas de publicités
- Synchronisation multi-appareils

**Add-ons:**
- Pack HSK complet: 9.99€
- Voix régionales: 2.99€
- Thèmes visuels: 1.99€

---

## 📱 Configuration minimale

```yaml
iOS Version: 16.0+
iPhone: iPhone 11 ou plus récent
iPad: iPad (7e génération) ou plus récent
Stockage: 200 MB minimum
Connexion: Requise pour IA et sync
Microphone: Requis pour reconnaissance vocale
```

---

## 🧪 Tests & QA

### Plan de tests

```swift
// Unit Tests
- Models validation
- Scoring algorithms
- API integrations

// UI Tests
- Card flip animations
- Timer functionality
- Navigation flow

// Performance Tests
- Audio processing latency < 100ms
- Character load time < 50ms
- Memory usage < 150MB
```

---

## 📚 Documentation

### Pour développeurs
- README.md technique
- Guide d'architecture
- Documentation API
- Guide de contribution

### Pour utilisateurs
- Tutoriel interactif in-app
- FAQ
- Guide de prononciation
- Vidéos tutorielles

---

## 🤝 Équipe & Rôles

```yaml
Product Owner: [À définir]
iOS Developer: [À définir]
UI/UX Designer: [À définir]
Backend Developer: [À définir]
QA Tester: [À définir]
Content Creator: [À définir] # Création contenu pédagogique
```

---

## 📞 Support & Contact

- Email support: support@charactercards.app
- Discord communauté: [À créer]
- Twitter: @CharacterCardsApp
- Site web: www.charactercards.app

---

## 🏁 Critères de succès

1. **Technique**: App stable, <0.1% crash rate
2. **Engagement**: 40% rétention J7
3. **Apprentissage**: 80% utilisateurs progressent
4. **Financier**: Break-even en 6 mois
5. **Satisfaction**: Note App Store > 4.5⭐

---

*Document créé le: [DATE]*  
*Dernière mise à jour: [DATE]*  
*Version: 1.0.0*

---

## 🔧 État Actuel du Projet & Problèmes Résolus (Nov 2025)

### Architecture Réelle Implémentée

```
LearnTheCharacters/
├── Core/
│   ├── Models/
│   │   ├── Character.swift (✅ Implémenté)
│   │   ├── Deck.swift (✅ Implémenté)
│   │   └── GameSession.swift (✅ Implémenté)
│   └── Services/
│       ├── AudioService.swift (✅ Implémenté)
│       ├── SpeechRecognitionService.swift (✅ Implémenté - On-Device uniquement)
│       └── DeckLoaderService.swift (✅ Implémenté)
├── Features/
│   ├── Components/
│   │   └── CharacterCardView.swift (✅ Multi-line examples support)
│   ├── Home/
│   │   └── HomeView.swift (✅ Implémenté)
│   └── Learning/
│       ├── CardGameView.swift (✅ Layout avec hauteurs fixes)
│       ├── CardGameViewModel.swift (✅ Flow optimisé)
│       └── TimerManager.swift (✅ Implémenté)
└── Resources/
    └── Decks/
        ├── nombres-0-20.json (✅ 21 caractères)
        └── [autres decks...]
```

### Reconnaissance Vocale - Configuration Actuelle

**Mode utilisé** : On-Device uniquement (pas de cloud)

```swift
// SpeechRecognitionService.swift
if #available(iOS 17, *) {
    recognitionRequest.requiresOnDeviceRecognition = true
    print("📱 Mode on-device (rapide et local)")
}
```

**Avantages** :
- Fonctionne hors ligne
- Rapide (pas de latence réseau)
- Pas de frais API

**Détection des tons** :
- Système implémenté mais limites reconnues
- Fonctionne quand l'utilisateur prononce le pinyin
- Ne fonctionne PAS quand Speech Framework reconnaît un caractère différent

### CardGameView - Layout avec Hauteurs FIXES

**IMPORTANT** : Le layout utilise des hauteurs FIXES pour éviter tout déplacement des éléments.

```swift
VStack(spacing: 0) {
    // Header - 60px FIXE
    HStack { /* X, Score, Timer */ }
        .frame(height: 60)
    
    // Progress bar + compteur - 30px FIXE
    VStack { 
        ProgressView(...)
        Text("X / Y")
    }
    .frame(height: 30)
    
    // Zone feedback - 100px FIXE (toujours présente même vide)
    ZStack {
        Color.clear
        if showRecognitionFeedback {
            RecognitionFeedbackView(...)
        }
    }
    .frame(height: 100)
    
    // Card - 360px FIXE
    CharacterCardView(...)
        .frame(height: 360)
    
    Spacer() // Flexible pour pousser les boutons en bas
    
    // Boutons - hauteur variable selon l'état
    VStack {
        if !showAnswer {
            // Bouton micro + Indice + Écouter
        } else {
            // Retour + Suivant
        }
    }
}
```

**Calcul des hauteurs** :
- Header: 60px
- Progress: 30px
- Feedback: 100px
- Card: 360px
- **Total haut**: 550px
- **Reste pour boutons**: ~300px sur iPhone (selon modèle)

### Flow du Jeu - Comportement Actuel

**Quand la prononciation est CORRECTE** :
1. Affiche feedback vert pendant 1.5s
2. Passe au caractère suivant après 2s
3. **N'affiche PAS la carte réponse**

**Quand la prononciation est INCORRECTE** :
1. Affiche feedback rouge
2. **Affiche automatiquement la réponse (flip carte)**
3. Prononce le caractère correct après 0.5s
4. Cache le feedback après 3s
5. Passe au suivant après 5s

### Problèmes Résolus

#### 1. Layout instable (Nov 2025)
**Symptôme** : Header, progress bar disparaissaient ou bougeaient entre les états
**Cause** : Utilisation de `Spacer()` flexibles et `minHeight/maxHeight`
**Solution** : Hauteurs FIXES pour tous les éléments du haut

#### 2. Exemples tronqués avec "..."
**Symptôme** : Texte des exemples coupé sur une ligne
**Solution** :
```swift
Text(example)
    .lineLimit(nil)
    .multilineTextAlignment(.leading)
    .fixedSize(horizontal: false, vertical: true)
```

#### 3. Reconnaissance vocale cloud vs on-device
**Décision** : Suppression du mode cloud, on-device uniquement
**Raison** : 
- Cloud n'était pas utilisé de manière cohérente
- On-device plus rapide et fonctionne hors ligne

#### 4. Flow confus après prononciation correcte
**Ancien comportement** : Toujours montrer la réponse
**Nouveau comportement** : Ne montrer la réponse QUE si incorrect

### Configurations Importantes

#### Speech Recognition Error Codes
```swift
// 1101: Network issue (server unreachable)
// 1110: No speech detected (PAS une erreur réseau!)
// 203: Connection failed
```

#### Deck JSON Format
```json
{
  "id": "UUID",
  "name": "Nom du deck",
  "category": "numbers|travel|etc",
  "characters": [
    {
      "id": "UUID",
      "simplified": "零",
      "traditional": "零",
      "pinyin": "líng",
      "meaning": ["zéro"],
      "examples": ["零度 (língdù) - zéro degré"],
      "arabicNumeral": "0"
    }
  ]
}
```

### Points d'Attention pour Développement Futur

1. **Layout CardGameView** : NE PAS utiliser de Spacers flexibles, garder les hauteurs fixes
2. **Reconnaissance vocale** : Rester en on-device, ne pas réintroduire le cloud
3. **Taille de la carte** : 360px est un bon compromis, ajuster à 340px si boutons coupés
4. **Safe Areas** : Éviter `.ignoresSafeArea()`, laisser SwiftUI gérer naturellement

### Commandes de Build Rapides

```bash
# Build complet
xcodebuild -scheme LearnTheCharacters -sdk iphonesimulator -configuration Debug build

# Build avec logs réduits
xcodebuild -scheme LearnTheCharacters -sdk iphonesimulator -configuration Debug build 2>&1 | grep -E "(BUILD|error)"

# Nettoyage
xcodebuild -scheme LearnTheCharacters clean
```

---

*Dernière mise à jour technique: 19 novembre 2025*
*État: Layout stable avec hauteurs fixes, reconnaissance vocale on-device uniquement*

## 📖 Mode Consultation (Ajouté Nov 2025)

### Vue d'ensemble

Le mode Consultation permet de parcourir les caractères sans pression de temps ni test de prononciation. C'est un mode de révision et d'apprentissage tranquille.

### Caractéristiques

**Pas de chronomètre** : L'utilisateur peut prendre tout son temps
**Pas de reconnaissance vocale** : Pas de test de prononciation
**Commence avec l'indice** : La carte affiche directement le pinyin et la traduction
**Navigation flexible** : 
- Boutons "Précédent" / "Suivant"
- Swipe droite = carte précédente
- Swipe gauche = carte suivante
- Tap sur la carte = toggle entre vue complète et caractère seul

**Bouton Écouter** : Pour entendre la prononciation correcte

### Implémentation

```swift
// Fichier: ConsultationView.swift
// Location: Features/Learning/ConsultationView.swift

struct ConsultationView: View {
    @StateObject private var viewModel: ConsultationViewModel
    
    // Gestes implémentés:
    .gesture(
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                if value.translation.width > 50 {
                    // Swipe droite = précédent
                    viewModel.moveToPrevious()
                } else if value.translation.width < -50 {
                    // Swipe gauche = suivant  
                    viewModel.moveToNext()
                }
            }
    )
    .onTapGesture {
        // Tap = toggle answer
        viewModel.toggleAnswer()
    }
}
```

### Configuration dans GameSession.Difficulty

```swift
enum Difficulty {
    case consultation = "consultation"  // 📖 Mode consultation
    case listening = "listening"        // 👂 Mode écoute
    case writing = "writing"            // ✍️ Mode écriture
    case mediaReview = "mediaReview"    // 🎬 Mode révision média
    case beginner = "beginner"          // 🌱 Mode débutant
    case intermediate = "intermediate"  // 🌿 Mode intermédiaire

    var timeLimit: TimeInterval {
        case .consultation: return 0 // Pas de limite
        case .listening: return 0    // Pas de limite
        case .writing: return 0      // Pas de limite
        case .mediaReview: return 0  // Pas de limite
        case .beginner: return 30.0
        case .intermediate: return 20.0
    }

    var icon: String {
        case .consultation: return "📖"
        case .listening: return "👂"
        case .writing: return "✍️"
        case .mediaReview: return "🎬"
        case .beginner: return "🌱"
        case .intermediate: return "🌿"
    }
}
```

### Routing

Le DifficultySelectionView route vers la vue appropriée selon le mode choisi :

```swift
.navigationDestination(isPresented: $navigateToGame) {
    if selectedDifficulty == .consultation {
        ConsultationView(deck: deck)
    } else if selectedDifficulty == .listening {
        ListeningView(deck: deck)
    } else if selectedDifficulty == .writing {
        WritingPracticeView(deck: deck)
    } else if selectedDifficulty == .mediaReview {
        MediaReviewView(deck: deck)
    } else {
        CardGameView(deck: deck, difficulty: selectedDifficulty)
    }
}
```

---

## 📝 Mode Écriture - Apprentissage de l'Ordre des Traits (Ajouté Jan 2026)

### Vue d'ensemble

Le mode Écriture permet d'apprendre l'ordre correct d'écriture des caractères chinois avec animation des traits et pratique libre.

### Caractéristiques

**Pas de chronomètre** : L'utilisateur peut prendre tout son temps
**Pas de validation** : Mode apprentissage libre uniquement
**Animation des traits** : Démonstration visuelle de l'ordre d'écriture correct
**Canvas de dessin** : Pratique libre avec le doigt (iPhone) ou Apple Pencil (iPad)
**Caractère guide** : Affichage en SVG pour correspondance parfaite avec l'animation
**Navigation flexible** : Boutons Précédent/Suivant pour naviguer librement

### Source de données

**Make Me a Hanzi** : Base de données open-source dérivée d'Arphic CJK
- 9574 caractères avec données de stroke order
- Format SVG pour les contours de traits
- Medians (lignes centrales) pour l'animation fluide

### Composants principaux

#### 1. StrokeAnimationView
- **Animation séquentielle** des traits (un par un)
- **Contours SVG** en gris clair comme guide statique
- **Tracé médian** animé en vert avec courbes Bézier adoucies
- **Numéros de traits** en rouge pour indiquer l'ordre
- **Auto-play** : L'animation démarre automatiquement au chargement
- **Replay** : Bouton "Animer" pour rejouer l'animation

#### 2. MedianStrokePath
- Convertit les points de médiane en **courbes de Bézier quadratiques**
- **Adoucissement** des changements de direction pour un tracé naturel
- **Inversion de l'axe Y** pour correspondance correcte
- Technique : Chaque point devient un point de contrôle, la courbe va jusqu'au milieu du segment suivant

#### 3. DrawingCanvasView
- **Caractère guide** en SVG rempli (même fonte que l'animation)
- **Geste de dessin** : DragGesture pour tracer au doigt/Apple Pencil
- **Traits complétés** en noir, trait actuel en bleu
- **Bouton Effacer** pour recommencer

#### 4. SVGPathParser
- Parse les chemins SVG de Make Me a Hanzi en SwiftUI Path
- Supporte M (MoveTo), L (LineTo), Q (Quadratic), C (Cubic), Z (Close)
- **Inversion de l'axe Y** : `y: rect.maxY - point.y * scaleY`
- Mise à l'échelle du viewBox (1024x1024) vers le rect cible

### Intégration des données

**Script Python** : `add-stroke-order.py`

```bash
# Télécharger Make Me a Hanzi
cd LearnTheCharacters-Decks-Repo
git clone https://github.com/skishore/makemeahanzi.git

# Enrichir un deck avec stroke order
python3 tools/add-stroke-order.py decks/community/nombres-0-20.json
```

### Corrections techniques appliquées

1. **Inversion de l'axe Y** (3 jan 2026)
   - SVGPathParser : `y: rect.maxY - point.y * scaleY`
   - MedianStrokePath : même inversion
   - getStrokeStartPoint : `y: size.height - firstPoint.y * scaleY`

2. **Animation automatique** (3 jan 2026)
   - Ajout de `.onAppear { playAnimation() }` dans StrokeAnimationView

3. **Courbes adoucies** (3 jan 2026)
   - Utilisation de `addQuadCurve()` au lieu de `addLine()`
   - Tracé fluide et naturel comme un pinceau calligraphique

4. **Correspondance des fontes** (3 jan 2026)
   - DrawingCanvasView utilise les strokes SVG remplis comme guide
   - Plus de `Text()` avec fonte système différente

5. **Retrait mode Avancé** (3 jan 2026)
   - Modes disponibles : Consultation, Écoute, Écriture, Débutant, Intermédiaire
   - Mode Avancé retiré de l'enum Difficulty

### État actuel des decks

```
✅ cours-03-hanzi.json       11/ 11 (100%)
✅ cours-04-hanzi.json       10/ 10 (100%)
✅ cours-05-hanzi.json       10/ 10 (100%)
✅ cours-06-hanzi.json       10/ 10 (100%)
⚠️ nombres-0-20.json         11/ 21 ( 52%)
```

**Note** : Le deck nombres-0-20 est à 52% car les nombres composés (十一, 十二, etc.) ne sont pas des caractères uniques dans Make Me a Hanzi.

---

## 🚀 Pousser des Decks sur GitHub (Mis à jour Jan 2026)

### Structure des repositories

```
/Users/cbrassel/Projet/LearnTheCharacters/
├── LearnTheCharacters/          # ← REPO GIT PRINCIPAL (app iOS + decks)
│   ├── .git/
│   ├── LearnTheCharacters/      # Code Swift de l'app
│   ├── decks/                   # ← LES DECKS SONT ICI
│   │   ├── community/
│   │   ├── hsk1/
│   │   └── thematic/
│   └── tools/
└── LearnTheCharacters-Decks-Repo/  # Copie locale (NE PAS UTILISER pour push)
```

**IMPORTANT** : Les decks à pousser sont dans `LearnTheCharacters/LearnTheCharacters/decks/`, pas dans `LearnTheCharacters-Decks-Repo/`.

### Procédure pour ajouter un nouveau deck

#### 1. Créer le deck dans LearnTheCharacters-Decks-Repo

```bash
cd /Users/cbrassel/Projet/LearnTheCharacters/LearnTheCharacters-Decks-Repo

# Créer le fichier JSON du deck (voir format requis ci-dessous)
# Puis ajouter les stroke order :
python3 tools/add-stroke-order.py decks/community/mon-deck.json
```

#### 2. Valider et corriger le deck (OBLIGATOIRE)

Le deck doit respecter ces règles pour être chargé par l'app :

**a) UUIDs valides** - Format : `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` (hex uniquement)
```bash
# Script pour corriger les UUIDs invalides :
python3 << 'EOF'
import json, uuid

def fix_uuids(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    data['id'] = str(uuid.uuid4()).upper()
    for char in data.get('characters', []):
        char['id'] = str(uuid.uuid4()).upper()
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"✅ UUIDs corrigés dans {filepath}")

fix_uuids('decks/community/mon-deck.json')
EOF
```

**b) Champ `listeningSentences` requis** - Doit être présent (même vide) sur chaque caractère
```bash
# Script pour ajouter listeningSentences manquants :
python3 << 'EOF'
import json

def add_listening_sentences(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    for char in data.get('characters', []):
        if 'listeningSentences' not in char:
            char['listeningSentences'] = []
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"✅ listeningSentences ajoutés dans {filepath}")

add_listening_sentences('decks/community/mon-deck.json')
EOF
```

**c) Script tout-en-un pour valider un deck :**
```bash
python3 << 'EOF'
import json, uuid

def validate_and_fix_deck(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Fix deck UUID si invalide
    try:
        uuid.UUID(data['id'])
    except:
        data['id'] = str(uuid.uuid4()).upper()
        print(f"  ✓ UUID deck corrigé")

    # Fix chaque caractère
    for char in data.get('characters', []):
        # UUID valide
        try:
            uuid.UUID(char['id'])
        except:
            char['id'] = str(uuid.uuid4()).upper()
        # listeningSentences présent
        if 'listeningSentences' not in char:
            char['listeningSentences'] = []

    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"✅ {filepath} validé et corrigé")

validate_and_fix_deck('decks/community/mon-deck.json')
EOF
```

#### 3. Copier vers le repo principal

```bash
cp decks/community/mon-deck.json /Users/cbrassel/Projet/LearnTheCharacters/LearnTheCharacters/decks/community/
```

#### 4. Pousser sur GitHub

```bash
cd /Users/cbrassel/Projet/LearnTheCharacters/LearnTheCharacters

# Vérifier que gh est configuré
gh auth status

# Si besoin de permissions repo :
gh auth refresh -h github.com -s repo
# → Suivre les instructions (ouvrir URL + entrer code)

# Configurer git pour utiliser gh
gh auth setup-git

# Commit et push
git add decks/community/mon-deck.json
git commit -m "feat: Add mon-deck"
git push origin main
```

### Format JSON requis pour un deck

```json
{
  "id": "A1B2C3D4-5678-90AB-CDEF-1234567890AB",
  "name": "Nom du Deck",
  "description": "Description du deck",
  "category": "community",
  "version": "1.0",
  "author": "Auteur",
  "createdDate": "2026-01-19T10:00:00Z",
  "characters": [
    {
      "id": "12345678-90AB-CDEF-1234-567890ABCDEF",
      "simplified": "字",
      "traditional": "字",
      "pinyin": "zì",
      "meaning": ["caractère"],
      "frequency": 10,
      "hskLevel": 1,
      "examples": ["汉字 (hànzì) - caractère chinois"],
      "listeningSentences": []
    }
  ]
}
```

**Champs obligatoires par caractère :**
- `id` : UUID valide
- `simplified` : caractère simplifié
- `pinyin` : prononciation avec ton
- `meaning` : tableau de traductions
- `listeningSentences` : tableau (peut être vide)

### Dépannage

#### Erreur "Permission denied"
```bash
gh auth refresh -h github.com -s repo
# Puis suivre les instructions dans le navigateur
gh auth setup-git
```

#### Erreur "Push cannot contain secrets"
GitHub bloque les tokens exposés. Ouvrir l'URL fournie dans l'erreur pour autoriser le secret, puis relancer `git push`.

#### Erreur "Repository rule violations"
Même solution : ouvrir l'URL fournie et autoriser.

### URLs importantes

- **Repo GitHub** : https://github.com/cbrassel/LearnTheCharacters
- **Decks sur GitHub** : https://github.com/cbrassel/LearnTheCharacters/tree/main/decks
- **Raw content** : `https://raw.githubusercontent.com/cbrassel/LearnTheCharacters/main/decks/community/[nom].json`

---

## 🎬 Mode Révision Média (Ajouté Fév 2026)

### Vue d'ensemble

Le mode Révision Média permet d'écouter l'audio ou regarder la vidéo générée pour un deck. Idéal pour réviser passivement en écoutant comme un podcast.

### Caractéristiques

**Lecture Audio** :
- Fichiers MP3 générés avec voix chinoise + française
- Téléchargement automatique depuis GitHub
- Lecture en arrière-plan (continue quand l'app est minimisée)
- Contrôles sur l'écran de verrouillage

**Lecture Vidéo** :
- Fichiers MP4 en streaming depuis GitHub
- Option de téléchargement pour lecture hors ligne
- Mode plein écran avec contrôles natifs

**Contrôles** :
- Play/Pause
- Skip ±15 secondes
- Barre de progression interactive
- Toggle Audio/Vidéo

### Architecture

```
Core/Services/
└── MediaService.swift          # Gestion URLs, téléchargements, cache

Features/Learning/
├── MediaReviewView.swift       # Vue principale
├── MediaReviewViewModel.swift  # Logique métier
└── Components/
    └── VideoPlayerView.swift   # Wrapper AVPlayerViewController
```

### MediaService

```swift
class MediaService: ObservableObject {
    static let shared = MediaService()

    // URLs distantes (GitHub)
    func getRemoteAudioURL(for deckName: String) -> URL?
    func getRemoteVideoURL(for deckName: String) -> URL?

    // Téléchargement
    func downloadAudio(for deckName: String) async throws -> URL
    func downloadVideo(for deckName: String) async throws -> URL

    // Vérification disponibilité
    func isAudioDownloaded(for deckName: String) -> Bool
    func isVideoDownloaded(for deckName: String) -> Bool
    func checkRemoteMediaExists(for deckName: String, type: MediaType) async -> Bool

    // Cache
    func deleteMedia(for deckName: String, type: MediaType) throws
    func clearAllCache() throws
    func totalCacheSize() -> Int64

    // Audio session
    func configureBackgroundAudio()
    func setupRemoteCommandCenter(...)
    func updateNowPlayingInfo(...)
}
```

### URLs des médias sur GitHub

```
https://raw.githubusercontent.com/cbrassel/LearnTheCharacters/main/media/audio/[deck-name].mp3
https://raw.githubusercontent.com/cbrassel/LearnTheCharacters/main/media/video/[deck-name].mp4
```

### Comportement

1. **Entrée dans le mode** : L'audio est téléchargé automatiquement s'il existe sur GitHub
2. **Vidéo** : Streaming par défaut, téléchargement optionnel
3. **Background** : L'audio continue en arrière-plan avec contrôles lock screen
4. **Plein écran** : Tap sur la vidéo ou bouton ↗️ pour passer en plein écran

### Configuration Info.plist

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

---

## 🎧 Génération Audio et Vidéo (Ajouté Fév 2026)

### Vue d'ensemble

Outils Python pour générer des pistes audio MP3 et des vidéos MP4 d'apprentissage à partir des decks JSON.

### Emplacement

```
tools/audio-generator/
├── generate-audio.sh      # Script wrapper audio
├── generate-video.sh      # Script wrapper vidéo
├── generate_audio.py      # Script Python audio
├── generate_video.py      # Script Python vidéo
├── requirements.txt       # Dépendances Python
├── venv/                  # Environnement virtuel (auto-géré)
└── .gitignore
```

### Prérequis

- **Python 3.11+**
- **ffmpeg** : `brew install ffmpeg`
- Les dépendances Python sont installées automatiquement dans le venv

### Utilisation

```bash
cd /Users/cbrassel/Projet/LearnTheCharacters/tools/audio-generator

# Générer l'audio pour un deck
./generate-audio.sh /chemin/vers/deck.json

# Générer la vidéo pour un deck
./generate-video.sh /chemin/vers/deck.json

# Générer pour plusieurs decks
./generate-audio.sh deck1.json deck2.json deck3.json
./generate-video.sh deck1.json deck2.json deck3.json

# Générer pour tous les decks community
./generate-video.sh ../../../LearnTheCharacters/decks/community/*.json
```

### Dossiers de sortie

- **Audio** : `/Users/cbrassel/Projet/LearnTheCharacters/audio_output/`
- **Vidéo** : `/Users/cbrassel/Projet/LearnTheCharacters/video_output/`

### Format Audio (MP3)

Structure par caractère :
1. 🇨🇳 Caractère chinois × 3 répétitions (avec pause courte)
2. 🇫🇷 Toutes les traductions françaises
3. 🇨🇳 Phrase exemple en chinois
4. 🇫🇷 Traduction de l'exemple
5. ⏸️ Pause de 4 secondes avant le caractère suivant

**Voix utilisées** (Microsoft Edge TTS) :
- Chinois : `zh-CN-XiaoxiaoNeural` (féminine)
- Français : `fr-FR-DeniseNeural` (féminine)

### Format Vidéo (MP4)

**Résolution** : 1920×1080 (Full HD)
**FPS** : 30

Structure visuelle par caractère :
```
┌─────────────────────────────────┐
│              上                 │  ← Caractère (or)
│            shàng                │  ← Pinyin (gris clair)
│                                 │
│      haut, monter, sur          │  ← Traductions (blanc)
│                                 │
│  ─────────────────────────────  │
│                                 │
│         我上楼了。               │  ← Exemple chinois (or)
│      wǒ shàng lóu le            │  ← Pinyin auto-généré (gris)
│   Je monte à l'étage.           │  ← Traduction (gris clair)
│                                 │
└─────────────────────────────────┘
```

**Phases d'affichage** :
1. Caractère + pinyin (pendant 3× répétitions audio)
2. + Traductions (pendant audio français)
3. + Exemple chinois + pinyin (pendant audio exemple)
4. + Traduction exemple (pendant audio traduction)
5. Pause 4s → caractère suivant

### Dépendances Python

```
edge-tts>=6.1.0         # Synthèse vocale Microsoft
pydub>=0.25.0           # Manipulation audio
audioop-lts>=0.2.0      # Compatibilité Python 3.13+
Pillow>=10.0.0          # Génération d'images
pypinyin>=0.50.0        # Conversion caractères → pinyin
```

### Configuration des pauses

Dans `generate_audio.py` et `generate_video.py` :
```python
PAUSE_SHORT = 500       # Entre répétitions (ms)
PAUSE_MEDIUM = 1000     # Après traduction (ms)
PAUSE_LONG = 4000       # Entre deux caractères (ms)
```

### Temps de génération estimés

| Taille du deck | Audio | Vidéo |
|----------------|-------|-------|
| 10 caractères  | ~30s  | ~2min |
| 20 caractères  | ~1min | ~4min |
| 50 caractères  | ~2min | ~10min |
| 90 caractères  | ~4min | ~20min |

### Polices utilisées (macOS)

- **Chinois** : PingFang SC, STHeiti, Hiragino Sans GB
- **Latin** : Helvetica, SF NS Display, Arial

### Exemple de sortie

```
audio_output/
├── Cours 03 - 汉字.mp3    (2.6 Mo, ~3min)
├── Cours 04 - 汉字.mp3
└── ...

video_output/
├── Cours 03 - 汉字.mp4    (1.8 Mo, ~3min, 1080p)
├── Cours 04 - 汉字.mp4
└── ...
```

---

*Dernière mise à jour: 9 février 2026*
*État: Mode Révision Média intégré avec lecture audio/vidéo, plein écran et background audio*
