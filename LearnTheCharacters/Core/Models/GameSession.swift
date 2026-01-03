//
//  GameSession.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation

struct GameSession: Identifiable {
    let id: UUID
    let deck: Deck
    let difficulty: Difficulty
    var currentCharacterIndex: Int
    var scores: [CharacterScore]
    var startTime: Date
    var endTime: Date?
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        deck: Deck,
        difficulty: Difficulty = .beginner,
        currentCharacterIndex: Int = 0,
        scores: [CharacterScore] = [],
        startTime: Date = Date(),
        endTime: Date? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.deck = deck
        self.difficulty = difficulty
        self.currentCharacterIndex = currentCharacterIndex
        self.scores = scores
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
    }

    enum Difficulty: String, CaseIterable, Codable {
        case consultation = "consultation"
        case listening = "listening"
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"

        var displayName: String {
            switch self {
            case .consultation: return "Consultation"
            case .listening: return "Écoute"
            case .beginner: return "Débutant"
            case .intermediate: return "Intermédiaire"
            case .advanced: return "Avancé"
            }
        }

        var timeLimit: TimeInterval {
            switch self {
            case .consultation: return 0 // Pas de limite de temps
            case .listening: return 0 // Pas de limite de temps
            case .beginner: return 30.0
            case .intermediate: return 20.0
            case .advanced: return 10.0
            }
        }

        var icon: String {
            switch self {
            case .consultation: return "📖"
            case .listening: return "👂"
            case .beginner: return "🌱"
            case .intermediate: return "🌿"
            case .advanced: return "🌳"
            }
        }

        /// Seuils de tolérance pour la validation de prononciation
        /// Retourne (seuil d'acceptation, seuil "presque")
        var pronunciationThresholds: (acceptance: Double, near: Double) {
            switch self {
            case .consultation:
                return (0, 0)          // Pas de validation en mode consultation
            case .listening:
                return (0, 0)          // Pas de validation en mode écoute
            case .beginner:
                return (0.5, 0.4)      // Très tolérant - 50% de similarité suffit
            case .intermediate:
                return (0.65, 0.5)     // Tolérant - 65% de similarité
            case .advanced:
                return (0.80, 0.65)    // Strict - 80% de similarité
            }
        }
    }

    var totalScore: Int {
        scores.reduce(0) { $0 + $1.finalScore }
    }

    var averageAccuracy: Double {
        guard !scores.isEmpty else { return 0 }
        let total = scores.reduce(0.0) { $0 + $1.pronunciationAccuracy }
        return total / Double(scores.count)
    }

    var duration: TimeInterval {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }

    mutating func addScore(_ score: CharacterScore) {
        scores.append(score)
    }

    mutating func complete() {
        endTime = Date()
        isCompleted = true
    }
}

struct CharacterScore: Identifiable, Codable {
    let id: UUID
    let characterID: UUID
    let responseTime: TimeInterval
    let pronunciationAccuracy: Double
    let hintUsed: Bool
    let wasCorrect: Bool
    let finalScore: Int
    let timestamp: Date

    init(
        id: UUID = UUID(),
        characterID: UUID,
        responseTime: TimeInterval,
        pronunciationAccuracy: Double,
        hintUsed: Bool,
        wasCorrect: Bool,
        finalScore: Int,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.characterID = characterID
        self.responseTime = responseTime
        self.pronunciationAccuracy = pronunciationAccuracy
        self.hintUsed = hintUsed
        self.wasCorrect = wasCorrect
        self.finalScore = finalScore
        self.timestamp = timestamp
    }
}
