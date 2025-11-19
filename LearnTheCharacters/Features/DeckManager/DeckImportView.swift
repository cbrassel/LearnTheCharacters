//
//  DeckImportView.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

struct DeckImportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DeckImportViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Importer un Deck")
                            .font(.title.bold())

                        Text("Ajoutez des decks depuis GitHub ou vos fichiers locaux")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    // Import depuis URL
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Depuis URL GitHub", systemImage: "link")
                            .font(.headline)

                        HStack {
                            TextField("https://raw.githubusercontent.com/...", text: $viewModel.urlString)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .keyboardType(.URL)

                            Button(action: {
                                viewModel.importFromURL()
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.title2)
                                }
                            }
                            .disabled(viewModel.urlString.isEmpty || viewModel.isLoading)
                        }

                        // Liens rapides
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Liens rapides:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ForEach(viewModel.quickLinks, id: \.self) { link in
                                Button(action: {
                                    viewModel.urlString = link
                                    viewModel.importFromURL()
                                }) {
                                    HStack {
                                        Image(systemName: "link.circle.fill")
                                            .foregroundColor(.blue)
                                        Text(link.components(separatedBy: "/").last?.replacingOccurrences(of: ".json", with: "") ?? link)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 5)
                    )
                    .padding(.horizontal)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                        Text("OU")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal)

                    // Import depuis fichier
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Depuis fichier local", systemImage: "doc.fill")
                            .font(.headline)

                        Button(action: {
                            viewModel.showFilePicker = true
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                Text("Choisir un fichier JSON")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 5)
                    )
                    .padding(.horizontal)

                    // Deck importé avec succès
                    if let deck = viewModel.importedDeck {
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                Text("Deck importé avec succès!")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Nom:")
                                        .foregroundColor(.secondary)
                                    Text(deck.name)
                                        .bold()
                                }

                                HStack {
                                    Text("Caractères:")
                                        .foregroundColor(.secondary)
                                    Text("\(deck.characterIDs.count)")
                                        .bold()
                                }

                                HStack {
                                    Text("Catégorie:")
                                        .foregroundColor(.secondary)
                                    Text(deck.category.rawValue)
                                        .bold()
                                }

                                Text(deck.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 5)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)

                            Button(action: {
                                dismiss()
                            }) {
                                Text("Terminé")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .fileImporter(
                isPresented: $viewModel.showFilePicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                viewModel.handleFileImport(result)
            }
        }
    }
}

// MARK: - ViewModel

class DeckImportViewModel: ObservableObject {
    @Published var urlString = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showFilePicker = false
    @Published var importedDeck: Deck?

    private let importService = DeckImportExportService.shared

    // Liens rapides vers des decks populaires
    var quickLinks: [String] {
        [
            GitHubConfiguration.deckURL(category: "hsk1", filename: "basic-verbs.json"),
            GitHubConfiguration.deckURL(category: "thematic", filename: "restaurant.json")
        ]
    }

    func importFromURL() {
        guard !urlString.isEmpty else { return }

        isLoading = true

        Task {
            do {
                let deck = try await importService.importDeckFromURL(urlString)
                await MainActor.run {
                    self.importedDeck = deck
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Impossible d'importer le deck: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }

    func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            // Activer l'accès au fichier sécurisé
            guard url.startAccessingSecurityScopedResource() else {
                self.errorMessage = "Impossible d'accéder au fichier"
                self.showError = true
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let deck = try importService.importAndSaveDeck(from: Data(contentsOf: url))
                self.importedDeck = deck
            } catch {
                self.errorMessage = "Fichier invalide: \(error.localizedDescription)"
                self.showError = true
            }

        case .failure(let error):
            self.errorMessage = "Erreur: \(error.localizedDescription)"
            self.showError = true
        }
    }
}

#Preview {
    DeckImportView()
}
