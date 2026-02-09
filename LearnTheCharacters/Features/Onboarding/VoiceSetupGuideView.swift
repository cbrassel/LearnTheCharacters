//
//  VoiceSetupGuideView.swift
//  LearnTheCharacters
//
//  Created by Claude on 20/11/2025.
//

import SwiftUI

struct VoiceSetupGuideView: View {
    @StateObject private var voiceService = VoiceAvailabilityService.shared
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasSeenVoiceGuide") private var hasSeenGuide = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding(.top, 20)

                            Text("Voix chinoise requise")
                                .font(.title.bold())

                            Text("Pour profiter pleinement de l'apprentissage, téléchargez une voix chinoise de qualité.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }

                        // Info système
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("iOS \(voiceService.iOSVersion) détecté")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.1))
                        )

                        // Étapes personnalisées
                        VStack(spacing: 16) {
                            ForEach(voiceService.getInstructions()) { step in
                                StepCardView(step: step)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Boutons d'action
                        VStack(spacing: 12) {
                            // Note informative
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Le bouton ci-dessous ouvrira l'app Réglages. Suivez ensuite les étapes ci-dessus.")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.05))
                            )

                            Button(action: {
                                voiceService.openSettings()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.body)
                                    Text("Ouvrir l'app Réglages")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                            }

                            Button(action: {
                                // Revérifier les voix disponibles
                                voiceService.checkVoiceAvailability()

                                // Fermer si voix disponible
                                if voiceService.hasChineseVoice {
                                    hasSeenGuide = true
                                    dismiss()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.body)
                                    Text("J'ai téléchargé la voix")
                                        .font(.headline)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(15)
                            }

                            Button(action: {
                                // Continuer sans voix chinoise
                                hasSeenGuide = true
                                dismiss()
                            }) {
                                Text("Continuer sans voix chinoise")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .underline()
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        hasSeenGuide = true
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

// Vue pour chaque étape
struct StepCardView: View {
    let step: OnboardingStep

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Numéro de l'étape
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Text("\(step.number)")
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }

            // Contenu de l'étape
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: step.icon)
                        .font(.body)
                        .foregroundColor(.blue)

                    Text(step.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                }

                Text(step.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

#Preview {
    VoiceSetupGuideView()
}
