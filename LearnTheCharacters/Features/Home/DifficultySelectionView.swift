//
//  DifficultySelectionView.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import SwiftUI

struct DifficultySelectionView: View {
    let deck: Deck
    @State private var selectedDifficulty: GameSession.Difficulty = .beginner
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

            VStack(spacing: 25) {
                // Deck info
                VStack(spacing: 12) {
                    Text(deck.name)
                        .font(.title.bold())
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
                VStack(alignment: .leading, spacing: 15) {
                    Text("Choisissez votre niveau")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    VStack(spacing: 15) {
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
                    .frame(minHeight: 20, maxHeight: 40)

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
        .navigationTitle("Sélectionner la difficulté")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToGame) {
            CardGameView(deck: deck, difficulty: selectedDifficulty)
        }
    }
}

struct DifficultyButton: View {
    let difficulty: GameSession.Difficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(difficulty.icon)
                    .font(.system(size: 30))

                VStack(alignment: .leading, spacing: 5) {
                    Text(difficulty.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(Int(difficulty.timeLimit))s par caractère")
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
