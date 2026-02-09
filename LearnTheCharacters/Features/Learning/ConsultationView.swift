//
//  ConsultationView.swift
//  LearnTheCharacters
//
//  Created by Claude on 19/11/2025.
//

import SwiftUI
import Combine

struct ConsultationView: View {
    @StateObject private var viewModel: ConsultationViewModel
    @Environment(\.dismiss) private var dismiss

    init(deck: Deck) {
        _viewModel = StateObject(wrappedValue: ConsultationViewModel(deck: deck))
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Progress indicator
                    Text("\(viewModel.currentIndex + 1) / \(viewModel.characters.count)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // Placeholder pour équilibrer
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)

                // Progress bar
                ProgressView(value: viewModel.progressPercentage)
                    .tint(.blue)
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                Spacer()
                    .frame(maxHeight: 30)

                // Card avec gestes
                if let character = viewModel.currentCharacter {
                    CharacterCardView(
                        character: character,
                        showAnswer: viewModel.showAnswer
                    )
                    .frame(height: 400)
                    .padding(.horizontal, 30)
                    .gesture(
                        DragGesture(minimumDistance: 50)
                            .onEnded { value in
                                if value.translation.width > 50 {
                                    // Swipe à droite = précédent
                                    withAnimation(.spring()) {
                                        viewModel.moveToPrevious()
                                    }
                                } else if value.translation.width < -50 {
                                    // Swipe à gauche = suivant
                                    withAnimation(.spring()) {
                                        viewModel.moveToNext()
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        // Tap = toggle answer
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            viewModel.toggleAnswer()
                        }
                    }
                }

                // Instruction pour l'utilisateur
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Touchez la carte pour changer de vue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)

                Spacer()
                    .frame(minHeight: 10, maxHeight: 15)

                // Navigation buttons
                VStack(spacing: 10) {
                    // Ligne 1: Écouter (pleine largeur)
                    Button(action: {
                        viewModel.playPronunciation()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.body)
                            Text("Écouter")
                                .font(.callout)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.purple)
                        .cornerRadius(12)
                    }

                    // Ligne 2: Précédent + Suivant
                    HStack(spacing: 12) {
                        // Bouton Précédent
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.moveToPrevious()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.body)
                                Text("Précédent")
                                    .font(.callout)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(viewModel.currentIndex > 0 ? Color.orange : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.currentIndex == 0)

                        // Bouton Suivant (toujours actif - consultation infinie)
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.moveToNext()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("Suivant")
                                    .font(.callout)
                                Image(systemName: "chevron.right")
                                    .font(.body)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
    }
}

// ViewModel pour la consultation
class ConsultationViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var currentIndex: Int = 0
    @Published var showAnswer: Bool = true // Commence avec l'indice visible

    private let audioService = AudioService.shared
    private let dataService = DataPersistenceService.shared

    init(deck: Deck) {
        loadCharacters(for: deck)
    }

    private func loadCharacters(for deck: Deck) {
        characters = dataService.getCharacters(for: deck).shuffled()
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

        // Si on dépasse la dernière carte, remélanger et recommencer
        if currentIndex >= characters.count {
            characters.shuffle()
            currentIndex = 0
            print("🔄 Fin du deck atteinte - Cartes remélangées et redémarrage")
        }
        // Ne pas réinitialiser showAnswer pour mémoriser le choix de l'utilisateur
    }

    func moveToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        // Ne pas réinitialiser showAnswer pour mémoriser le choix de l'utilisateur
    }

    func toggleAnswer() {
        showAnswer.toggle()
    }

    func playPronunciation() {
        guard let character = currentCharacter else { return }
        audioService.speakCharacter(character)
    }
}

#Preview {
    ConsultationView(deck: Deck.sample)
}
