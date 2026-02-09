//
//  WritingPracticeView.swift
//  LearnTheCharacters
//
//  Created by Claude on 03/01/2026.
//

import SwiftUI

/// Vue principale pour le mode d'apprentissage de l'écriture
struct WritingPracticeView: View {
    @StateObject private var viewModel: WritingPracticeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var animationViewID = UUID() // Pour forcer le refresh de StrokeAnimationView

    init(deck: Deck) {
        _viewModel = StateObject(wrappedValue: WritingPracticeViewModel(deck: deck))
    }

    var body: some View {
        ZStack {
            // Gradient de fond
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.teal.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header - 60px FIXE
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("\(viewModel.currentIndex + 1) / \(viewModel.characters.count)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "pencil.tip")
                        .font(.title3)
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .frame(height: 60)

                // Barre de progression - 35px FIXE
                VStack(spacing: 4) {
                    ProgressView(value: viewModel.progressPercentage)
                        .tint(.green)
                }
                .padding(.horizontal)
                .frame(height: 35)

                Spacer()

                // Contenu principal
                if let character = viewModel.currentCharacter {
                    if let strokeOrder = character.strokeOrder {
                        VStack(spacing: 20) {
                            // Info caractère
                            VStack(spacing: 8) {
                                Text(character.simplified)
                                    .font(.system(size: 60, weight: .light))
                                Text(character.pinyin)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                Text(character.displayMeaning)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            // Sélecteur Animation / Dessin
                            Picker("Mode", selection: $viewModel.showAnimation) {
                                Text("Animation").tag(true)
                                Text("Dessiner").tag(false)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 30)
                            .onChange(of: viewModel.showAnimation) { oldValue, newValue in
                                // Forcer le refresh de l'animation si on revient en mode animation
                                if newValue == true {
                                    animationViewID = UUID()
                                }
                            }

                            // Zone d'animation ou de dessin
                            if viewModel.showAnimation {
                                StrokeAnimationView(
                                    strokeOrder: strokeOrder,
                                    character: character
                                )
                                .id(animationViewID)
                                .frame(width: 300, height: 300)
                            } else {
                                DrawingCanvasView(
                                    character: character,
                                    currentPath: $viewModel.currentPath,
                                    completedPaths: $viewModel.completedPaths
                                )
                                .frame(width: 300, height: 300)
                            }
                        }
                    } else {
                        // Pas de données de stroke order
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)

                            Text("Données d'écriture non disponibles")
                                .font(.title3)
                                .foregroundColor(.secondary)

                            Text("Ce caractère n'a pas encore de données d'ordre des traits.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                } else {
                    // Aucun caractère disponible
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text("Aucun caractère disponible")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        Text("Ce deck ne contient pas de caractères avec données d'écriture.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }

                Spacer()

                // Boutons de contrôle
                VStack(spacing: 10) {
                    // Ligne 1: Boutons d'action
                    HStack(spacing: 12) {
                        if viewModel.showAnimation {
                            // Bouton Animer/Rejouer
                            Button(action: {
                                if let character = viewModel.currentCharacter,
                                   character.strokeOrder != nil {
                                    // Forcer un nouveau rendu de StrokeAnimationView
                                    animationViewID = UUID()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                    Text("Animer")
                                }
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                        } else {
                            // Bouton Effacer
                            Button(action: {
                                viewModel.clearCanvas()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                    Text("Effacer")
                                }
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.completedPaths.isEmpty && viewModel.currentPath.isEmpty)
                        }

                        // Bouton Écouter
                        Button(action: {
                            viewModel.playPronunciation()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("Écouter")
                            }
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                    }

                    // Ligne 2: Navigation
                    HStack(spacing: 12) {
                        // Bouton Précédent
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.moveToPrevious()
                                animationViewID = UUID()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Précédent")
                            }
                            .font(.callout)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(viewModel.currentIndex > 0 ? Color.teal : Color.gray)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.currentIndex == 0)

                        // Bouton Suivant
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.moveToNext()
                                animationViewID = UUID()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("Suivant")
                                Image(systemName: "chevron.right")
                            }
                            .font(.callout)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    WritingPracticeView(deck: Deck.sample)
}
