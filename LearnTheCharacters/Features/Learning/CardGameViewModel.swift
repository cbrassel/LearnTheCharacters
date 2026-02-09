//
//  CardGameViewModel.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation
import Combine

class CardGameViewModel: ObservableObject, Identifiable, Hashable {
    let id = UUID()

    // Hashable conformance
    static func == (lhs: CardGameViewModel, rhs: CardGameViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    @Published var currentCharacter: Character?
    @Published var characters: [Character] = []
    @Published var currentIndex = 0
    @Published var showAnswer = false
    @Published var gameSession: GameSession
    @Published var currentScore = 0
    @Published var streak = 0
    @Published var isGameOver = false
    @Published var recognitionResult: String? = nil // Résultat de la reconnaissance
    @Published var recognitionIsCorrect: Bool = false // Si la reconnaissance est correcte
    @Published var recognitionFeedbackMessage: String? = nil // Message de feedback (tons, etc.)
    @Published var showRecognitionFeedback = false
    @Published var isRecordingVoice = false // Copie locale pour meilleure réactivité UI

    var timerManager: TimerManager
    let speechService = SpeechRecognitionService.shared // Public pour accès depuis View

    private let dataService = DataPersistenceService.shared
    private let audioService = AudioService.shared
    private let scoringSystem = ScoringSystem.shared

    private var currentCharacterStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    private var initStartTime: Date?

    // MARK: - Helper Functions

    /// Retourne un timestamp formaté pour les logs
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    init(deck: Deck, difficulty: GameSession.Difficulty) {
        initStartTime = Date()
        self.gameSession = GameSession(deck: deck, difficulty: difficulty)
        self.timerManager = TimerManager(timeLimit: difficulty.timeLimit)
        loadCharacters(for: deck)
        setupBindings()
    }

    private func loadCharacters(for deck: Deck) {
        characters = dataService.getCharacters(for: deck).shuffled()
        // NE PAS définir currentCharacter ici pour éviter de déclencher des mises à jour SwiftUI pendant l'init
        // currentCharacter sera défini dans startGame() / nextCharacter()
    }

    private func setupBindings() {
        // Aucun binding spécifique pour le moment
    }

    // MARK: - Contrôle du jeu

    func startGame() {
        currentIndex = 0
        currentScore = 0
        streak = 0
        isGameOver = false
        gameSession.scores = []
        nextCharacter()
    }

    func nextCharacter() {
        guard currentIndex < characters.count else {
            endGame()
            return
        }

        currentCharacter = characters[currentIndex]
        currentCharacterStartTime = Date()

        // En mode débutant, afficher la réponse pendant 3 secondes au début
        if gameSession.difficulty == .beginner {
            showAnswer = true

            // Cacher la réponse après 3 secondes
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showAnswer = false

                // Démarrer le timer après les 3 secondes
                self.timerManager.reset()
                self.timerManager.start { [weak self] in
                    self?.handleTimeUp()
                }
            }
        } else {
            // Pour les autres niveaux, comportement normal
            showAnswer = false

            // Démarrer le timer immédiatement
            timerManager.reset()
            timerManager.start { [weak self] in
                self?.handleTimeUp()
            }
        }
    }

    private func handleTimeUp() {
        // Temps écoulé, afficher automatiquement la réponse
        showAnswer = true
        audioService.playErrorSound()

        // Enregistrer comme échec
        recordAnswer(wasCorrect: false, pronunciationAccuracy: 0.0, hintUsed: false)
    }

    func showHint() {
        showAnswer = true
        // Ne pas arrêter le timer - l'utilisateur doit continuer à répondre

        // Jouer la prononciation
        if let character = currentCharacter {
            audioService.speakCharacter(character)
        }
    }

    func playPronunciation() {
        if let character = currentCharacter {
            audioService.speakCharacter(character)
        }
    }

    // MARK: - Validation réponse

    func startVoiceRecognition() {
        let startTime = Date()

        // Forcer le rafraîchissement UI immédiatement sur le main thread
        if Thread.isMainThread {
            self.isRecordingVoice = true
            self.objectWillChange.send()
        } else {
            DispatchQueue.main.async {
                self.isRecordingVoice = true
                self.objectWillChange.send()
            }
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        print("[\(formatter.string(from: startTime))] 🔴 ViewModel: isRecordingVoice = true")

        do {
            try speechService.startRecording { [weak self] recognizedText, confidence in
                self?.handleVoiceRecognition(
                    recognizedText: recognizedText,
                    confidence: confidence
                )
            }
        } catch {
            print("Erreur reconnaissance vocale: \(error)")
            isRecordingVoice = false
        }
    }

    func stopVoiceRecognition() {
        // Vérifier qu'on est bien en train d'enregistrer
        guard isRecordingVoice && speechService.isRecording else {
            print("⚠️ Arrêt ignoré - pas d'enregistrement en cours")
            isRecordingVoice = false
            return
        }

        print("⏳ Attente traitement de la reconnaissance vocale...")

        speechService.stopRecording()

        // Remettre à false après un délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isRecordingVoice = false
            self.objectWillChange.send()
            print("⚪️ ViewModel: isRecordingVoice = false")
        }
    }

