# Système de Feedback Tonique

## Vue d'ensemble

Le système de reconnaissance vocale inclut maintenant un système de feedback intelligent qui détecte les homophones chinois et évalue la précision des tons.

## Niveaux de Feedback

### 1. Parfait (100% de précision)
**Déclencheur**: Le caractère reconnu correspond exactement au caractère attendu.

**Feedback affiché**: "Parfait!"

**Exemple**:
- Attendu: 店 (diàn - magasin)
- Reconnu: 店 (diàn)
- ✅ Match parfait

---

### 2. Correct (100% de précision)
**Déclencheur**: Une alternative valide est reconnue (nombre arabe, traduction, etc.).

**Feedback affiché**: "Correct!"

**Exemple**:
- Attendu: 十四 (shí sì)
- Reconnu: 14 (chiffre arabe)
- ✅ Alternative acceptée

---

### 3. Homophone avec Bons Tons (85% de précision)
**Déclencheur**: Un caractère homophone est reconnu avec les tons corrects.

**Feedback affiché**: "Bons tons, mais attention au caractère!"

**Exemple**:
- Attendu: 店 (diàn - magasin)
- Reconnu: 电 (diàn - électricité)
- ✅ Prononciation correcte, mais mauvais caractère
- Précision: 85%

**Cas d'usage pédagogique**: L'utilisateur maîtrise la prononciation et les tons, mais a confondu deux homophones. C'est une erreur sémantique, pas phonétique.

---

### 4. Homophone avec Mauvais Tons (60% de précision)
**Déclencheur**: Un caractère homophone est reconnu mais les tons ne correspondent pas.

**Feedback affiché**: "Attention aux tons!"

**Exemple**:
- Attendu: 店 (diàn - ton descendant)
- Reconnu: 电 sans tons ou avec mauvais ton
- ⚠️ Base correcte (dian) mais tons incorrects
- Précision: 60%

**Cas d'usage pédagogique**: L'utilisateur a identifié la bonne syllabe mais n'a pas prononcé le ton correct. Il doit améliorer sa maîtrise des tons.

---

### 5. Presque Correct (Seuil selon difficulté)
**Déclencheur**: Similarité au-dessus du seuil proche mais en-dessous du seuil d'acceptation.

**Feedback affiché**: "Presque! Réessayez."

**Exemple**:
- Attendu: 好 (hǎo)
- Reconnu: hao (sans ton)
- Similarité: 0.70
- ⚠️ Proche mais pas assez précis

---

### 6. Incorrect (En-dessous des seuils)
**Déclencheur**: Similarité trop faible.

**Feedback affiché**: "Essayez encore."

**Exemple**:
- Attendu: 店 (diàn)
- Reconnu: 好 (hǎo)
- ❌ Caractères complètement différents

---

## Seuils de Tolérance par Difficulté

```swift
enum Difficulty {
    case beginner:     70% acceptation, 50% proche
    case intermediate: 80% acceptation, 60% proche
    case advanced:     90% acceptation, 70% proche
    case expert:       95% acceptation, 80% proche
}
```

---

## Détection des Homophones

### Méthode de Détection

1. **Vérification que les deux textes sont chinois** (Unicode range 0x4E00-0x9FFF)
2. **Suppression des tons** du pinyin reconnu et attendu
3. **Comparaison de la base phonétique** (ex: "dian" = "dian")
4. **Vérification exacte des tons** via le pinyin complet

### Exemples d'Homophones Courants

| Caractère | Pinyin | Signification |
|-----------|--------|---------------|
| 店 | diàn | magasin |
| 电 | diàn | électricité |
| 点 | diǎn | point / heure |
| 典 | diǎn | classique |

| Caractère | Pinyin | Signification |
|-----------|--------|---------------|
| 吗 | ma | particule interrogative |
| 妈 | mā | mère |
| 马 | mǎ | cheval |
| 骂 | mà | injurier |

---

## Fonction de Suppression des Tons

La fonction `removeTones()` normalise le pinyin en retirant tous les diacritiques:

```
ā, á, ǎ, à → a
ē, é, ě, è → e
ī, í, ǐ, ì → i
ō, ó, ǒ, ò → o
ū, ú, ǔ, ù → u
ǖ, ǘ, ǚ, ǜ, ü → v
```

**Exemple**:
- Input: "diàn"
- Output: "dian"

---

## Impact sur le Scoring

### Précision et Points

Le système de scoring utilise `pronunciationAccuracy` (0.0 à 1.0):

```swift
// Bonus précision prononciation
score += parameters.pronunciationAccuracy * 2
```

**Exemples de calcul**:

