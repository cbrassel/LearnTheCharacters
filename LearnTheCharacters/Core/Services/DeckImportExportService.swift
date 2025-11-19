//
//  DeckImportExportService.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation

class DeckImportExportService {
    static let shared = DeckImportExportService()

    private let dataService = DataPersistenceService.shared

    // MARK: - Helper Functions

    /// Retourne un timestamp formaté pour les logs
    private func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    // MARK: - Export

    /// Exporte un deck au format JSON
    func exportDeck(_ deck: Deck) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let exportableDeck = ExportableDeck(from: deck)
        return try encoder.encode(exportableDeck)
    }

    /// Exporte un deck et le sauvegarde dans un fichier
    func exportDeckToFile(_ deck: Deck, filename: String) throws -> URL {
        let data = try exportDeck(deck)

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(filename).json")

        try data.write(to: fileURL)
        return fileURL
    }

    /// Génère une URL de partage pour un deck (via GitHub raw content)
    func generateShareableURL(for deck: Deck) -> String {
        let sanitizedName = deck.name
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)

        return GitHubConfiguration.deckURL(category: "community", filename: "\(sanitizedName).json")
    }

    // MARK: - Import

    /// Importe un deck depuis des données JSON
    func importDeck(from data: Data) throws -> Deck {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let exportableDeck = try decoder.decode(ExportableDeck.self, from: data)
        return exportableDeck.toDeck()
    }

    /// Importe un deck depuis un fichier local
    func importDeckFromFile(_ fileURL: URL) throws -> Deck {
        let data = try Data(contentsOf: fileURL)
        return try importDeck(from: data)
    }

    /// Importe un deck depuis une URL distante (ex: GitHub)
    func importDeckFromURL(_ urlString: String) async throws -> Deck {
        guard let url = URL(string: urlString) else {
            throw ImportError.invalidURL
        }

        // Créer une requête avec authentification si c'est une URL GitHub
        let request: URLRequest
        if urlString.contains("github.com") || urlString.contains("githubusercontent.com") {
            request = GitHubConfiguration.authenticatedRequest(url: url)
        } else {
            request = URLRequest(url: url)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImportError.networkError
        }

        return try importDeck(from: data)
    }

    /// Importe et sauvegarde un deck
    func importAndSaveDeck(from data: Data) throws -> Deck {
        let deck = try importDeck(from: data)
        dataService.saveDeck(deck)
        return deck
    }

    // MARK: - Validation

    /// Valide qu'un fichier JSON est un deck valide
    func validateDeckJSON(_ data: Data) -> Bool {
        do {
            _ = try importDeck(from: data)
            return true
        } catch {
            print("Erreur validation deck: \(error)")
            return false
        }
    }

    // MARK: - Liste des decks communautaires

    /// Récupère la liste des decks disponibles sur le repo GitHub
    func fetchAvailableDecks(category: String = "hsk1") async throws -> [DeckMetadata] {
        let startTime = Date()
        print("⏱️ [\(timestamp())] Début chargement catégorie '\(category)'")

        let apiURL = GitHubConfiguration.apiURL(forCategory: category)

        guard let url = URL(string: apiURL) else {
            throw ImportError.invalidURL
        }

        // Utiliser une requête authentifiée
        print("⏱️ [\(timestamp())] Requête API: \(apiURL)")
        let requestStart = Date()
        let request = GitHubConfiguration.authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        print("⏱️ [\(timestamp())] Réponse API reçue en \(String(format: "%.2f", Date().timeIntervalSince(requestStart)))s")

        // Vérifier la réponse HTTP
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImportError.networkError
        }

        // Si 404, le dossier n'existe pas - retourner un array vide
        if httpResponse.statusCode == 404 {
            print("⏱️ [\(timestamp())] ℹ️ Catégorie '\(category)' n'existe pas (404)")
            return []
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Debug: afficher le code d'erreur et le corps de la réponse
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ [\(timestamp())] Erreur HTTP \(httpResponse.statusCode): \(responseString)")
            }
            throw ImportError.networkError
        }

        // Décoder la réponse
        print("⏱️ [\(timestamp())] Décodage de la liste des fichiers...")
        let decodeStart = Date()
        let files: [GitHubFile]
        do {
            files = try JSONDecoder().decode([GitHubFile].self, from: data)
            print("⏱️ [\(timestamp())] \(files.count) fichier(s) trouvé(s) en \(String(format: "%.3f", Date().timeIntervalSince(decodeStart)))s")
        } catch {
            print("❌ [\(timestamp())] Erreur décodage JSON: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 JSON reçu: \(jsonString)")
            }
            throw ImportError.invalidFormat
        }

        var metadata: [DeckMetadata] = []
        let jsonFiles = files.filter { $0.name.hasSuffix(".json") }
        print("⏱️ [\(timestamp())] \(jsonFiles.count) deck(s) JSON à télécharger")

        for (index, file) in jsonFiles.enumerated() {
            if let downloadURL = URL(string: file.download_url) {
                do {
                    // Utiliser une requête authentifiée pour télécharger
                    print("⏱️ [\(timestamp())] Téléchargement deck \(index + 1)/\(jsonFiles.count): \(file.name)")
                    let downloadStart = Date()
                    let downloadRequest = GitHubConfiguration.authenticatedRequest(url: downloadURL)
                    let (deckData, _) = try await URLSession.shared.data(for: downloadRequest)
                    print("⏱️ [\(timestamp())] Téléchargé \(deckData.count) bytes en \(String(format: "%.2f", Date().timeIntervalSince(downloadStart)))s")

                    let parseStart = Date()
                    let deck = try importDeck(from: deckData)
                    print("⏱️ [\(timestamp())] Deck parsé en \(String(format: "%.3f", Date().timeIntervalSince(parseStart)))s - '\(deck.name)' (\(deck.characterIDs.count) caractères)")

                    metadata.append(DeckMetadata(
                        name: deck.name,
                        description: deck.description,
                        characterCount: deck.characterIDs.count,
                        category: deck.category.rawValue,
                        downloadURL: file.download_url
                    ))
                } catch {
                    print("❌ [\(timestamp())] Erreur chargement metadata pour \(file.name): \(error)")
                }
            }
        }

        let totalTime = Date().timeIntervalSince(startTime)
        print("⏱️ [\(timestamp())] ✅ Catégorie '\(category)' terminée en \(String(format: "%.2f", totalTime))s - \(metadata.count) deck(s) chargé(s)")
        return metadata
    }

    /// Récupère toutes les catégories de decks disponibles
    func fetchAllCategories() async throws -> [String: [DeckMetadata]] {
        let globalStart = Date()
        print("🚀 [\(timestamp())] ========================================")
        print("🚀 [\(timestamp())] DÉBUT CHARGEMENT MARKETPLACE")
        print("🚀 [\(timestamp())] ========================================")

        var allDecks: [String: [DeckMetadata]] = [:]

        let categories = ["hsk1", "hsk2", "hsk3", "thematic", "community"]
        print("⏱️ [\(timestamp())] \(categories.count) catégories à scanner: \(categories.joined(separator: ", "))")

        for (index, category) in categories.enumerated() {
            print("")
            print("📂 [\(timestamp())] --- Catégorie \(index + 1)/\(categories.count): \(category) ---")
            do {
                let decks = try await fetchAvailableDecks(category: category)
                if !decks.isEmpty {
                    allDecks[category] = decks
                    print("✅ [\(timestamp())] Catégorie '\(category)': \(decks.count) deck(s) ajouté(s)")
                } else {
                    print("ℹ️ [\(timestamp())] Catégorie '\(category)': vide")
                }
            } catch ImportError.invalidFormat {
                print("⚠️ [\(timestamp())] Format invalide pour la catégorie \(category)")
            } catch ImportError.networkError {
                print("⚠️ [\(timestamp())] Erreur réseau pour la catégorie \(category)")
            } catch {
                print("⚠️ [\(timestamp())] Impossible de charger la catégorie \(category): \(error)")
            }
        }

        let totalTime = Date().timeIntervalSince(globalStart)
        let totalDecks = allDecks.values.reduce(0) { $0 + $1.count }
        print("")
        print("🏁 [\(timestamp())] ========================================")
        print("🏁 [\(timestamp())] MARKETPLACE CHARGÉ EN \(String(format: "%.2f", totalTime))s")
        print("🏁 [\(timestamp())] Total: \(totalDecks) deck(s) dans \(allDecks.count) catégorie(s)")
        print("🏁 [\(timestamp())] ========================================")

        return allDecks
    }

    // MARK: - Errors

    enum ImportError: LocalizedError {
        case invalidURL
        case networkError
        case invalidFormat
        case missingData

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "URL invalide"
            case .networkError: return "Erreur réseau"
            case .invalidFormat: return "Format de fichier invalide"
            case .missingData: return "Données manquantes"
            }
        }
    }
}

