//
//  DeckMarketplaceView.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import SwiftUI
import Combine

struct DeckMarketplaceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DeckMarketplaceViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if viewModel.isLoading {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Chargement des decks...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.hasError {
                    // Error state
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)

                        Text("Impossible de charger les decks")
                            .font(.headline)

                        Text(viewModel.errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: {
                            viewModel.loadDecks()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Réessayer")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                } else if viewModel.allDecks.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("Aucun deck disponible")
                            .font(.headline)

                        Text("Revenez plus tard ou créez votre propre deck!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    // Content
                    ScrollView {
                        VStack(spacing: 25) {
                            // Header
                            VStack(spacing: 10) {
                                Image(systemName: "square.stack.3d.down.right.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)

                                Text("Marketplace de Decks")
                                    .font(.title.bold())

                                Text("\(viewModel.totalDecksCount) decks disponibles")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top)

                            // Decks by category
                            ForEach(viewModel.sortedCategories, id: \.self) { category in
                                if let decks = viewModel.allDecks[category], !decks.isEmpty {
                                    VStack(alignment: .leading, spacing: 15) {
                                        // Category header
                                        HStack {
                                            Image(systemName: categoryIcon(for: category))
                                                .foregroundColor(categoryColor(for: category))
                                            Text(categoryDisplayName(for: category))
                                                .font(.title2.bold())
                                            Spacer()
                                            Text("\(decks.count)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                        .padding(.horizontal)

                                        // Decks list
                                        ForEach(decks) { deck in
                                            MarketplaceDeckCard(
                                                deck: deck,
                                                onImport: {
                                                    viewModel.importDeck(deck)
                                                },
                                                onDelete: {
                                                    viewModel.deleteDeck(deck)
                                                },
                                                isImporting: viewModel.importingDeckID == deck.id,
                                                isInstalled: viewModel.isDeckInstalled(deck)
                                            )
                                        }
                                    }
                                }
                            }

                            // Footer
                            VStack(spacing: 10) {
                                Text("Vous voulez contribuer?")
                                    .font(.headline)

                                Link(destination: URL(string: "https://github.com/cbrassel/LearnTheCharacters-Decks")!) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text("Visitez le repository GitHub")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 30)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadDecks()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("Deck importé!", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                if let deckName = viewModel.importedDeckName {
                    Text("Le deck '\(deckName)' a été importé avec succès!")
                }
            }
            .alert("Erreur", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Supprimer le deck?", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Annuler", role: .cancel) {
                    viewModel.deckToDelete = nil
                }
                Button("Supprimer", role: .destructive) {
                    viewModel.confirmDelete()
                }
            } message: {
                if let deck = viewModel.deckToDelete {
                    Text("Êtes-vous sûr de vouloir supprimer '\(deck.name)'? Cette action est irréversible.")
                }
            }
        }
        .onAppear {
            viewModel.loadDecks()
        }
    }

    // MARK: - Helper Functions

    private func categoryDisplayName(for category: String) -> String {
        switch category.lowercased() {
        case "hsk1": return "HSK Niveau 1"
        case "hsk2": return "HSK Niveau 2"
        case "hsk3": return "HSK Niveau 3"
        case "thematic": return "Thématiques"
        case "community": return "Communauté"
        default: return category.capitalized
        }
    }

    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "hsk1", "hsk2", "hsk3": return "graduationcap.fill"
        case "thematic": return "tag.fill"
        case "community": return "person.3.fill"
        default: return "folder.fill"
        }
    }

    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "hsk1": return .green
        case "hsk2": return .blue
        case "hsk3": return .purple
        case "thematic": return .orange
        case "community": return .pink
        default: return .gray
        }
    }
}

// MARK: - Marketplace Deck Card Component

struct MarketplaceDeckCard: View {
    let deck: DeckMetadata
    let onImport: () -> Void
    let onDelete: () -> Void
    let isImporting: Bool
    let isInstalled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(deck.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Character count badge
                VStack(spacing: 4) {
                    Text("\(deck.characterCount)")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Text("caractères")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 80)
            }

            // Footer
            HStack {
                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                    Text(deck.category)
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(8)

                Spacer()

                // Import/Delete button
                if isInstalled {
                    // Bouton de suppression
                    Button(action: onDelete) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash.fill")
                            Text("Supprimer")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                } else {
                    // Bouton d'import
                    Button(action: onImport) {
                        HStack(spacing: 6) {
                            if isImporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.down.circle.fill")
                            }
                            Text(isImporting ? "Import..." : "Importer")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isImporting ? Color.gray : Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(isImporting)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - ViewModel

class DeckMarketplaceViewModel: ObservableObject {
    @Published var allDecks: [String: [DeckMetadata]] = [:]
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage = ""
    @Published var importingDeckID: UUID?
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var importedDeckName: String?
    @Published var deckToDelete: DeckMetadata?
    @Published var showDeleteConfirmation = false

    private let importService = DeckImportExportService.shared
    private let dataService = DataPersistenceService.shared

    var totalDecksCount: Int {
        allDecks.values.reduce(0) { $0 + $1.count }
    }

    var sortedCategories: [String] {
        allDecks.keys.sorted { category1, category2 in
            let order = ["hsk1", "hsk2", "hsk3", "thematic", "community"]
            let index1 = order.firstIndex(of: category1.lowercased()) ?? order.count
            let index2 = order.firstIndex(of: category2.lowercased()) ?? order.count
            return index1 < index2
        }
    }

    func loadDecks() {
        isLoading = true
        hasError = false
        errorMessage = ""

        Task {
            do {
                let decks = try await importService.fetchAllCategories()

                await MainActor.run {
                    self.allDecks = decks
                    self.isLoading = false

                    if decks.isEmpty {
                        self.hasError = true
                        self.errorMessage = "Aucun deck trouvé sur GitHub"
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.hasError = true
                    self.errorMessage = "Erreur réseau: \(error.localizedDescription)"
                }
            }
        }
    }

    func importDeck(_ metadata: DeckMetadata) {
        importingDeckID = metadata.id

        Task {
            do {
                let deck = try await importService.importDeckFromURL(metadata.downloadURL)

                // Sauvegarder le deck
                await MainActor.run {
                    dataService.saveDeck(deck)
                    self.importedDeckName = deck.name
                    self.importingDeckID = nil
                    self.showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    self.importingDeckID = nil
                    self.errorMessage = "Impossible d'importer le deck: \(error.localizedDescription)"
                    self.showErrorAlert = true
                }
            }
        }
    }

    func isDeckInstalled(_ metadata: DeckMetadata) -> Bool {
        // Vérifier si un deck avec le même nom existe déjà
        return dataService.decks.contains { $0.name == metadata.name }
    }

    func deleteDeck(_ metadata: DeckMetadata) {
        deckToDelete = metadata
        showDeleteConfirmation = true
    }

    func confirmDelete() {
        guard let metadata = deckToDelete else { return }

        // Trouver le deck correspondant dans les decks locaux
        if let deck = dataService.decks.first(where: { $0.name == metadata.name }) {
            dataService.deleteDeck(deck)
        }

        deckToDelete = nil
        showDeleteConfirmation = false
    }
}

#Preview {
    DeckMarketplaceView()
}
