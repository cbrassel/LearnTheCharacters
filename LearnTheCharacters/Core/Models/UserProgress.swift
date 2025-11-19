//
//  UserProgress.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation

struct UserProgress: Codable {
    var userId: UUID
    var charactersLearned: Set<UUID>
    var totalScore: Int
    var streak: Int
    var lastPracticeDate: Date?
    var statistics: LearningStatistics
    var achievements: [Achievement]
    var level: ProgressLevel

    init(
        userId: UUID = UUID(),
        charactersLearned: Set<UUID> = [],
        totalScore: Int = 0,
        streak: Int = 0,
        lastPracticeDate: Date? = nil,
        statistics: LearningStatistics = LearningStatistics(),
        achievements: [Achievement] = [],
        level: ProgressLevel = .bronze
    ) {
        self.userId = userId
        self.charactersLearned = charactersLearned
        self.totalScore = totalScore
        self.streak = streak
        self.lastPracticeDate = lastPracticeDate
        self.statistics = statistics
        self.achievements = achievements
        self.level = level
    }

    mutating func updateAfterSession(charactersStudied: [UUID], sessionScore: Int, accuracy: Double) {
        totalScore += sessionScore
        charactersLearned.formUnion(charactersStudied)

        // Mise à jour du streak
        if let lastDate = lastPracticeDate {
            let calendar = Calendar.current
            if calendar.isDateInToday(lastDate) {
                // Même jour, pas de changement
            } else if calendar.isDateInYesterday(lastDate) {
                streak += 1
            } else {
                streak = 1 // Reset du streak
            }
        } else {
            streak = 1
        }

        lastPracticeDate = Date()

        // Mise à jour des statistiques
        statistics.totalAttempts += charactersStudied.count
        statistics.updateSuccessRate(accuracy: accuracy)

        // Mise à jour du niveau
        level = ProgressLevel.from(score: totalScore)
    }
}

struct LearningStatistics: Codable {
    var totalAttempts: Int
    var successfulAttempts: Int
    var averageResponseTime: TimeInterval
    var difficultCharacters: [UUID]
    var masteredCharacters: [UUID]
    var totalStudyTime: TimeInterval

    init(
        totalAttempts: Int = 0,
        successfulAttempts: Int = 0,
        averageResponseTime: TimeInterval = 0,
        difficultCharacters: [UUID] = [],
        masteredCharacters: [UUID] = [],
        totalStudyTime: TimeInterval = 0
    ) {
        self.totalAttempts = totalAttempts
        self.successfulAttempts = successfulAttempts
        self.averageResponseTime = averageResponseTime
        self.difficultCharacters = difficultCharacters
        self.masteredCharacters = masteredCharacters
        self.totalStudyTime = totalStudyTime
    }

    var successRate: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(successfulAttempts) / Double(totalAttempts)
    }

    mutating func updateSuccessRate(accuracy: Double) {
        let newSuccessful = Int(accuracy * Double(totalAttempts))
        successfulAttempts = newSuccessful
    }
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let dateEarned: Date
    let type: AchievementType

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        icon: String,
        dateEarned: Date = Date(),
        type: AchievementType
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.dateEarned = dateEarned
        self.type = type
    }
}

enum AchievementType: String, Codable {
    case firstCharacter = "first_character"
    case streak7 = "streak_7"
    case streak30 = "streak_30"
    case score1000 = "score_1000"
    case score5000 = "score_5000"
    case hsk1Complete = "hsk1_complete"
    case perfect10 = "perfect_10"
}

enum ProgressLevel: String, Codable {
    case bronze = "bronze"
    case silver = "silver"
    case gold = "gold"
    case diamond = "diamond"
    case master = "master"

    var displayName: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Argent"
        case .gold: return "Or"
        case .diamond: return "Diamant"
        case .master: return "Maître"
        }
    }

    var icon: String {
        switch self {
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🥇"
        case .diamond: return "💎"
        case .master: return "🏆"
        }
    }

    var minScore: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 1001
        case .gold: return 5001
        case .diamond: return 10001
        case .master: return 25001
        }
    }

    static func from(score: Int) -> ProgressLevel {
        if score >= 25001 { return .master }
        if score >= 10001 { return .diamond }
        if score >= 5001 { return .gold }
        if score >= 1001 { return .silver }
        return .bronze
    }
}