// MARK: - Modèles pour export/import

/// Structure pour l'export/import JSON (inclut les caractères complets)
struct ExportableDeck: Codable {
    let id: UUID
    let name: String
    let description: String
    let category: String
    let characters: [ExportableCharacter]
    let createdDate: Date
    let version: String
    let author: String?

    init(from deck: Deck) {
        self.id = deck.id
        self.name = deck.name
        self.description = deck.description
        self.category = deck.category.rawValue
        self.version = "1.0"
        self.author = nil
        self.createdDate = Date()

        // Récupérer les caractères complets depuis DataPersistenceService
        let allCharacters = DataPersistenceService.shared.getAllCharacters()
        self.characters = deck.characterIDs.compactMap { id in
            if let character = allCharacters.first(where: { $0.id == id }) {
                return ExportableCharacter(from: character)
            }
            return nil
        }
    }

    func toDeck() -> Deck {
        // Sauvegarder les caractères dans DataPersistenceService
        let characters = self.characters.map { $0.toCharacter() }
        let dataService = DataPersistenceService.shared

        for character in characters {
            // Sauvegarder chaque caractère s'il n'existe pas déjà
            let existing = dataService.getAllCharacters().first { $0.id == character.id }
            if existing == nil {
                dataService.saveCharacter(character)
            }
        }

        return Deck(
            id: self.id,
            name: self.name,
            description: self.description,
            category: Category(rawValue: self.category) ?? .custom,
            characterIDs: characters.map { $0.id }
        )
    }
}

