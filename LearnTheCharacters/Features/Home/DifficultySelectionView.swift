//
//  DifficultySelectionView.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import SwiftUI

struct DifficultySelectionView: View {
    let deck: Deck
    @State private var selectedDifficulty: GameSession.Difficulty = .consultation
    @State private var navigateToGame = false

    init(deck: Deck) {
        self.deck = deck
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Deck info
                VStack(spacing: 10) {
                    Text(deck.name)
                        .font(.title2.bold())
                        .padding(.top, 20)

                    Text(deck.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 30)

                    Text("\(deck.characterCount) caractères")
                        .font(.headline)
                        .foregroundColor(.blue)
                }

                // Difficulty selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choisissez votre niveau")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ForEach(GameSession.Difficulty.allCases, id: \.self) { difficulty in
                            DifficultyButton(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty
                            ) {
                                selectedDifficulty = difficulty
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
                    .frame(minHeight: 10, maxHeight: 20)

                // Start button
                Button(action: {
                    navigateToGame = true
                }) {
                    Text("Commencer")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sélectionner le mode")
                    .font(.headline)
            }
        }
        .navigationDestination(isPresented: $navigateToGame) {
            if selectedDifficulty == .consultation {
                ConsultationView(deck: deck)
            } else if selectedDifficulty == .listening {
                ListeningView(deck: deck)
            } else if selectedDifficulty == .writing {
                WritingPracticeView(deck: deck)
            } else if selectedDifficulty == .mediaReview {
                MediaReviewView(deck: deck)
            } else {
                CardGameView(deck: deck, difficulty: selectedDifficulty)
            }
        }
    }
}

struct DifficultyButton: View {
    let difficulty: GameSession.Difficulty
    let isSelected: Bool
    let action: () -> Void

    private func descriptionFor(difficulty: GameSession.Difficulty) -> String {
        switch difficulty {
        case .consultation:
            return "Pas de chronomètre"
        case .listening:
            return "Écoute de phrases"
        case .writing:
            return "Ordre des traits"
        case .mediaReview:
            return "Audio et vidéo du deck"
        default:
            return "\(Int(difficulty.timeLimit))s par caractère"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(difficulty.icon)
                    .font(.system(size: 30))

                VStack(alignment: .leading, spacing: 5) {
                    Text(difficulty.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(descriptionFor(difficulty: difficulty))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        DifficultySelectionView(deck: Deck.sample)
    }
}
