//
//  DrawingCanvasView.swift
//  LearnTheCharacters
//
//  Created by Claude on 03/01/2026.
//

import SwiftUI

/// Canvas de dessin pour la pratique de l'écriture
struct DrawingCanvasView: View {
    let character: Character

    @Binding var currentPath: [CGPoint]
    @Binding var completedPaths: [[CGPoint]]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Caractère guide en filigrane - utilise les strokes SVG si disponibles
                if let strokeOrder = character.strokeOrder {
                    // Afficher tous les traits SVG comme guide (même fonte que l'animation)
                    ForEach(Array(strokeOrder.strokes.enumerated()), id: \.offset) { index, stroke in
                        StrokePathShape(svgPath: stroke, viewBox: strokeOrder.viewBox.size)
                            .fill(Color.gray.opacity(0.08))
                    }
                } else {
                    // Fallback sur Text() si pas de strokeOrder
                    Text(character.simplified)
                        .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.7))
                        .foregroundColor(.gray.opacity(0.12))
                }

                // Canvas de dessin
                Canvas { context, size in
                    // Dessiner les traits complétés
                    for path in completedPaths {
                        if !path.isEmpty {
                            var swiftUIPath = Path()
                            swiftUIPath.move(to: path[0])
                            for point in path.dropFirst() {
                                swiftUIPath.addLine(to: point)
                            }
                            context.stroke(
                                swiftUIPath,
                                with: .color(.black),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                            )
                        }
                    }

                    // Dessiner le trait actuel
                    if !currentPath.isEmpty {
                        var swiftUIPath = Path()
                        swiftUIPath.move(to: currentPath[0])
                        for point in currentPath.dropFirst() {
                            swiftUIPath.addLine(to: point)
                        }
                        context.stroke(
                            swiftUIPath,
                            with: .color(.blue),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentPath.append(value.location)
                        }
                        .onEnded { _ in
                            if !currentPath.isEmpty {
                                completedPaths.append(currentPath)
                                currentPath = []
                            }
                        }
                )
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
        )
    }
}

#Preview {
    @Previewable @State var currentPath: [CGPoint] = []
    @Previewable @State var completedPaths: [[CGPoint]] = []

    if let character = Character.sampleCharacters.first {
        DrawingCanvasView(
            character: character,
            currentPath: $currentPath,
            completedPaths: $completedPaths
        )
        .frame(width: 300, height: 300)
        .padding()
    }
}
