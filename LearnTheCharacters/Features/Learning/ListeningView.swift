//
//  ListeningView.swift
//  LearnTheCharacters
//
//  Created by Claude on 03/01/2026.
//

import SwiftUI
import Combine

struct ListeningView: View {
    @StateObject private var viewModel: ListeningViewModel
    @Environment(\.dismiss) private var dismiss

    init(deck: Deck) {
        _viewModel = StateObject(wrappedValue: ListeningViewModel(deck: deck))
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.indigo.opacity(0.1), Color.cyan.opacity(0.1)],
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

                    // Icône mode écoute
                    Image(systemName: "ear.fill")
                        .font(.title3)
                        .foregroundColor(.indigo)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)

                // Progress bar
                ProgressView(value: viewModel.progressPercentage)
                    .tint(.indigo)
                    .padding(.horizontal)
                    .padding(.bottom, 30)

                Spacer()

                // Contenu principal
                if let character = viewModel.currentCharacter,
                   let sentence = viewModel.currentSentence {

                    VStack(spacing: 25) {
                        // Caractère en grand
                        Text(character.simplified)
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(.primary)

                        // Pinyin du caractère
                        Text(character.pinyin)
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Divider()
                            .padding(.horizontal, 40)

                        // Phrase d'écoute en chinois
                        Text(sentence)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 30)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        // Zone de traduction (toggle)
                        if viewModel.showTranslation {
                            VStack(spacing: 12) {
                                // Traduction du caractère
                                VStack(spacing: 4) {
                                    Text("Caractère \(character.simplified):")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(character.displayMeaning)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.indigo)
                                        .multilineTextAlignment(.center)
                                }

                                Divider()

                                // Traduction de la phrase (à implémenter dans les JSONs)
                                VStack(spacing: 4) {
                                    Text("Phrase:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Essayez de comprendre le sens général")
                                        .font(.caption)
                                        .italic()
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding()
                            .background(Color.indigo.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 30)
                            .transition(.opacity.combined(with: .scale))
                        }

                        // Instruction
                        HStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(viewModel.showTranslation ? "Touchez pour cacher la traduction" : "Touchez pour voir la traduction")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleTranslation()
                        }
                    }
                } else {
                    // Fallback si pas de phrase d'écoute
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text("Aucune phrase d'écoute disponible")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        Text("Ce caractère n'a pas encore de phrases d'écoute.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }

                Spacer()

                // Boutons de navigation
                VStack(spacing: 10) {
                    // Ligne 1: Écouter la phrase (pleine largeur)
                    Button(action: {
                        viewModel.playSentence()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: viewModel.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                .font(.body)
                            Text(viewModel.isPlaying ? "Lecture en cours..." : "Écouter la phrase")
                                .font(.callout)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(viewModel.currentSentence != nil ? Color.indigo : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.currentSentence == nil)

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

                        // Bouton Suivant
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
                            .background(Color.cyan)
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
        .onAppear {
            // Lecture automatique de la première phrase
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.playSentence()
            }
        }
    }
}

// ViewModel pour le mode écoute
class ListeningViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var currentIndex: Int = 0
    @Published var currentSentenceIndex: Int = 0
    @Published var showTranslation: Bool = false
    @Published var isPlaying: Bool = false

    private let audioService = AudioService.shared
    private let dataService = DataPersistenceService.shared

    init(deck: Deck) {
        loadCharacters(for: deck)
    }

    private func loadCharacters(for deck: Deck) {
        characters = dataService.getCharacters(for: deck).shuffled()
        selectRandomSentence()
    }

    var currentCharacter: Character? {
        guard currentIndex < characters.count else { return nil }
        return characters[currentIndex]
    }

    var currentSentence: String? {
        guard let character = currentCharacter,
              !character.listeningSentences.isEmpty else { return nil }
        guard currentSentenceIndex < character.listeningSentences.count else { return nil }
        return character.listeningSentences[currentSentenceIndex]
    }

    var progressPercentage: Double {
        guard !characters.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(characters.count)
    }

    private func selectRandomSentence() {
        guard let character = currentCharacter,
              !character.listeningSentences.isEmpty else {
            currentSentenceIndex = 0
            return
        }
        // Sélectionner une phrase aléatoire parmi les 4-5 disponibles
        currentSentenceIndex = Int.random(in: 0..<character.listeningSentences.count)
        print("👂 Phrase sélectionnée: \(currentSentenceIndex + 1)/\(character.listeningSentences.count)")
    }

    func moveToNext() {
        currentIndex += 1
        showTranslation = false // Cacher la traduction pour le prochain

        // Si on dépasse la dernière carte, remélanger et recommencer
        if currentIndex >= characters.count {
            characters.shuffle()
            currentIndex = 0
            print("🔄 Fin du deck atteinte - Cartes remélangées et redémarrage")
        }

        // Sélectionner une nouvelle phrase aléatoire
        selectRandomSentence()

        // Lecture automatique de la nouvelle phrase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.playSentence()
        }
    }

    func moveToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        showTranslation = false

        // Sélectionner une nouvelle phrase aléatoire
        selectRandomSentence()
    }

    func toggleTranslation() {
        showTranslation.toggle()
    }

    func playSentence() {
        guard let sentence = currentSentence else {
            print("❌ Pas de phrase à lire")
            return
        }

        isPlaying = true
        print("🔊 Lecture de la phrase: \(sentence)")

        // Utiliser le service audio pour lire la phrase en chinois (vitesse ralentie pour l'apprentissage)
        audioService.speakText(sentence, language: "zh-CN", rate: 0.35)

        // Réinitialiser l'état après un délai estimé
        // (2 secondes + 0.5s par caractère comme approximation)
        let estimatedDuration = 2.0 + Double(sentence.count) * 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration) {
            self.isPlaying = false
        }
    }
}

#Preview {
    ListeningView(deck: Deck.sample)
}
