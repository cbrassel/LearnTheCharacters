//
//  StrokePathShape.swift
//  LearnTheCharacters
//
//  Created by Claude on 03/01/2026.
//

import SwiftUI

/// Shape SwiftUI pour un trait SVG unique
struct StrokePathShape: Shape {
    let svgPath: String
    let viewBox: CGSize

    func path(in rect: CGRect) -> Path {
        SVGPathParser.parse(svgPath, in: rect, viewBox: viewBox)
    }
}
