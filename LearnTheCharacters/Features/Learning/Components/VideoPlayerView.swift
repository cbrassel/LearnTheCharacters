//
//  VideoPlayerView.swift
//  LearnTheCharacters
//
//  Created by Claude on 09/02/2026.
//

import SwiftUI
import AVKit

/// Wrapper SwiftUI pour AVPlayerViewController avec contrôles personnalisés
struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    let showControls: Bool

    init(player: AVPlayer, showControls: Bool = true) {
        self.player = player
        self.showControls = showControls
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = showControls
        controller.videoGravity = .resizeAspect
        controller.allowsPictureInPicturePlayback = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}

/// Vue plein écran pour la vidéo
struct FullscreenVideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        controller.allowsPictureInPicturePlayback = true
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        let parent: FullscreenVideoPlayerView

        init(_ parent: FullscreenVideoPlayerView) {
            self.parent = parent
        }

        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
            coordinator.animate(alongsideTransition: nil) { _ in
                self.parent.isPresented = false
            }
        }
    }
}

/// Vue audio avec artwork et waveform simulé
struct AudioPlayerView: View {
    let deckName: String
    let isPlaying: Bool
    let currentTime: TimeInterval
    let duration: TimeInterval

    var body: some View {
        VStack(spacing: 20) {
            // Artwork placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 16) {
                    // Icône audio
                    Image(systemName: isPlaying ? "waveform" : "headphones")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .symbolEffect(.variableColor.iterative, options: .repeating, isActive: isPlaying)

                    // Nom du deck
                    Text(deckName)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Indicateur de lecture
                    if isPlaying {
                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { index in
                                AudioBar(index: index)
                            }
                        }
                        .frame(height: 30)
                    }
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
        }
    }
}

/// Barre d'animation audio
struct AudioBar: View {
    let index: Int
    @State private var height: CGFloat = 10

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.white.opacity(0.8))
            .frame(width: 6, height: height)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.3 + Double(index) * 0.1)
                    .repeatForever(autoreverses: true)
                ) {
                    height = CGFloat.random(in: 15...30)
                }
            }
    }
}

#Preview {
    VStack {
        AudioPlayerView(
            deckName: "Cours 03 - 汉字",
            isPlaying: true,
            currentTime: 45,
            duration: 180
        )
        .padding()
    }
}
