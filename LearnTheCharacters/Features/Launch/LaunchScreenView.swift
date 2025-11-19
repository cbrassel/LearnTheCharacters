//
//  LaunchScreenView.swift
//  LearnTheCharacters
//
//  Created by Claude on 19/11/2025.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var currentCharacterIndex = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var isAnimationComplete = false

    // Séquence de caractères pour l'animation
    let characters = ["学", "习", "汉", "字"]
    let characterMeanings = ["apprendre", "étudier", "chinois", "caractère"]

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background gradient identique à l'icône
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.9),
                    Color(red: 0.6, green: 0.3, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Caractère principal animé
                Text(characters[currentCharacterIndex])
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .scaleEffect(scale)

                // Traduction en dessous
                Text(characterMeanings[currentCharacterIndex])
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Animation pour chaque caractère
        animateCharacter()
    }

    private func animateCharacter() {
        // Fade in + scale up
        withAnimation(.easeOut(duration: 0.4)) {
            opacity = 1.0
            scale = 1.0
        }

        // Pause pour que l'utilisateur voie le caractère
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            // Fade out
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 0.0
                scale = 1.2
            }

            // Passer au caractère suivant
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if currentCharacterIndex < characters.count - 1 {
                    currentCharacterIndex += 1
                    scale = 0.5
                    animateCharacter()
                } else {
                    // Animation terminée, afficher l'app
                    completeAnimation()
                }
            }
        }
    }

    private func completeAnimation() {
        isAnimationComplete = true

        // Petit délai avant de passer à l'app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
        }
    }
}

#Preview {
    LaunchScreenView {
        print("Animation terminée")
    }
}
