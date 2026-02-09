//
//  CharacterCardView.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import SwiftUI

struct CharacterCardView: View {
    let character: Character
    let showAnswer: Bool

    @State private var isFlipped: Bool

    init(character: Character, showAnswer: Bool) {
        self.character = character
        self.showAnswer = showAnswer
        _isFlipped = State(initialValue: showAnswer)
    }

    var body: some View {
        ZStack {
            // Recto - Caractère chinois
            CardFace(isVisible: !isFlipped) {
                VStack(spacing: 10) {
                    Text(character.simplified)
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.primary)

                    if character.traditional != nil && character.traditional != character.simplified {
                        Text(character.traditional!)
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Verso - Réponse
            CardFace(isVisible: isFlipped) {
                VStack(spacing: 10) {
                    Text(character.simplified)
                        .font(.system(size: 80, weight: .bold))

                    Text(character.pinyin)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.blue)

                    Text(character.displayMeaning)
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    if !character.examples.isEmpty {
                        Divider()
                            .padding(.vertical, 3)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Exemples:")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            ForEach(character.examples.prefix(2), id: \.self) { example in
                                Text(example)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(nil) // ✨ Permettre plusieurs lignes
                                    .multilineTextAlignment(.leading) // ✨ Alignement à gauche
                                    .fixedSize(horizontal: false, vertical: true) // ✨ Expansion verticale
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
        }
        .onChange(of: showAnswer) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped = newValue
            }
        }
    }
}

struct CardFace<Content: View>: View {
    let isVisible: Bool
    let content: Content

    init(isVisible: Bool, @ViewBuilder content: () -> Content) {
        self.isVisible = isVisible
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)

            content
                .padding(20)
        }
        .rotation3DEffect(
            .degrees(isVisible ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .opacity(isVisible ? 1 : 0)
    }
}

#Preview {
    VStack(spacing: 40) {
        CharacterCardView(
            character: Character.sampleCharacters[0],
            showAnswer: false
        )
        .frame(height: 400)
        .padding()

        CharacterCardView(
            character: Character.sampleCharacters[0],
            showAnswer: true
        )
        .frame(height: 400)
        .padding()
    }
}
