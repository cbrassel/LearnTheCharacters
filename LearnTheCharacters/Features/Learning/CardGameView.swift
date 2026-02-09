//
//  CardGameView.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import SwiftUI

struct CardGameView: View {
    @StateObject private var viewModel: CardGameViewModel
    @Environment(\.dismiss) private var dismiss

    private static var viewInitTime: Date?

    /// Retourne un timestamp formaté pour les logs
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }

    // Initializer pour création à la volée
    init(deck: Deck, difficulty: GameSession.Difficulty) {
        CardGameView.viewInitTime = Date()
        _viewModel = StateObject(wrappedValue: CardGameViewModel(deck: deck, difficulty: difficulty))
    }

    // Initializer pour ViewModel préchargé
    init(viewModel: CardGameViewModel) {
        CardGameView.viewInitTime = Date()
        _viewModel = StateObject(wrappedValue: viewModel)
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

            if viewModel.isGameOver {
                GameOverView(viewModel: viewModel, onRestart: {
                    viewModel.startGame()
                }, onExit: {
                    dismiss()
                })
            } else {
                VStack(spacing: 0) {
                    // Header - 60px total
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // Score
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.body)
                                .foregroundColor(.yellow)
                            Text("\(viewModel.currentScore)")
                                .font(.title3.bold())
                        }

                        Spacer()

                        // Timer
                        TimerView(timerManager: viewModel.timerManager)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .frame(height: 60)

                    // Progress bar - 35px total
                    VStack(spacing: 4) {
                        ProgressView(value: viewModel.progressPercentage)
                            .tint(.blue)
                            .padding(.horizontal)

                        Text("\(viewModel.currentIndex + 1) / \(viewModel.characters.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 35)
                    .padding(.bottom, -15) // Remonter le feedback de 10px

                    // Zone FIXE pour le feedback - 120px (directement sous progress bar)
                    ZStack {
                        Color.clear

                        if viewModel.showRecognitionFeedback, let result = viewModel.recognitionResult {
                            RecognitionFeedbackView(
                                recognizedText: result,
                                isCorrect: viewModel.recognitionIsCorrect,
                                expectedText: viewModel.currentCharacter?.simplified ?? "",
                                feedbackMessage: viewModel.recognitionFeedbackMessage
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(), value: viewModel.showRecognitionFeedback)
                        }
                    }
                    .frame(height: 110)

                    // Spacer flexible pour centrer la carte verticalement
                    Spacer()

                    // Card - 280px (réduit de 20px pour compacter l'affichage)
                    if let character = viewModel.currentCharacter {
                        CharacterCardView(
                            character: character,
                            showAnswer: viewModel.showAnswer
                        )
                        .frame(height: 280)
                        .padding(.horizontal, 30)
                    }

                    Spacer()

                    // Action buttons - Plus compacts
                    VStack(spacing: 10) { // Réduit de 15 à 10
                        if !viewModel.showAnswer {
                            // Voice recognition button - Maintenir pour parler
                            VStack(spacing: 4) { // Réduit de 8 à 4
                                Text(viewModel.isRecordingVoice ? "🎤 Parlez maintenant..." : "Maintenez pour parler")
                                    .font(.caption2) // Plus petit
                                    .foregroundColor(viewModel.isRecordingVoice ? .red : .secondary)

                                RecordButtonView(isRecording: viewModel.isRecordingVoice)
                                    .onLongPressGesture(minimumDuration: 10.0, pressing: { isPressing in
                                        if isPressing {
                                            // Commence à presser
                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "HH:mm:ss.SSS"
                                            print("[\(formatter.string(from: Date()))] 👆 Appui détecté - démarrage enregistrement")
                                            let impact = UIImpactFeedbackGenerator(style: .medium)
                                            impact.impactOccurred()
                                            viewModel.startVoiceRecognition()
                                        } else {
                                            // Relâche
                                            if viewModel.isRecordingVoice {
                                                let formatter = DateFormatter()
                                                formatter.dateFormat = "HH:mm:ss.SSS"
                                                print("[\(formatter.string(from: Date()))] 👆 Relâché - arrêt enregistrement")
                                                let impact = UIImpactFeedbackGenerator(style: .light)
                                                impact.impactOccurred()
                                                viewModel.stopVoiceRecognition()
                                            }
                                        }
                                    }, perform: {
                                        // Ne sera jamais appelé (minimumDuration = 10s)
                                    })
                            }

                            HStack(spacing: 12) { // Réduit de 15 à 12
                                // Hint button
                                Button(action: {
                                    viewModel.showHint()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.body)
                                        Text("Indice")
                                            .font(.callout) // Plus petit
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12) // Réduit de 16 à 12
                                    .background(Color.orange)
                                    .cornerRadius(12)
                                }

                                // Play pronunciation
                                Button(action: {
                                    viewModel.playPronunciation()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.body)
                                        Text("Écouter")
                                            .font(.callout) // Plus petit
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12) // Réduit de 16 à 12
                                    .background(Color.purple)
                                    .cornerRadius(12)
                                }
                            }
                        } else {
                            // Spacer pour garder la même hauteur que les 2 rangées ci-dessus
                            Spacer()
                                .frame(height: 66) // Ajusté pour correspondre aux nouveaux espacements

                            HStack(spacing: 12) { // Réduit de 15 à 12
                                // Bouton Retour (masquer la réponse)
                                Button(action: {
                                    viewModel.showAnswer = false
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "eye.slash")
                                            .font(.body)
                                        Text("Retour")
                                            .font(.callout)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.orange)
                                    .cornerRadius(12)
                                }

                                // Bouton Suivant
                                Button(action: {
                                    viewModel.moveToNext()
                                }) {
                                    HStack(spacing: 4) {
                                        Text("Suivant")
                                            .font(.callout)
                                        Image(systemName: "arrow.right")
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
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 30) // Augmenté de 10 à 30px pour le bouton Prononcer et son animation
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startGame()
        }
    }
}

// MARK: - Record Button View
struct RecordButtonView: View {
    let isRecording: Bool

    var body: some View {
        ZStack {
            // Animation pulse permanent quand isRecording = true
            if isRecording {
                PulseCircle()
            }

            // Bouton principal
            HStack(spacing: 8) {
                Image(systemName: isRecording ? "waveform" : "mic.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                Text(isRecording ? "En écoute..." : "Prononcer")
                    .foregroundColor(.white)
            }
            .font(.title3.bold())
            .frame(maxWidth: .infinity)
            .padding()
            .background(isRecording ? Color.red : Color.blue)
            .cornerRadius(15)
            .shadow(color: isRecording ? Color.red.opacity(0.6) : Color.blue.opacity(0.3), radius: isRecording ? 15 : 5)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isRecording ? Color.white : Color.clear, lineWidth: 3)
            )
            .scaleEffect(isRecording ? 1.05 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
    }
}

// Animation pulse séparée
struct PulseCircle: View {
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(Color.red, lineWidth: 4)
            .frame(width: 80, height: 80)
            .scaleEffect(animate ? 2.0 : 1.0)
            .opacity(animate ? 0.0 : 0.8)
            .onAppear {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss.SSS"
                print("[\(formatter.string(from: Date()))] 🎨 Animation pulse démarrée")

                withAnimation(Animation.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
    }
}

// MARK: - Recognition Feedback View
struct RecognitionFeedbackView: View {
    let recognizedText: String
    let isCorrect: Bool
    let expectedText: String
    var feedbackMessage: String? = nil // ✨ NOUVEAU paramètre optionnel

    var body: some View {
        HStack(spacing: 6) {
            // Icône de succès/erreur - Plus petite
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 2) {
                // Afficher le message de feedback s'il existe, sinon le message par défaut
                Text(feedbackMessage ?? (isCorrect ? "✅ Correct !" : "❌ Incorrect"))
                    .font(.caption.bold())
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Text("Vous:")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    Text(recognizedText)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }

                // Afficher le caractère attendu si erreur
                if !isCorrect {
                    HStack(spacing: 4) {
                        Text("Attendu:")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        Text(expectedText)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: isCorrect ? [Color.green, Color.teal] : [Color.red, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isCorrect ? .green.opacity(0.4) : .red.opacity(0.4), radius: 8, y: 3)
        )
        .padding(.horizontal, 30)
    }
}

struct GameOverView: View {
    @ObservedObject var viewModel: CardGameViewModel
    let onRestart: () -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("🎉 Session terminée!")
                .font(.system(size: 40, weight: .bold))

            VStack(spacing: 20) {
                StatRow(
                    icon: "star.fill",
                    label: "Score total",
                    value: "\(viewModel.currentScore)",
                    color: .yellow
                )

                StatRow(
                    icon: "checkmark.circle.fill",
                    label: "Réussite",
                    value: "\(viewModel.correctAnswers)/\(viewModel.totalAnswers)",
                    color: .green
                )

                StatRow(
                    icon: "percent",
                    label: "Précision",
                    value: String(format: "%.0f%%", viewModel.accuracy * 100),
                    color: .blue
                )

                StatRow(
                    icon: "flame.fill",
                    label: "Meilleure série",
                    value: "\(viewModel.streak)",
                    color: .orange
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
            .padding(.horizontal)

            VStack(spacing: 15) {
                Button(action: onRestart) {
                    Text("Recommencer")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }

                Button(action: onExit) {
                    Text("Quitter")
                        .font(.title3.bold())
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            Text(label)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.title3.bold())
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    CardGameView(
        deck: Deck.sample,
        difficulty: .beginner
    )
}
