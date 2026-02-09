//
//  StrokeAnimationView.swift
//  LearnTheCharacters
//
//  Created by Claude on 03/01/2026.
//

import SwiftUI

/// Shape pour dessiner une ligne médiane (utilisée pour l'animation du tracé)
struct MedianStrokePath: Shape {
    let points: [CGPoint]
    let viewBox: StrokeOrderData.ViewBox
    let size: CGSize

    func path(in rect: CGRect) -> Path {
        guard !points.isEmpty else { return Path() }

        var path = Path()

        // Facteurs d'échelle
        let scaleX = rect.width / viewBox.width
        let scaleY = rect.height / viewBox.height

        // Convertir tous les points avec mise à l'échelle
        let scaledPoints = points.map { point in
            CGPoint(
                x: rect.minX + point.x * scaleX,
                y: rect.maxY - point.y * scaleY  // Inversion Y
            )
        }

        guard scaledPoints.count > 0 else { return Path() }

        // Premier point
        path.move(to: scaledPoints[0])

        if scaledPoints.count == 2 {
            // Si seulement 2 points, ligne droite
            path.addLine(to: scaledPoints[1])
        } else if scaledPoints.count > 2 {
            // Utiliser des courbes quadratiques pour adoucir le tracé
            for i in 1..<scaledPoints.count {
                let currentPoint = scaledPoints[i]
                let previousPoint = scaledPoints[i - 1]

                if i < scaledPoints.count - 1 {
                    // Point de contrôle = point actuel
                    // Point de fin = milieu entre point actuel et suivant
                    let nextPoint = scaledPoints[i + 1]
                    let midPoint = CGPoint(
                        x: (currentPoint.x + nextPoint.x) / 2,
                        y: (currentPoint.y + nextPoint.y) / 2
                    )
                    path.addQuadCurve(to: midPoint, control: currentPoint)
                } else {
                    // Dernier point : ligne droite
                    path.addLine(to: currentPoint)
                }
            }
        }

        return path
    }
}

/// Vue d'animation des traits pour démonstration de l'ordre d'écriture
struct StrokeAnimationView: View {
    let strokeOrder: StrokeOrderData
    let character: Character

    @State private var currentStroke: Int = -1  // -1 = pas commencé
    @State private var animationProgress: CGFloat = 0.0
    @State private var isAnimating: Bool = false
    @State private var showStrokeNumbers: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fond : tous les traits en gris clair (guide)
                ForEach(Array(strokeOrder.strokes.enumerated()), id: \.offset) { index, stroke in
                    StrokePathShape(svgPath: stroke, viewBox: strokeOrder.viewBox.size)
                        .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                }

                // Traits déjà tracés (en gris foncé) - utilise aussi les medians
                ForEach(0..<max(0, currentStroke), id: \.self) { index in
                    if let medians = strokeOrder.medians, index < medians.count {
                        MedianStrokePath(points: medians[index], viewBox: strokeOrder.viewBox, size: geometry.size)
                            .stroke(Color.gray.opacity(0.6), style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    } else {
                        StrokePathShape(svgPath: strokeOrder.strokes[index], viewBox: strokeOrder.viewBox.size)
                            .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    }
                }

                // Trait en cours d'animation (en vert) - utilise les medians pour un tracé au pinceau
                if currentStroke >= 0 && currentStroke < strokeOrder.strokes.count {
                    if let medians = strokeOrder.medians,
                       currentStroke < medians.count {
                        // Utiliser la ligne médiane pour l'animation (tracé au pinceau)
                        MedianStrokePath(points: medians[currentStroke], viewBox: strokeOrder.viewBox, size: geometry.size)
                            .trim(from: 0, to: animationProgress)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    } else {
                        // Fallback si pas de medians
                        StrokePathShape(svgPath: strokeOrder.strokes[currentStroke], viewBox: strokeOrder.viewBox.size)
                            .trim(from: 0, to: animationProgress)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    }
                }

                // Numéros de traits (optionnel)
                if showStrokeNumbers {
                    ForEach(Array(strokeOrder.strokes.enumerated()), id: \.offset) { index, _ in
                        if let startPoint = getStrokeStartPoint(index: index, in: geometry.size) {
                            Text("\(index + 1)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.red)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.8))
                                        .frame(width: 24, height: 24)
                                )
                                .position(startPoint)
                        }
                    }
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .onAppear {
            // Démarrer l'animation automatiquement au chargement
            playAnimation()
        }
    }

    /// Démarrer l'animation séquentielle
    func playAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        currentStroke = 0
        animationProgress = 0.0
        animateNextStroke()
    }

    /// Réinitialiser l'animation
    func resetAnimation() {
        isAnimating = false
        currentStroke = -1
        animationProgress = 0.0
    }

    /// Animer le trait suivant
    private func animateNextStroke() {
        guard currentStroke < strokeOrder.strokes.count else {
            // Animation terminée
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = false
            }
            return
        }

        // Animer le trait actuel de 0 à 1
        withAnimation(.easeInOut(duration: 0.8)) {
            animationProgress = 1.0
        }

        // Passer au trait suivant après l'animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            currentStroke += 1
            animationProgress = 0.0
            animateNextStroke()
        }
    }

    /// Obtenir le point de départ d'un trait pour afficher le numéro
    private func getStrokeStartPoint(index: Int, in size: CGSize) -> CGPoint? {
        guard index < strokeOrder.medians?.count ?? 0,
              let median = strokeOrder.medians?[index],
              let firstPoint = median.first else {
            return nil
        }

        // Convertir du viewBox au rect avec inversion de l'axe Y
        let scaleX = size.width / strokeOrder.viewBox.width
        let scaleY = size.height / strokeOrder.viewBox.height

        return CGPoint(
            x: firstPoint.x * scaleX,
            y: size.height - firstPoint.y * scaleY  // Inversion de l'axe Y
        )
    }
}

#Preview {
    // Exemple fictif pour preview
    if let character = Character.sampleCharacters.first {
        // Créer un exemple de stroke order pour preview
        let sampleStrokeOrder = StrokeOrderData(
            strokes: ["M 100 100 L 200 200", "M 200 100 L 100 200"],
            medians: [[CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)], [CGPoint(x: 200, y: 100), CGPoint(x: 100, y: 200)]],
            source: "makemeahanzi"
        )

        // Créer un caractère avec strokeOrder pour preview
        let charWithStroke = Character(
            simplified: character.simplified,
            pinyin: character.pinyin,
            meaning: character.meaning,
            strokeOrder: sampleStrokeOrder
        )

        StrokeAnimationView(
            strokeOrder: sampleStrokeOrder,
            character: charWithStroke
        )
        .frame(width: 300, height: 300)
        .padding()
    } else {
        Text("Pas de données de stroke order")
    }
}
