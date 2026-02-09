//
//  Character.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation
import CoreGraphics

/// Phrase d'écoute avec sa traduction
struct ListeningSentence: Codable, Hashable {
    let chinese: String
    let translation: String
}

/// Données d'ordre des traits pour l'apprentissage de l'écriture
struct StrokeOrderData: Codable, Hashable {
    /// Tableau de chaînes SVG path, un par trait dans l'ordre
    let strokes: [String]

    /// Données de médiane pour chaque trait (optionnel)
    let medians: [[CGPoint]]?

    /// Source d'attribution (ex: "makemeahanzi")
    let source: String

    /// Dimensions du système de coordonnées (typiquement 1024x1024)
    let viewBox: ViewBox

    init(strokes: [String], medians: [[CGPoint]]? = nil, source: String = "makemeahanzi", viewBox: ViewBox = ViewBox(width: 1024, height: 1024)) {
        self.strokes = strokes
        self.medians = medians
        self.source = source
        self.viewBox = viewBox
    }

    /// Structure pour représenter les dimensions du viewBox
    struct ViewBox: Codable, Hashable {
        let width: Double
        let height: Double

        /// Convertit en CGSize pour utilisation SwiftUI
        var size: CGSize {
            CGSize(width: width, height: height)
        }
    }
}

struct Character: Codable, Identifiable, Hashable {
    let id: UUID
    let simplified: String      // 简体字
    let traditional: String?    // 繁體字
    let pinyin: String          // Pīnyīn
    let meaning: [String]       // Traductions
    let audioFileName: String?  // Nom du fichier audio
    let frequency: Int          // Fréquence d'usage
    let hskLevel: Int?          // Niveau HSK (1-6)
    let examples: [String]      // Phrases exemples
    let mnemonics: String?      // Aide mémoire
    let listeningSentences: [ListeningSentence] // 4-5 variations de phrases pour mode écoute
    let strokeOrder: StrokeOrderData?  // Données d'ordre des traits pour l'écriture

    init(
        id: UUID = UUID(),
        simplified: String,
        traditional: String? = nil,
        pinyin: String,
        meaning: [String],
        audioFileName: String? = nil,
        frequency: Int = 0,
        hskLevel: Int? = nil,
        examples: [String] = [],
        mnemonics: String? = nil,
        listeningSentences: [ListeningSentence] = [],
        strokeOrder: StrokeOrderData? = nil
    ) {
        self.id = id
        self.simplified = simplified
        self.traditional = traditional
        self.pinyin = pinyin
        self.meaning = meaning
        self.audioFileName = audioFileName
        self.frequency = frequency
        self.hskLevel = hskLevel
        self.examples = examples
        self.mnemonics = mnemonics
        self.listeningSentences = listeningSentences
        self.strokeOrder = strokeOrder
    }

    var audioFileURL: URL? {
        guard let fileName = audioFileName else { return nil }
        return Bundle.main.url(forResource: fileName, withExtension: "mp3")
    }

    var displayMeaning: String {
        meaning.joined(separator: ", ")
    }
}

// Extension pour les données de test
extension Character {
    static let sampleCharacters: [Character] = [
        Character(
            simplified: "你",
            pinyin: "nǐ",
            meaning: ["tu", "toi", "vous"],
            frequency: 100,
            hskLevel: 1,
            examples: ["你好 (nǐ hǎo) - Bonjour"],
            mnemonics: "Une personne (亻) debout"
        ),
        Character(
            simplified: "好",
            pinyin: "hǎo",
            meaning: ["bien", "bon"],
            frequency: 99,
            hskLevel: 1,
            examples: ["你好 (nǐ hǎo) - Bonjour", "好吗？(hǎo ma?) - Ça va?"],
            mnemonics: "Une femme (女) avec un enfant (子) = bon"
        ),
        Character(
            simplified: "我",
            pinyin: "wǒ",
            meaning: ["je", "moi"],
            frequency: 98,
            hskLevel: 1,
            examples: ["我是 (wǒ shì) - Je suis"],
            mnemonics: "Main (手) tenant une arme (戈)"
        ),
        Character(
            simplified: "是",
            pinyin: "shì",
            meaning: ["être", "oui"],
            frequency: 97,
            hskLevel: 1,
            examples: ["我是学生 (wǒ shì xuéshēng) - Je suis étudiant"],
            mnemonics: "Soleil (日) sur la terre (正)"
        ),
        Character(
            simplified: "爱",
            traditional: "愛",
            pinyin: "ài",
            meaning: ["amour", "aimer"],
            frequency: 85,
            hskLevel: 2,
            examples: ["我爱你 (wǒ ài nǐ) - Je t'aime"],
            mnemonics: "Coeur avec des griffes et un ami"
        )
    ]
}
