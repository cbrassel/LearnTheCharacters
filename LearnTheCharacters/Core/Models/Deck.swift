//
//  Deck.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation

struct Deck: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var category: Category
    var characterIDs: [UUID]
    var isPublic: Bool
    var createdBy: String?
    var tags: [String]
    var createdDate: Date
    var lastModifiedDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        category: Category,
        characterIDs: [UUID] = [],
        isPublic: Bool = false,
        createdBy: String? = nil,
        tags: [String] = [],
        createdDate: Date = Date(),
        lastModifiedDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.characterIDs = characterIDs
        self.isPublic = isPublic
        self.createdBy = createdBy
        self.tags = tags
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }

    var characterCount: Int {
        characterIDs.count
    }

    mutating func addCharacter(_ characterID: UUID) {
        if !characterIDs.contains(characterID) {
            characterIDs.append(characterID)
            lastModifiedDate = Date()
        }
    }

    mutating func removeCharacter(_ characterID: UUID) {
        characterIDs.removeAll { $0 == characterID }
        lastModifiedDate = Date()
    }
}

// Extension pour les decks par défaut
extension Deck {
    static func createDefaultDecks() -> [Deck] {
        return Category.allCases.map { category in
            Deck(
                name: category.displayName,
                description: category.description,
                category: category,
                isPublic: true,
                createdBy: "System"
            )
        }
    }

    static let sample = Deck(
        name: "HSK 1 Basique",
        description: "Les 150 caractères essentiels du HSK niveau 1",
        category: .introduction,
        characterIDs: Character.sampleCharacters.map { $0.id },
        isPublic: true,
        tags: ["HSK1", "débutant", "essentiel"]
    )
}
