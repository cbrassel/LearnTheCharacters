//
//  HomeView.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var dataService = DataPersistenceService.shared
    @State private var showMarketplace = false
    @State private var deckToDelete: Deck?
    @State private var showDeleteConfirmation = false
    @State private var selectedDeck: Deck? // Pour la navigation optimisée

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Text("学习汉字")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.primary)

                            Text("Apprendre le chinois")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 30)

                        // User Progress Card
                        UserProgressCard(progress: dataService.userProgress)
                            .padding(.horizontal)

                        // Quick Start
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Commencer")
                                .font(.title2.bold())
                                .padding(.horizontal)

                            if let quickDeck = dataService.quickStartDeck {
                                Button(action: {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm:ss.SSS"
                                    print("🏠 [\(formatter.string(from: Date()))] Clic QuickStart - Deck: '\(quickDeck.name)'")
                                    // Sauvegarder ce deck comme dernier utilisé
                                    dataService.saveLastUsedDeck(quickDeck.id)
                                    selectedDeck = quickDeck
                                }) {
                                    QuickStartCard(deck: quickDeck)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }

                        // Marketplace Button
                        Button(action: {
                            showMarketplace = true
                        }) {
                            HStack {
                                Image(systemName: "square.stack.3d.down.right.fill")
                                    .font(.title2)
                                Text("Découvrir plus de decks")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.horizontal)

                        // All Decks
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Mes decks")
                                    .font(.title2.bold())
                                Spacer()
                                Text("\(dataService.decks.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)

                            if dataService.decks.isEmpty {
                                VStack(spacing: 15) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)

                                    Text("Aucun deck disponible")
                                        .font(.headline)
                                        .foregroundColor(.secondary)

                                    Text("Importez des decks depuis le marketplace!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Button(action: {
                                        showMarketplace = true
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.down.circle.fill")
                                            Text("Importer des decks")
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 15) {
                                    ForEach(dataService.decks) { deck in
                                        ZStack(alignment: .topTrailing) {
                                            Button(action: {
                                                let formatter = DateFormatter()
                                                formatter.dateFormat = "HH:mm:ss.SSS"
                                                print("🏠 [\(formatter.string(from: Date()))] Clic Grid - Deck: '\(deck.name)'")
                                                // Sauvegarder ce deck comme dernier utilisé
                                                dataService.saveLastUsedDeck(deck.id)
                                                selectedDeck = deck
                                            }) {
                                                DeckCard(deck: deck)
                                            }
                                            .buttonStyle(PlainButtonStyle())

                                            // Bouton de suppression
                                            Button(action: {
                                                deckToDelete = deck
                                                showDeleteConfirmation = true
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.red)
                                                    .background(
                                                        Circle()
                                                            .fill(Color.white)
                                                            .frame(width: 24, height: 24)
                                                    )
                                            }
                                            .padding(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showMarketplace) {
                DeckMarketplaceView()
            }
            .alert("Supprimer le deck?", isPresented: $showDeleteConfirmation) {
                Button("Annuler", role: .cancel) {
                    deckToDelete = nil
                }
                Button("Supprimer", role: .destructive) {
                    if let deck = deckToDelete {
                        withAnimation {
                            dataService.deleteDeck(deck)
                        }
                        deckToDelete = nil
                    }
                }
            } message: {
                if let deck = deckToDelete {
                    Text("Êtes-vous sûr de vouloir supprimer '\(deck.name)'? Cette action est irréversible.")
                }
            }
            .navigationDestination(item: $selectedDeck) { deck in
                DifficultySelectionView(deck: deck)
            }
        }
    }
}

struct UserProgressCard: View {
    let progress: UserProgress

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Niveau")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 5) {
                        Text(progress.level.icon)
                            .font(.title)
                        Text(progress.level.displayName)
                            .font(.title2.bold())
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text("Score total")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(progress.totalScore)")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                }
            }

            Divider()

            HStack {
                ProgressStatItem(
                    icon: "character.book.closed",
                    value: "\(progress.charactersLearned.count)",
                    label: "Caractères"
                )

                Spacer()

                ProgressStatItem(
                    icon: "flame.fill",
                    value: "\(progress.streak)",
                    label: "Série"
                )

                Spacer()

                ProgressStatItem(
                    icon: "percent",
                    value: String(format: "%.0f%%", progress.statistics.successRate * 100),
                    label: "Réussite"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
    }
}

struct ProgressStatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)

            Text(value)
                .font(.headline.bold())

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct QuickStartCard: View {
    let deck: Deck

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: deck.category.icon)
                .font(.system(size: 40))
                .foregroundColor(deck.category.color)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(deck.category.color.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 5) {
                Text("Démarrage rapide")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(deck.name)
                    .font(.title3.bold())
                    .foregroundColor(.primary)

                Text("\(deck.characterCount) caractères")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .padding(.horizontal)
    }
}

struct DeckCard: View {
    let deck: Deck

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: deck.category.icon)
                .font(.system(size: 30))
                .foregroundColor(deck.category.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(deck.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(deck.characterCount) caractères")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            HStack {
                ForEach(deck.tags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(deck.category.color.opacity(0.2))
                        )
                        .foregroundColor(deck.category.color)
                }
            }
        }
        .padding()
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
    }
}

#Preview {
    HomeView()
}
