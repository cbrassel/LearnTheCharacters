//
//  TimerManager.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isRunning = false
    @Published var isWarning = false // True quand < 3 secondes

    private var timer: Timer?
    private let timeLimit: TimeInterval
    private var onTimeUp: (() -> Void)?

    init(timeLimit: TimeInterval) {
        self.timeLimit = timeLimit
        self.timeRemaining = timeLimit
    }

    func start(onTimeUp: @escaping () -> Void) {
        self.onTimeUp = onTimeUp
        isRunning = true
        timeRemaining = timeLimit

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.timeRemaining -= 0.1

            // Activer l'avertissement si < 3 secondes
            if self.timeRemaining <= 3.0 && !self.isWarning {
                self.isWarning = true
                AudioService.shared.playTimerWarningSound()
            }

            if self.timeRemaining <= 0 {
                self.timeUp()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isWarning = false
    }

    func reset() {
        stop()
        timeRemaining = timeLimit
    }

    private func timeUp() {
        stop()
        onTimeUp?()
    }

    var progress: Double {
        guard timeLimit > 0 else { return 0 }
        // Utiliser le temps arrondi pour la cohérence avec l'affichage
        let displaySeconds = Double(Int(ceil(timeRemaining)))
        return displaySeconds / ceil(timeLimit)
    }

    var displayTime: String {
        let seconds = Int(ceil(timeRemaining))
        return "\(seconds)s"
    }

    deinit {
        timer?.invalidate()
    }
}
