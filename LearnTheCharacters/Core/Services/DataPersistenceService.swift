//
//  DataPersistenceService.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation
import Combine

class DataPersistenceService: ObservableObject {
    static let shared = DataPersistenceService()

    @Published var characters: [Character] = []
    @Published var decks: [Deck] = []
    @Published var userProgress: UserProgress
    @Published var lastUsedDeckID: UUID?

    private let charactersKey = "saved_characters"
    private let decksKey = "saved_decks"
    private let userProgressKey = "user_progress"
    private let lastUsedDeckKey = "last_used_deck_id"

    private init() {
        // Initialiser avec des données vides
        self.userProgress = UserProgress()

        // Charger les données sauvegardées
        loadAllData()

        // Si aucune donnée, charger les données par défaut
        if characters.isEmpty {
            loadDefaultCharacters()
        }
        if decks.isEmpty {
            loadDefaultDecks()
        }

        // Charger le dernier deck utilisé
        loadLastUsedDeckID()
    }

    // MARK: - Chargement données

    private func loadAllData() {
        characters = loadCharacters()
        decks = loadDecks()
        userProgress = loadUserProgress()
    }

    private func loadCharacters() -> [Character] {
        guard let data = UserDefaults.standard.data(forKey: charactersKey),
              let characters = try? JSONDecoder().decode([Character].self, from: data) else {
            return []
        }
        return characters
    }

    private func loadDecks() -> [Deck] {
        guard let data = UserDefaults.standard.data(forKey: decksKey),
              let decks = try? JSONDecoder().decode([Deck].self, from: data) else {
            return []
        }
        return decks
    }

