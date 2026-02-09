//
//  MediaService.swift
//  LearnTheCharacters
//
//  Created by Claude on 09/02/2026.
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

/// Service de gestion des fichiers média (audio/vidéo) pour les decks
class MediaService: ObservableObject {
    static let shared = MediaService()

    private let fileManager = FileManager.default
    private let baseURL = "https://raw.githubusercontent.com/cbrassel/LearnTheCharacters/main/media"

    @Published var downloadProgress: Double = 0
    @Published var isDownloading = false
    @Published var currentDownloadDeckName: String?

    enum MediaType: String {
        case audio = "audio"
        case video = "video"

        var fileExtension: String {
            switch self {
            case .audio: return "mp3"
            case .video: return "mp4"
            }
        }

        var folderName: String {
            switch self {
            case .audio: return "Audio"
            case .video: return "Video"
            }
        }
    }

    enum MediaError: LocalizedError {
        case invalidURL
        case downloadFailed
        case fileNotFound
        case networkError(statusCode: Int)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "URL invalide"
            case .downloadFailed:
                return "Échec du téléchargement"
            case .fileNotFound:
                return "Fichier non trouvé"
            case .networkError(let statusCode):
                return "Erreur réseau (code \(statusCode))"
            }
        }
    }

    private init() {
        createMediaDirectories()
    }

    // MARK: - Directory Setup

    private func createMediaDirectories() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDir = documentsURL.appendingPathComponent("Media/Audio")
        let videoDir = documentsURL.appendingPathComponent("Media/Video")

        do {
            try fileManager.createDirectory(at: audioDir, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: videoDir, withIntermediateDirectories: true)
        } catch {
            print("❌ Erreur création dossiers média: \(error)")
        }
    }

    // MARK: - URL Generation

    /// Génère le nom de fichier sanitizé pour un deck
    func sanitizedFileName(for deckName: String) -> String {
        // Remplacer les espaces par des %20 pour l'URL
        // Le nom réel des fichiers sur GitHub contient des espaces
        return deckName
    }

    /// URL distante pour l'audio d'un deck
    func getRemoteAudioURL(for deckName: String) -> URL? {
        let fileName = sanitizedFileName(for: deckName)
        let encodedFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
        return URL(string: "\(baseURL)/audio/\(encodedFileName).mp3")
    }

    /// URL distante pour la vidéo d'un deck
    func getRemoteVideoURL(for deckName: String) -> URL? {
        let fileName = sanitizedFileName(for: deckName)
        let encodedFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
        return URL(string: "\(baseURL)/video/\(encodedFileName).mp4")
    }

    /// URL locale pour le cache d'un média
    private func getLocalURL(for deckName: String, type: MediaType) -> URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // Sanitize le nom pour le système de fichiers local
        let safeFileName = deckName
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        return documentsURL
            .appendingPathComponent("Media/\(type.folderName)/\(safeFileName).\(type.fileExtension)")
    }

    // MARK: - Audio Management

    /// Retourne l'URL de l'audio (local si téléchargé, sinon nil)
    func getAudioURL(for deckName: String) -> URL? {
        let localURL = getLocalURL(for: deckName, type: .audio)
        if fileManager.fileExists(atPath: localURL.path) {
            return localURL
        }
        return nil
    }

    /// Vérifie si l'audio est téléchargé localement
    func isAudioDownloaded(for deckName: String) -> Bool {
        let localURL = getLocalURL(for: deckName, type: .audio)
        return fileManager.fileExists(atPath: localURL.path)
    }

    /// Télécharge l'audio d'un deck
    @discardableResult
    func downloadAudio(for deckName: String) async throws -> URL {
        return try await downloadMedia(for: deckName, type: .audio)
    }

    // MARK: - Video Management

    /// Retourne l'URL de la vidéo (local si téléchargé, sinon distant pour streaming)
    func getVideoURL(for deckName: String) -> URL? {
        // 1. Si téléchargée localement, utiliser le cache
        let localURL = getLocalURL(for: deckName, type: .video)
        if fileManager.fileExists(atPath: localURL.path) {
            return localURL
        }
        // 2. Sinon streaming depuis GitHub
        return getRemoteVideoURL(for: deckName)
    }

    /// Vérifie si la vidéo est téléchargée localement
    func isVideoDownloaded(for deckName: String) -> Bool {
        let localURL = getLocalURL(for: deckName, type: .video)
        return fileManager.fileExists(atPath: localURL.path)
    }

    /// Télécharge la vidéo d'un deck
    @discardableResult
    func downloadVideo(for deckName: String) async throws -> URL {
        return try await downloadMedia(for: deckName, type: .video)
    }

    // MARK: - Download

    /// Télécharge un média (audio ou vidéo)
    private func downloadMedia(for deckName: String, type: MediaType) async throws -> URL {
        let remoteURL: URL?
        switch type {
        case .audio:
            remoteURL = getRemoteAudioURL(for: deckName)
        case .video:
            remoteURL = getRemoteVideoURL(for: deckName)
        }

        guard let remote = remoteURL else {
            throw MediaError.invalidURL
        }

        let localURL = getLocalURL(for: deckName, type: type)

        // Mettre à jour l'état
        await MainActor.run {
            self.isDownloading = true
            self.currentDownloadDeckName = deckName
            self.downloadProgress = 0
        }

        defer {
            Task { @MainActor in
                self.isDownloading = false
                self.currentDownloadDeckName = nil
            }
        }

        print("📥 Téléchargement \(type.rawValue): \(remote)")

        // Utiliser URLSession avec délégué pour le suivi de progression
        let (tempURL, response) = try await URLSession.shared.download(from: remote)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MediaError.downloadFailed
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Erreur HTTP \(httpResponse.statusCode) pour \(remote)")
            throw MediaError.networkError(statusCode: httpResponse.statusCode)
        }

        // Supprimer l'ancien fichier si existant
        if fileManager.fileExists(atPath: localURL.path) {
            try fileManager.removeItem(at: localURL)
        }

        // Déplacer vers l'emplacement final
        try fileManager.moveItem(at: tempURL, to: localURL)

        await MainActor.run {
            self.downloadProgress = 1.0
        }

        print("✅ \(type.rawValue) téléchargé: \(localURL.lastPathComponent)")
        return localURL
    }

    /// Vérifie si un média distant existe (HEAD request)
    func checkRemoteMediaExists(for deckName: String, type: MediaType) async -> Bool {
        let remoteURL: URL?
        switch type {
        case .audio:
            remoteURL = getRemoteAudioURL(for: deckName)
        case .video:
            remoteURL = getRemoteVideoURL(for: deckName)
        }

        guard let url = remoteURL else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return (200...299).contains(httpResponse.statusCode)
            }
        } catch {
            print("⚠️ Erreur vérification média distant: \(error)")
        }

        return false
    }

    // MARK: - Cache Management

    /// Supprime un média du cache
    func deleteMedia(for deckName: String, type: MediaType) throws {
        let localURL = getLocalURL(for: deckName, type: type)
        if fileManager.fileExists(atPath: localURL.path) {
            try fileManager.removeItem(at: localURL)
            print("🗑️ \(type.rawValue) supprimé: \(deckName)")
        }
    }

    /// Supprime tous les médias d'un deck
    func deleteAllMedia(for deckName: String) throws {
        try deleteMedia(for: deckName, type: .audio)
        try deleteMedia(for: deckName, type: .video)
    }

    /// Calcule la taille totale du cache média
    func totalCacheSize() -> Int64 {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mediaURL = documentsURL.appendingPathComponent("Media")
        return folderSize(at: mediaURL)
    }

    /// Taille formatée du cache
    func formattedCacheSize() -> String {
        let size = totalCacheSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    /// Vide tout le cache média
    func clearAllCache() throws {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let mediaURL = documentsURL.appendingPathComponent("Media")

        if fileManager.fileExists(atPath: mediaURL.path) {
            try fileManager.removeItem(at: mediaURL)
            createMediaDirectories()
            print("🗑️ Cache média vidé")
        }
    }

    private func folderSize(at url: URL) -> Int64 {
        guard fileManager.fileExists(atPath: url.path) else { return 0 }

        var totalSize: Int64 = 0

        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            while let fileURL = enumerator.nextObject() as? URL {
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                    if let size = attributes[.size] as? Int64 {
                        totalSize += size
                    }
                } catch {
                    continue
                }
            }
        }

        return totalSize
    }

    // MARK: - Audio Session Configuration

    /// Configure l'audio session pour la lecture en arrière-plan
    func configureBackgroundAudio() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.allowAirPlay, .allowBluetoothA2DP]
            )
            try audioSession.setActive(true)
            print("🔊 Audio session configurée pour lecture en arrière-plan")
        } catch {
            print("❌ Erreur configuration audio session: \(error)")
        }
    }

    /// Configure les contrôles du lock screen
    func setupRemoteCommandCenter(
        playAction: @escaping () -> Void,
        pauseAction: @escaping () -> Void,
        skipForwardAction: @escaping () -> Void,
        skipBackwardAction: @escaping () -> Void
    ) {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ in
            playAction()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { _ in
            pauseAction()
            return .success
        }

        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { _ in
            skipForwardAction()
            return .success
        }

        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { _ in
            skipBackwardAction()
            return .success
        }
    }

    /// Met à jour les informations Now Playing
    func updateNowPlayingInfo(
        title: String,
        artist: String = "LearnTheCharacters",
        currentTime: TimeInterval,
        duration: TimeInterval,
        isPlaying: Bool
    ) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
