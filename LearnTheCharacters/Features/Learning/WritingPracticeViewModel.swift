//
//  WritingPracticeViewModel.swift
//  LearnTheCharacters
//
//  Created by Claude on 03/01/2026.
//

import SwiftUI
import Combine

/// ViewModel pour le mode d'apprentissage de l'écriture
class WritingPracticeViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var currentIndex: Int = 0
    @Published var showAnimation: Bool = true
    @Published var isAnimating: Bool = false

    // État du canvas de dessin
    @Published var currentPath: [CGPoint] = []
    @Published var completedPaths: [[CGPoint]] = []

    private let audioService = AudioService.shared
    private let dataService = DataPersistenceService.shared

    init(deck: Deck) {
        loadCharacters(for: deck)
    }

    private func loadCharacters(for deck: Deck) {
        // Charger UNIQUEMENT les caractères avec strokeOrder
        characters = dataService.getCharacters(for: deck)
            .filter { $0.strokeOrder != nil }
            .shuffled()

        if characters.isEmpty {
            print("⚠️ Aucun caractère avec données de stroke order dans ce deck")
        } else {
            print("✅ \(characters.count) caractères avec stroke order chargés")
        }
    }

    var currentCharacter: Character? {
        guard currentIndex < characters.count else { return nil }
        return characters[currentIndex]
    }

    var progressPercentage: Double {
        guard !characters.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(characters.count)
    }

    func moveToNext() {
        currentIndex += 1

        if currentIndex >= characters.count {
            // Remélanger et recommencer
            characters.shuffle()
            currentIndex = 0
            print("🔄 Fin du deck - Remélange et redémarrage")
        }

        // Réinitialiser l'état
        showAnimation = true
        isAnimating = false
        clearCanvas()
    }

    func moveToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        showAnimation = true
        isAnimating = false
        clearCanvas()
    }

    func playAnimation() {
        isAnimating = true
    }

    func clearCanvas() {
        currentPath.removeAll()
        completedPaths.removeAll()
    }

    func undoLastStroke() {
        if !completedPaths.isEmpty {
            completedPaths.removeLast()
        }
    }

    func playPronunciation() {
        guard let character = currentCharacter else { return }
        audioService.speakText(character.pinyin, language: "zh-CN", rate: 0.5)
    }
}
