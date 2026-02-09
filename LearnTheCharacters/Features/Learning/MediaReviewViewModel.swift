//
//  MediaReviewViewModel.swift
//  LearnTheCharacters
//
//  Created by Claude on 09/02/2026.
//

import Foundation
import AVFoundation
import Combine

/// ViewModel pour le mode Révision Média
class MediaReviewViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var mediaType: MediaType = .audio
    @Published var isLoading = true
    @Published var error: String?
    @Published var isAudioAvailable = false
    @Published var isVideoAvailable = false
    @Published var isVideoDownloaded = false
    @Published var isDownloadingVideo = false

    enum MediaType {
        case audio
        case video
    }

    // MARK: - Properties

    let deck: Deck
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private let mediaService = MediaService.shared

    // MARK: - Computed Properties

    var deckName: String {
        deck.name
    }

    var currentPlayer: AVPlayer? {
        player
    }

    var progressPercentage: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    var formattedDuration: String {
        formatTime(duration)
    }

    // MARK: - Initialization

    init(deck: Deck) {
        self.deck = deck
        Task {
            await checkMediaAvailability()
            await setupPlayer()
        }
    }

    deinit {
        cleanup()
    }

    // MARK: - Media Availability

    @MainActor
    private func checkMediaAvailability() async {
        // Vérifier si l'audio est disponible localement
        var audioDownloaded = mediaService.isAudioDownloaded(for: deck.name)

        // Si l'audio n'est pas téléchargé, vérifier s'il existe sur le serveur et le télécharger
        if !audioDownloaded {
            let audioExists = await mediaService.checkRemoteMediaExists(for: deck.name, type: .audio)
            if audioExists {
                print("📥 Téléchargement automatique de l'audio pour '\(deck.name)'...")
                do {
                    _ = try await mediaService.downloadAudio(for: deck.name)
                    audioDownloaded = true
                    print("✅ Audio téléchargé pour '\(deck.name)'")
                } catch {
                    print("❌ Erreur téléchargement audio: \(error)")
                }
            }
        }

        isAudioAvailable = audioDownloaded

        // Vérifier si la vidéo est disponible (locale ou distante)
        isVideoDownloaded = mediaService.isVideoDownloaded(for: deck.name)

        // La vidéo est toujours "disponible" car on peut streamer
        // Mais on vérifie si elle existe vraiment sur le serveur
        let videoExists = await mediaService.checkRemoteMediaExists(for: deck.name, type: .video)
        isVideoAvailable = isVideoDownloaded || videoExists

        // Déterminer le type de média par défaut
        if isAudioAvailable {
            mediaType = .audio
        } else if isVideoAvailable {
            mediaType = .video
        }

        print("📊 Média disponible pour '\(deck.name)': audio=\(isAudioAvailable), video=\(isVideoAvailable)")
    }

    // MARK: - Player Setup

    @MainActor
    private func setupPlayer() async {
        isLoading = true
        error = nil

        let url: URL?

        switch mediaType {
        case .audio:
            url = mediaService.getAudioURL(for: deck.name)
        case .video:
            url = mediaService.getVideoURL(for: deck.name)
        }

        guard let mediaURL = url else {
            isLoading = false
            error = "Média non disponible"
            return
        }

        // Configurer la session audio pour la lecture en arrière-plan
        mediaService.configureBackgroundAudio()

        // Créer le player
        let playerItem = AVPlayerItem(url: mediaURL)
        player = AVPlayer(playerItem: playerItem)

        // Observer la durée
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .readyToPlay {
                    self?.duration = playerItem.duration.seconds
                    self?.isLoading = false
                } else if status == .failed {
                    self?.error = "Erreur de chargement du média"
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)

        // Observer le temps de lecture
        setupTimeObserver()

        // Observer la fin de lecture
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isPlaying = false
                self?.currentTime = 0
                self?.player?.seek(to: .zero)
            }
            .store(in: &cancellables)

        // Configurer les contrôles du lock screen
        setupRemoteCommands()
    }

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            self?.updateNowPlaying()
        }
    }

    private func setupRemoteCommands() {
        mediaService.setupRemoteCommandCenter(
            playAction: { [weak self] in self?.play() },
            pauseAction: { [weak self] in self?.pause() },
            skipForwardAction: { [weak self] in self?.skipForward() },
            skipBackwardAction: { [weak self] in self?.skipBackward() }
        )
    }

    private func updateNowPlaying() {
        mediaService.updateNowPlayingInfo(
            title: deck.name,
            currentTime: currentTime,
            duration: duration,
            isPlaying: isPlaying
        )
    }

    // MARK: - Playback Controls

    func play() {
        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying()
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
        currentTime = time
    }

    func skipForward(_ seconds: TimeInterval = 15) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }

    func skipBackward(_ seconds: TimeInterval = 15) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }

    // MARK: - Media Type Toggle

    func toggleMediaType() {
        guard isAudioAvailable || isVideoAvailable else { return }

        cleanup()

        if mediaType == .audio && isVideoAvailable {
            mediaType = .video
        } else if mediaType == .video && isAudioAvailable {
            mediaType = .audio
        }

        Task {
            await setupPlayer()
        }
    }

    func switchToAudio() {
        guard isAudioAvailable, mediaType != .audio else { return }
        cleanup()
        mediaType = .audio
        Task {
            await setupPlayer()
        }
    }

    func switchToVideo() {
        guard isVideoAvailable, mediaType != .video else { return }
        cleanup()
        mediaType = .video
        Task {
            await setupPlayer()
        }
    }

    // MARK: - Video Download

    func downloadVideo() async {
        guard !isVideoDownloaded else { return }

        await MainActor.run {
            isDownloadingVideo = true
        }

        do {
            _ = try await mediaService.downloadVideo(for: deck.name)
            await MainActor.run {
                isVideoDownloaded = true
                isDownloadingVideo = false
            }
        } catch {
            await MainActor.run {
                self.error = "Erreur téléchargement: \(error.localizedDescription)"
                isDownloadingVideo = false
            }
        }
    }

    // MARK: - Cleanup

    private func cleanup() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player = nil
        cancellables.removeAll()
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && time >= 0 else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
