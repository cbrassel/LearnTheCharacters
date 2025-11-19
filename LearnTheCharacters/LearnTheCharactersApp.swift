//
//  LearnTheCharactersApp.swift
//  LearnTheCharacters
//
//  Created by Claude Brassel on 17/11/2025.
//

import SwiftUI

@main
struct LearnTheCharactersApp: App {
    @StateObject private var dataService = DataPersistenceService.shared
    @State private var showLaunchScreen = true

    init() {
        // Configuration initiale
        setupApp()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // App principale
                HomeView()
                    .environmentObject(dataService)
                    .onAppear {
                        requestPermissions()
                    }
                    .opacity(showLaunchScreen ? 0 : 1)

                // Launch screen par-dessus
                if showLaunchScreen {
                    LaunchScreenView {
                        // Appelé quand l'animation est terminée
                        withAnimation(.easeOut(duration: 0.5)) {
                            showLaunchScreen = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }

    private func setupApp() {
        // Charger les caractères par défaut si nécessaire
        if DataPersistenceService.shared.characters.isEmpty {
            DataPersistenceService.shared.characters = Character.defaultCharacters
            DataPersistenceService.shared.saveCharacters()
        }
    }

    private func requestPermissions() {
        // Demander l'autorisation pour la reconnaissance vocale
        SpeechRecognitionService.shared.requestAuthorization { granted in
            if granted {
                print("✅ Autorisation reconnaissance vocale accordée")
            } else {
                print("⚠️ Autorisation reconnaissance vocale refusée")
            }
        }
    }
}