    private func loadUserProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: userProgressKey),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return UserProgress()
        }
        return progress
    }

    private func loadLastUsedDeckID() {
        if let uuidString = UserDefaults.standard.string(forKey: lastUsedDeckKey),
           let uuid = UUID(uuidString: uuidString) {
            lastUsedDeckID = uuid
        }
    }

    // MARK: - Sauvegarde données

    func saveCharacters() {
        if let data = try? JSONEncoder().encode(characters) {
            UserDefaults.standard.set(data, forKey: charactersKey)
        }
    }

    func saveDecks() {
        if let data = try? JSONEncoder().encode(decks) {
            UserDefaults.standard.set(data, forKey: decksKey)
        }
    }

    func saveUserProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(data, forKey: userProgressKey)
        }
    }

    func saveAll() {
        saveCharacters()
        saveDecks()
        saveUserProgress()
    }

    func saveLastUsedDeck(_ deckID: UUID) {
        lastUsedDeckID = deckID
        UserDefaults.standard.set(deckID.uuidString, forKey: lastUsedDeckKey)
    }

    var quickStartDeck: Deck? {
        // Retourner le dernier deck utilisé s'il existe
        if let lastID = lastUsedDeckID,
           let deck = decks.first(where: { $0.id == lastID }) {
            return deck
        }
        // Sinon retourner le premier deck disponible
        return decks.first
    }

    // MARK: - Gestion caractères

    func addCharacter(_ character: Character) {
        characters.append(character)
        saveCharacters()
    }

    func getCharacter(by id: UUID) -> Character? {
        characters.first { $0.id == id }
    }

    func getCharacters(for deck: Deck) -> [Character] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let startTime = Date()

        print("🔍 [\(formatter.string(from: Date()))] getCharacters() - Recherche de \(deck.characterIDs.count) caractères")
        print("🔍 [\(formatter.string(from: Date()))] Total de caractères en mémoire: \(characters.count)")

        // Optimisation: Convertir characterIDs en Set pour recherche O(1)
        let idSet = Set(deck.characterIDs)
        let result = characters.filter { idSet.contains($0.id) }

        let elapsed = Date().timeIntervalSince(startTime)
        print("🔍 [\(formatter.string(from: Date()))] getCharacters() terminé en \(String(format: "%.3f", elapsed))s - \(result.count) caractères trouvés")

        return result
    }

    func getAllCharacters() -> [Character] {
        return characters
    }

    func saveCharacter(_ character: Character) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index] = character
        } else {
            characters.append(character)
        }
        saveCharacters()
    }

    // MARK: - Gestion decks

    func addDeck(_ deck: Deck) {
        decks.append(deck)
        saveDecks()
    }

    func updateDeck(_ deck: Deck) {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
            saveDecks()
        }
    }

    func deleteDeck(_ deck: Deck) {
        // Trouver les caractères qui sont utilisés uniquement par ce deck
        let otherDecks = decks.filter { $0.id != deck.id }
        let otherDeckCharacterIDs = Set(otherDecks.flatMap { $0.characterIDs })

        // Supprimer les caractères qui n'appartiennent qu'à ce deck
        let charactersToDelete = deck.characterIDs.filter { !otherDeckCharacterIDs.contains($0) }

        if !charactersToDelete.isEmpty {
            print("🗑️ Suppression de \(charactersToDelete.count) caractères du cache (appartenant uniquement au deck '\(deck.name)')")
            characters.removeAll { charactersToDelete.contains($0.id) }
            saveCharacters()
        }

        // Supprimer le deck
        decks.removeAll { $0.id == deck.id }
        saveDecks()

        print("✅ Deck '\(deck.name)' et son cache supprimés")
    }

    func getDeck(by id: UUID) -> Deck? {
        decks.first { $0.id == id }
    }

    func saveDeck(_ deck: Deck) {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
        } else {
            decks.append(deck)
        }
        saveDecks()
    }

    // MARK: - Gestion progression

    func updateProgress(after session: GameSession, characters: [Character]) {
        let characterIDs = characters.map { $0.id }
        let sessionScore = session.totalScore
        let accuracy = session.averageAccuracy

        userProgress.updateAfterSession(
            charactersStudied: characterIDs,
            sessionScore: sessionScore,
            accuracy: accuracy
        )

        // Vérifier et débloquer achievements
        checkAchievements()

        saveUserProgress()
    }

    private func checkAchievements() {
        var newAchievements: [Achievement] = []

        // Premier caractère
        if userProgress.charactersLearned.count == 1 &&
           !userProgress.achievements.contains(where: { $0.type == .firstCharacter }) {
            newAchievements.append(Achievement(
                title: "Premier pas",
                description: "Apprendre votre premier caractère",
                icon: "star.fill",
                type: .firstCharacter
            ))
        }

        // Streak 7 jours
        if userProgress.streak >= 7 &&
           !userProgress.achievements.contains(where: { $0.type == .streak7 }) {
            newAchievements.append(Achievement(
                title: "Une semaine parfaite",
                description: "7 jours consécutifs d'apprentissage",
                icon: "flame.fill",
                type: .streak7
            ))
        }

        // Score 1000
        if userProgress.totalScore >= 1000 &&
           !userProgress.achievements.contains(where: { $0.type == .score1000 }) {
            newAchievements.append(Achievement(
                title: "Millénaire",
                description: "Atteindre 1000 points",
                icon: "trophy.fill",
                type: .score1000
            ))
        }

        userProgress.achievements.append(contentsOf: newAchievements)
    }

    // MARK: - Données par défaut

    private func loadDefaultCharacters() {
        characters = Character.defaultCharacters
        saveCharacters()
    }

    private func loadDefaultDecks() {
        // Créer un deck de démonstration avec les 100 premiers caractères
        let hsk1Deck = Deck(
            name: "HSK 1 - Essentiels",
            description: "Les 100 premiers caractères essentiels du chinois",
            category: .introduction,
            characterIDs: Character.defaultCharacters.prefix(100).map { $0.id },
            isPublic: true,
            createdBy: "System",
            tags: ["HSK1", "débutant", "essentiel"]
        )

        decks = [hsk1Deck]
        saveDecks()
    }

    // MARK: - Reset

    func resetAllData() {
        characters = []
        decks = []
        userProgress = UserProgress()
        saveAll()
        loadDefaultCharacters()
        loadDefaultDecks()
    }
}
