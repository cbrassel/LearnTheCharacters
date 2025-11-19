//
//  ScoringSystem.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation

class ScoringSystem {
    static let shared = ScoringSystem()

    private let basePoints = 100

    private init() {}

    struct ScoreParameters {
        let responseTime: TimeInterval
        let timeLimit: TimeInterval
        let pronunciationAccuracy: Double // 0.0 to 1.0
        let hintUsed: Bool
        let currentStreak: Int
        let wasCorrect: Bool
    }

    func calculateScore(parameters: ScoreParameters) -> Int {
        guard parameters.wasCorrect else { return 0 }

        var score = basePoints

        // Bonus de rapidité (0-50 points)
        let timeBonus = calculateTimeBonus(
            responseTime: parameters.responseTime,
            timeLimit: parameters.timeLimit
        )
        score += timeBonus

        // Bonus de précision de prononciation (0-100 points)
        let pronunciationBonus = Int(parameters.pronunciationAccuracy * 100)
        score += pronunciationBonus

        // Bonus de série (streak)
        let streakBonus = calculateStreakBonus(streak: parameters.currentStreak)
        score += streakBonus

        // Malus si indice utilisé
        if parameters.hintUsed {
            score -= 30
        }

        return max(0, score)
    }

    private func calculateTimeBonus(responseTime: TimeInterval, timeLimit: TimeInterval) -> Int {
        // Plus rapide = plus de points
        let ratio = 1.0 - (responseTime / timeLimit)
        return Int(ratio * 50)
    }

    private func calculateStreakBonus(streak: Int) -> Int {
        // Bonus exponentiel pour les séries
        switch streak {
        case 0...2:
            return 0
        case 3...4:
            return 10
        case 5...9:
            return 20
        case 10...19:
            return 50
        case 20...49:
            return 100
        default:
            return 200
        }
    }

    func calculateSessionBonus(sessionScores: [CharacterScore]) -> Int {
        var bonus = 0

        // Bonus session parfaite (100% de réussite)
        let successRate = Double(sessionScores.filter { $0.wasCorrect }.count) / Double(sessionScores.count)
        if successRate == 1.0 {
            bonus += 500
        } else if successRate >= 0.9 {
            bonus += 200
        } else if successRate >= 0.8 {
            bonus += 100
        }

        // Bonus vitesse moyenne
        let avgTime = sessionScores.reduce(0.0) { $0 + $1.responseTime } / Double(sessionScores.count)
        if avgTime < 5.0 {
            bonus += 300
        } else if avgTime < 7.0 {
            bonus += 150
        }

        // Bonus précision prononciation moyenne
        let avgAccuracy = sessionScores.reduce(0.0) { $0 + $1.pronunciationAccuracy } / Double(sessionScores.count)
        if avgAccuracy >= 0.95 {
            bonus += 250
        } else if avgAccuracy >= 0.85 {
            bonus += 100
        }

        return bonus
    }
}