    private func handleVoiceRecognition(recognizedText: String, confidence: Double) {
        guard let character = currentCharacter else { return }

        timerManager.stop()

        // Pour les nombres, accepter aussi les chiffres arabes (ex: "14" pour "十四")
        var alternatives = character.meaning

        // Ajouter le pinyin comme alternative
        alternatives.append(character.pinyin)

        print("📤 ViewModel envoie alternatives: \(alternatives)")

        let result = speechService.validatePronunciation(
            expected: character.simplified,
            recognized: recognizedText,
            difficulty: gameSession.difficulty,
            acceptedAlternatives: alternatives
        )

        // Afficher le résultat à l'utilisateur
        recognitionResult = recognizedText
        recognitionIsCorrect = result.isCorrect
        recognitionFeedbackMessage = result.feedback // ✨ NOUVEAU: afficher le message de feedback
        showRecognitionFeedback = true

        print("🎯 Attendu: '\(character.simplified)' | Reconnu: '\(recognizedText)' | Précision: \(result.accuracy)")
        print("💬 Feedback: '\(result.feedback ?? "nil")'")

        if result.isCorrect {
            audioService.playSuccessSound()
            streak += 1

            // ✅ Réponse correcte : masquer le feedback rapidement et passer au suivant
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showRecognitionFeedback = false
                self.recognitionResult = nil
                self.recognitionFeedbackMessage = nil
            }

            // Passer au suivant après 2 secondes (rapide car réussite)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.moveToNext()
            }
        } else {
            audioService.playErrorSound()
            streak = 0

            // ❌ Réponse incorrecte : afficher l'indice et prononcer
            showAnswer = true

            // En cas d'erreur, prononcer le caractère correct après 0.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("🔊 Prononciation du caractère correct : '\(character.simplified)'")
                self.audioService.speakCharacter(character)
            }

            // Masquer le feedback après 3 secondes
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showRecognitionFeedback = false
                self.recognitionResult = nil
                self.recognitionFeedbackMessage = nil
            }

            // Passer au suivant après 5 secondes (laisser le temps de voir + entendre)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.moveToNext()
            }
        }

        recordAnswer(
            wasCorrect: result.isCorrect,
            pronunciationAccuracy: result.accuracy,
            hintUsed: showAnswer
        )
    }

    func manualValidation(isCorrect: Bool) {
        timerManager.stop()

        if isCorrect {
            audioService.playSuccessSound()
            streak += 1
        } else {
            audioService.playErrorSound()
            streak = 0
        }

        recordAnswer(
            wasCorrect: isCorrect,
            pronunciationAccuracy: isCorrect ? 1.0 : 0.0,
            hintUsed: showAnswer
        )

        showAnswer = true
    }

    private func recordAnswer(wasCorrect: Bool, pronunciationAccuracy: Double, hintUsed: Bool) {
        guard let character = currentCharacter,
              let startTime = currentCharacterStartTime else { return }

        let responseTime = Date().timeIntervalSince(startTime)

        let scoreParams = ScoringSystem.ScoreParameters(
            responseTime: responseTime,
            timeLimit: gameSession.difficulty.timeLimit,
            pronunciationAccuracy: pronunciationAccuracy,
            hintUsed: hintUsed,
            currentStreak: streak,
            wasCorrect: wasCorrect
        )

        let score = scoringSystem.calculateScore(parameters: scoreParams)
        currentScore += score

        let characterScore = CharacterScore(
            characterID: character.id,
            responseTime: responseTime,
            pronunciationAccuracy: pronunciationAccuracy,
            hintUsed: hintUsed,
            wasCorrect: wasCorrect,
            finalScore: score
        )

        gameSession.addScore(characterScore)
    }

    func moveToNext() {
        currentIndex += 1
        nextCharacter()
    }

    private func endGame() {
        isGameOver = true
        timerManager.stop()
        gameSession.complete()

        // Calculer le bonus de session
        let sessionBonus = scoringSystem.calculateSessionBonus(sessionScores: gameSession.scores)
        currentScore += sessionBonus

        // Mettre à jour la progression utilisateur
        dataService.updateProgress(after: gameSession, characters: characters)
    }

    // MARK: - Statistiques

    var correctAnswers: Int {
        gameSession.scores.filter { $0.wasCorrect }.count
    }

    var totalAnswers: Int {
        gameSession.scores.count
    }

    var accuracy: Double {
        guard totalAnswers > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalAnswers)
    }

    var progressPercentage: Double {
        guard !characters.isEmpty else { return 0 }
        return Double(currentIndex) / Double(characters.count)
    }
}