1. **Parfait (1.0)**
   - Base: 100 points
   - Bonus: 1.0 × 2 = 2 points
   - Total: 102+ points (+ bonus temps et série)

2. **Homophone bons tons (0.85)**
   - Base: 100 points
   - Bonus: 0.85 × 2 = 1.7 points
   - Total: 101.7+ points

3. **Homophone mauvais tons (0.6)**
   - Base: 100 points
   - Bonus: 0.6 × 2 = 1.2 points
   - Total: 101.2+ points

---

## Alternatives Acceptées

Le système accepte plusieurs formes de réponses via `acceptedAlternatives`:

### 1. Meanings (Traductions)
```json
"meaning": ["14", "quatorze"]
```

### 2. Pinyin
```json
"pinyin": "shí sì"
```

### 3. Caractère Simplifié
```json
"simplified": "十四"
```

**Exemple complet pour le nombre 14**:
- ✅ "十四" (caractère)
- ✅ "14" (chiffre arabe)
- ✅ "quatorze" (français)
- ✅ "shí sì" (pinyin)

---

## Logs de Debug

### Format des Logs

```
⚠️ Homophone détecté: '电' a la même base que '店'
✅ Tons corrects pour l'homophone
🎯 Attendu: '店' | Reconnu: '电' | Précision: 0.85
```

### Interprétation

- **⚠️ Homophone détecté**: Système a identifié deux caractères avec même base phonétique
- **✅ Tons corrects**: Match exact du pinyin avec tons
- **⚠️ Tons potentiellement incorrects**: Pinyin ne match pas exactement
- **🎯 Précision**: Valeur finale utilisée pour le scoring

---

## Cas d'Usage Pédagogiques

### Scénario 1: Apprenant Débutant
**Difficulté**: Beginner (70% tolérance)

L'apprenant prononce "dian" pour 店 (diàn):
- Reconnaissance floue acceptée si > 70%
- Feedback: "Très bien!" ou "Presque!"
- Objectif: Encourager la pratique

### Scénario 2: Apprenant Intermédiaire
**Difficulté**: Intermediate (80% tolérance)

L'apprenant prononce "电" (diàn) au lieu de "店" (diàn):
- Homophone détecté
- Tons corrects → 85% précision → Accepté
- Feedback: "Bons tons, mais attention au caractère!"
- Objectif: Affiner la reconnaissance des caractères

### Scénario 3: Apprenant Avancé
**Difficulté**: Advanced (90% tolérance)

L'apprenant prononce "dian" sans tons pour 店 (diàn):
- Homophone détecté
- Tons incorrects → 60% précision → Rejeté (< 90%)
- Feedback: "Attention aux tons!"
- Objectif: Maîtrise des tons obligatoire

### Scénario 4: Expert
**Difficulté**: Expert (95% tolérance)

L'apprenant doit être quasi-parfait:
- Seules les réponses > 95% sont acceptées
- Homophones avec bons tons (85%) → Rejetés
- Objectif: Perfection native

---

## Tests Recommandés

### Test 1: Homophones avec Tons Corrects
1. Deck: Cours 04 (magasin 店)
2. Prononcer: "diàn" (avec ton correct)
3. Résultat attendu:
   - Si 店 reconnu → 100% "Parfait!"
   - Si 电 reconnu → 85% "Bons tons, mais attention au caractère!"

### Test 2: Homophones sans Tons
1. Deck: Cours 04
2. Prononcer: "dian" (sans ton)
3. Résultat attendu:
   - 60% "Attention aux tons!"

### Test 3: Nombres
1. Deck: Nombres 0-20
2. Dire: "quatorze" ou "14"
3. Résultat attendu:
   - 100% "Correct!" (alternative acceptée)

### Test 4: Difficulté Beginner vs Expert
1. Même caractère, même prononciation approximative
2. Beginner: Accepté si > 70%
3. Expert: Rejeté si < 95%

---

## Améliorations Futures Possibles

### Court Terme
- [ ] Afficher le feedback tonique dans l'UI (actuellement dans les logs)
- [ ] Vibration différente selon le type de feedback
- [ ] Animation visuelle pour distinguer homophones

### Moyen Terme
- [ ] Base de données d'homophones courants
- [ ] Suggestions automatiques d'homophones après erreur
- [ ] Exercices spécifiques pour paires d'homophones

### Long Terme
- [ ] Analyse de la courbe tonale audio
- [ ] Feedback visuel sur la forme du ton (montant/descendant/etc.)
- [ ] Reconnaissance des variations régionales (Pékin vs Shanghai)

---

*Document créé le: 2025-11-19*
*Version: 1.0.0*
