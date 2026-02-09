//
//  TimerView.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        ZStack {
            // Cercle de fond
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: 5
                )

            // Cercle de progression
            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: timerManager.progress)

            // Texte du temps
            Text(timerManager.displayTime)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(progressColor)
                .contentTransition(.numericText()) // Animation fluide pour les chiffres
                .scaleEffect(timerManager.isWarning ? 1.1 : 1.0)
                .animation(
                    timerManager.isWarning
                        ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                        : .easeInOut(duration: 0.3), // Animation de retour rapide quand isWarning devient false
                    value: timerManager.isWarning
                )
        }
        .frame(width: 55, height: 55)
    }

    private var progressColor: Color {
        if timerManager.progress > 0.5 {
            return .green
        } else if timerManager.progress > 0.25 {
            return .orange
        } else {
            return .red
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        TimerView(timerManager: TimerManager(timeLimit: 10))
        TimerView(timerManager: {
            let manager = TimerManager(timeLimit: 10)
            manager.timeRemaining = 5
            return manager
        }())
        TimerView(timerManager: {
            let manager = TimerManager(timeLimit: 10)
            manager.timeRemaining = 2
            manager.isWarning = true
            return manager
        }())
    }
    .padding()
}
