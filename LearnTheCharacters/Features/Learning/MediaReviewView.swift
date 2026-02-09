//
//  MediaReviewView.swift
//  LearnTheCharacters
//
//  Created by Claude on 09/02/2026.
//

import SwiftUI
import AVKit

/// Vue principale pour le mode Révision Média (audio/vidéo)
struct MediaReviewView: View {
    @StateObject private var viewModel: MediaReviewViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showFullscreen = false

    init(deck: Deck) {
        _viewModel = StateObject(wrappedValue: MediaReviewViewModel(deck: deck))
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.indigo.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal)
                    .padding(.top, 10)

                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
                    contentView
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(viewModel.deckName)
                .font(.headline)
                .lineLimit(1)

            Spacer()

            // Mode indicator
            Text(viewModel.mediaType == .audio ? "🎧" : "🎬")
                .font(.title2)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Chargement du média...")
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Réessayer") {
                // Force reload
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .padding()
    }

    // MARK: - Content View

    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)

            // Player View
            playerView
                .padding(.horizontal, 20)

            Spacer()
                .frame(height: 30)

            // Progress bar
            progressBarView
                .padding(.horizontal, 30)

            // Time labels
            timeLabelsView
                .padding(.horizontal, 30)
                .padding(.top, 8)

            Spacer()
                .frame(height: 30)

            // Playback controls
            playbackControlsView

            Spacer()
                .frame(height: 20)

            // Media type toggle
            mediaToggleView
                .padding(.horizontal, 30)

            Spacer()
                .frame(minHeight: 20, maxHeight: 40)
        }
    }

    // MARK: - Player View

    @ViewBuilder
    private var playerView: some View {
        if viewModel.mediaType == .video, let player = viewModel.currentPlayer {
            ZStack(alignment: .topTrailing) {
                VideoPlayerView(player: player, showControls: false)
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .onTapGesture {
                        showFullscreen = true
                    }

                // Fullscreen button
                Button(action: { showFullscreen = true }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(12)
            }
            .fullScreenCover(isPresented: $showFullscreen) {
                FullscreenVideoView(player: player, isPresented: $showFullscreen)
            }
        } else {
            AudioPlayerView(
                deckName: viewModel.deckName,
                isPlaying: viewModel.isPlaying,
                currentTime: viewModel.currentTime,
                duration: viewModel.duration
            )
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }

    // MARK: - Progress Bar

    private var progressBarView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)

                // Progress track
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * viewModel.progressPercentage, height: 8)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let percentage = min(max(value.location.x / geometry.size.width, 0), 1)
                        viewModel.seek(to: viewModel.duration * percentage)
                    }
            )
        }
        .frame(height: 8)
    }

    // MARK: - Time Labels

    private var timeLabelsView: some View {
        HStack {
            Text(viewModel.formattedCurrentTime)
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()

            Spacer()

            Text(viewModel.formattedDuration)
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
    }

    // MARK: - Playback Controls

    private var playbackControlsView: some View {
        HStack(spacing: 40) {
            // Skip backward
            Button(action: { viewModel.skipBackward() }) {
                Image(systemName: "gobackward.15")
                    .font(.title)
                    .foregroundColor(.primary)
            }

            // Play/Pause
            Button(action: { viewModel.togglePlayPause() }) {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.purple)
            }

            // Skip forward
            Button(action: { viewModel.skipForward() }) {
                Image(systemName: "goforward.15")
                    .font(.title)
                    .foregroundColor(.primary)
            }
        }
    }

    // MARK: - Media Toggle

    private var mediaToggleView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Audio button
                Button(action: { viewModel.switchToAudio() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "headphones")
                        Text("Audio")
                    }
                    .font(.callout)
                    .foregroundColor(viewModel.mediaType == .audio ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.mediaType == .audio ? Color.purple : Color.gray.opacity(0.2))
                    )
                }
                .disabled(!viewModel.isAudioAvailable)
                .opacity(viewModel.isAudioAvailable ? 1 : 0.5)

                // Video button
                Button(action: { viewModel.switchToVideo() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "video")
                        Text("Vidéo")
                        if !viewModel.isVideoDownloaded && viewModel.isVideoAvailable {
                            Image(systemName: "icloud.and.arrow.down")
                                .font(.caption)
                        }
                    }
                    .font(.callout)
                    .foregroundColor(viewModel.mediaType == .video ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.mediaType == .video ? Color.blue : Color.gray.opacity(0.2))
                    )
                }
                .disabled(!viewModel.isVideoAvailable)
                .opacity(viewModel.isVideoAvailable ? 1 : 0.5)
            }

            // Download video button (if not downloaded)
            if viewModel.isVideoAvailable && !viewModel.isVideoDownloaded && viewModel.mediaType == .video {
                Button(action: {
                    Task {
                        await viewModel.downloadVideo()
                    }
                }) {
                    HStack {
                        if viewModel.isDownloadingVideo {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Téléchargement...")
                        } else {
                            Image(systemName: "arrow.down.circle")
                            Text("Télécharger pour hors ligne")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .disabled(viewModel.isDownloadingVideo)
                .padding(.top, 8)
            }
        }
    }
}

/// Vue plein écran pour la vidéo avec contrôles natifs
struct FullscreenVideoView: View {
    let player: AVPlayer
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VideoPlayer(player: player)
                .ignoresSafeArea()

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .statusBarHidden()
    }
}

#Preview {
    MediaReviewView(deck: Deck.sample)
}
