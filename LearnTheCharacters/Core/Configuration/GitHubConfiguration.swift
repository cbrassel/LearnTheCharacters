//
//  GitHubConfiguration.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation

/// Configuration pour l'accès au repository GitHub de decks
struct GitHubConfiguration {

    // MARK: - Repository Info

    static let username = "cbrassel"
    static let repositoryName = "LearnTheCharacters"

    // MARK: - Authentication

    /// Token d'accès GitHub pour l'API
    /// IMPORTANT: En production, ce token devrait être stocké dans le Keychain
    /// ou obfusqué pour plus de sécurité
    private static let accessToken = "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"

    // MARK: - URLs

    /// URL de base du repository
    static var repositoryURL: String {
        "https://github.com/\(username)/\(repositoryName)"
    }

    /// URL de base pour accéder aux fichiers raw
    static var rawContentBaseURL: String {
        "https://raw.githubusercontent.com/\(username)/\(repositoryName)/main"
    }

    /// URL de l'API GitHub pour accéder aux contenus
    static var apiContentsURL: String {
        "https://api.github.com/repos/\(username)/\(repositoryName)/contents"
    }

    // MARK: - Paths

    /// Chemin vers le dossier des decks HSK1
    static let hsk1Path = "decks/hsk1"

    /// Chemin vers le dossier des decks thématiques
    static let thematicPath = "decks/thematic"

    /// Chemin vers le dossier des decks communautaires
    static let communityPath = "decks/community"

    // MARK: - HTTP Headers

    /// Headers HTTP pour les requêtes authentifiées
    static var authenticatedHeaders: [String: String] {
        [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/vnd.github.v3+json",
            "X-GitHub-Api-Version": "2022-11-28"
        ]
    }

    /// Headers HTTP pour les requêtes publiques (sans authentification)
    static var publicHeaders: [String: String] {
        [
            "Accept": "application/vnd.github.v3+json",
            "X-GitHub-Api-Version": "2022-11-28"
        ]
    }

    // MARK: - Helper Methods

    /// Construit l'URL complète pour un deck spécifique
    static func deckURL(category: String, filename: String) -> String {
        "\(rawContentBaseURL)/decks/\(category)/\(filename)"
    }

    /// Construit l'URL de l'API pour lister les decks d'une catégorie
    static func apiURL(forCategory category: String) -> String {
        "\(apiContentsURL)/decks/\(category)"
    }

    /// Crée une URLRequest authentifiée
    static func authenticatedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        for (key, value) in authenticatedHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }

    /// Crée une URLRequest publique (sans authentification)
    static func publicRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        for (key, value) in publicHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

// MARK: - Security Note

/*
 ⚠️ NOTE DE SÉCURITÉ ⚠️

 En production, le token GitHub ne devrait PAS être stocké en dur dans le code source.

 Meilleures pratiques recommandées:

 1. Keychain (Recommandé pour iOS)
    - Stocker le token dans le Keychain iOS
    - Chiffré automatiquement par le système
    - Accessible uniquement par l'app

 2. Variables d'environnement (Build time)
    - Injecter le token lors de la compilation
    - Utiliser xcconfig files
    - Ne jamais commiter le token dans Git

 3. Backend proxy (Le plus sécurisé)
    - L'app communique avec votre serveur
    - Le serveur gère l'authentification GitHub
    - Le token n'est jamais exposé côté client

 4. Obfuscation (Solution temporaire)
    - Encoder/chiffrer le token dans le code
    - Déchiffrer au runtime
    - Pas 100% sécurisé mais mieux que rien

 Pour ce MVP, le token est en dur pour simplifier le développement.
 À sécuriser avant toute publication sur l'App Store!
 */