struct ExportableCharacter: Codable {
    let id: UUID
    let simplified: String
    let traditional: String?
    let pinyin: String
    let meaning: [String]
    let frequency: Int
    let hskLevel: Int?
    let examples: [String]
    let mnemonics: String?

    init(from character: Character) {
        self.id = character.id
        self.simplified = character.simplified
        self.traditional = character.traditional
        self.pinyin = character.pinyin
        self.meaning = character.meaning
        self.frequency = character.frequency
        self.hskLevel = character.hskLevel
        self.examples = character.examples
        self.mnemonics = character.mnemonics
    }

    func toCharacter() -> Character {
        return Character(
            id: self.id,
            simplified: self.simplified,
            traditional: self.traditional,
            pinyin: self.pinyin,
            meaning: self.meaning,
            frequency: self.frequency,
            hskLevel: self.hskLevel,
            examples: self.examples,
            mnemonics: self.mnemonics
        )
    }
}

/// Métadonnées d'un deck pour l'affichage dans la liste
struct DeckMetadata: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let characterCount: Int
    let category: String
    let downloadURL: String

    init(name: String, description: String, characterCount: Int, category: String, downloadURL: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.characterCount = characterCount
        self.category = category
        self.downloadURL = downloadURL
    }
}

/// Structure pour parser la réponse de l'API GitHub
struct GitHubFile: Codable {
    let name: String
    let download_url: String
}
