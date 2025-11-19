//
//  Category.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation
import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case numbers = "numbers"
    case travel = "travel"
    case introduction = "introduction"
    case food = "food"
    case family = "family"
    case business = "business"
    case daily = "daily"
    case emotions = "emotions"
    case colors = "colors"
    case animals = "animals"
    case custom = "custom"  // Pour les decks personnalisés

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .numbers: return "Compter"
        case .travel: return "Voyager"
        case .introduction: return "Se présenter"
        case .food: return "Nourriture"
        case .family: return "Famille"
        case .business: return "Affaires"
        case .daily: return "Vie quotidienne"
        case .emotions: return "Émotions"
        case .colors: return "Couleurs"
        case .animals: return "Animaux"
        case .custom: return "Personnalisé"
        }
    }

    var description: String {
        switch self {
        case .numbers:
            return "Apprendre à compter et utiliser les nombres en chinois"
        case .travel:
            return "Vocabulaire essentiel pour voyager en Chine"
        case .introduction:
            return "Se présenter et faire connaissance"
        case .food:
            return "Commander au restaurant et parler de nourriture"
        case .family:
            return "Parler de sa famille et ses proches"
        case .business:
            return "Vocabulaire professionnel et des affaires"
        case .daily:
            return "Expressions du quotidien"
        case .emotions:
            return "Exprimer ses sentiments et émotions"
        case .colors:
            return "Les couleurs et leurs nuances"
        case .animals:
            return "Les animaux et la nature"
        case .custom:
            return "Deck personnalisé importé"
        }
    }

    var targetCharacterCount: Int {
        switch self {
        case .numbers: return 20
        case .travel: return 50
        case .introduction: return 30
        case .food: return 40
        case .family: return 35
        case .business: return 45
        case .daily: return 40
        case .emotions: return 25
        case .colors: return 15
        case .animals: return 30
        case .custom: return 0  // Variable selon le deck
        }
    }

    var icon: String {
        switch self {
        case .numbers: return "123.rectangle"
        case .travel: return "airplane"
        case .introduction: return "hand.wave"
        case .food: return "fork.knife"
        case .family: return "person.3"
        case .business: return "briefcase"
        case .daily: return "house"
        case .emotions: return "face.smiling"
        case .colors: return "paintpalette"
        case .animals: return "pawprint"
        case .custom: return "square.stack.3d.up"
        }
    }

    var color: Color {
        switch self {
        case .numbers: return .blue
        case .travel: return .cyan
        case .introduction: return .green
        case .food: return .orange
        case .family: return .pink
        case .business: return .purple
        case .daily: return .yellow
        case .emotions: return .red
        case .colors: return .indigo
        case .animals: return .brown
        case .custom: return .gray
        }
    }
}
