//
//  SVGPathParser.swift
//  LearnTheCharacters
//
//  Created by Claude on 03/01/2026.
//

import SwiftUI

/// Parser pour convertir les chemins SVG de Make Me a Hanzi en SwiftUI Path
struct SVGPathParser {
    /// Parse une chaîne de chemin SVG en SwiftUI Path
    /// - Parameters:
    ///   - svgPath: Chaîne SVG (ex: "M 512 128 L 256 896")
    ///   - rect: Rectangle cible pour le rendu
    ///   - viewBox: Taille du système de coordonnées source (défaut: 1024x1024)
    /// - Returns: SwiftUI Path mis à l'échelle
    static func parse(_ svgPath: String, in rect: CGRect, viewBox: CGSize = CGSize(width: 1024, height: 1024)) -> Path {
        var path = Path()

        // Facteurs d'échelle de viewBox vers rect cible
        let scaleX = rect.width / viewBox.width
        let scaleY = rect.height / viewBox.height

        // Parser les commandes SVG
        let commands = parseCommands(svgPath)

        for command in commands {
            switch command.type {
            case "M": // MoveTo
                if let point = command.points.first {
                    let scaledPoint = scalePoint(point, scaleX: scaleX, scaleY: scaleY, rect: rect, viewBox: viewBox)
                    path.move(to: scaledPoint)
                }

            case "L": // LineTo
                if let point = command.points.first {
                    let scaledPoint = scalePoint(point, scaleX: scaleX, scaleY: scaleY, rect: rect, viewBox: viewBox)
                    path.addLine(to: scaledPoint)
                }

            case "Q": // Quadratic Bézier curve
                if command.points.count >= 2 {
                    let control = scalePoint(command.points[0], scaleX: scaleX, scaleY: scaleY, rect: rect, viewBox: viewBox)
                    let end = scalePoint(command.points[1], scaleX: scaleX, scaleY: scaleY, rect: rect, viewBox: viewBox)
                    path.addQuadCurve(to: end, control: control)
                }

            case "C": // Cubic Bézier curve
                if command.points.count >= 3 {
                    let control1 = scalePoint(command.points[0], scaleX: scaleX, scaleY: scaleY, rect: rect, viewBox: viewBox)
                    let control2 = scalePoint(command.points[1], scaleX: scaleX, scaleY: scaleY, rect: rect, viewBox: viewBox)
                    let end = scalePoint(command.points[2], scaleX: scaleX, scaleY: scaleY, rect: rect, viewBox: viewBox)
                    path.addCurve(to: end, control1: control1, control2: control2)
                }

            case "Z": // Close path
                path.closeSubpath()

            default:
                break
            }
        }

        return path
    }

    /// Met à l'échelle un point du système de coordonnées source vers le rectangle cible
    /// Note: Inverse l'axe Y car SVG a Y=0 en haut, SwiftUI aussi mais Make Me a Hanzi nécessite l'inversion
    private static func scalePoint(_ point: CGPoint, scaleX: CGFloat, scaleY: CGFloat, rect: CGRect, viewBox: CGSize) -> CGPoint {
        CGPoint(
            x: rect.minX + point.x * scaleX,
            y: rect.maxY - point.y * scaleY  // Inversion de l'axe Y
        )
    }

    /// Parse une chaîne de chemin SVG en commandes individuelles
    private static func parseCommands(_ svgPath: String) -> [SVGCommand] {
        var commands: [SVGCommand] = []
        let trimmed = svgPath.trimmingCharacters(in: .whitespaces)

        // Séparer par commandes (M, L, Q, C, Z)
        let pattern = "([MLQCZ])\\s*([^MLQCZ]*)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }

        let matches = regex.matches(in: trimmed, options: [], range: NSRange(trimmed.startIndex..., in: trimmed))

        for match in matches {
            guard match.numberOfRanges >= 3 else { continue }

            let typeRange = Range(match.range(at: 1), in: trimmed)!
            let dataRange = Range(match.range(at: 2), in: trimmed)!

            let type = String(trimmed[typeRange])
            let data = String(trimmed[dataRange])

            // Parser les coordonnées numériques
            let numbers = data.split(separator: " ")
                .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }

            // Convertir en points
            var points: [CGPoint] = []
            for i in stride(from: 0, to: numbers.count - 1, by: 2) {
                points.append(CGPoint(x: numbers[i], y: numbers[i + 1]))
            }

            commands.append(SVGCommand(type: type, points: points))
        }

        return commands
    }
}

/// Commande SVG individuelle
struct SVGCommand {
    let type: String      // M, L, Q, C, Z
    let points: [CGPoint]
}
