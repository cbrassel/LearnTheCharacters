//
//  VoiceAvailabilityService.swift
//  LearnTheCharacters
//
//  Created by Claude on 20/11/2025.
//

import Foundation
import AVFoundation
import UIKit
import Combine

class VoiceAvailabilityService: ObservableObject {
    static let shared = VoiceAvailabilityService()

    @Published var hasChineseVoice: Bool = false
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []
    @Published var recommendedVoice: String = ""

    private init() {
        checkVoiceAvailability()
    }

    func checkVoiceAvailability() {
        let chineseVoices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("zh")
        }

        availableVoices = chineseVoices
        hasChineseVoice = !chineseVoices.isEmpty

        // Recommander une voix selon la qualité disponible
        if chineseVoices.isEmpty {
            recommendedVoice = "Ting-Ting (Chinois - Chine)"
        } else if let enhancedVoice = chineseVoices.first(where: { $0.quality == .enhanced || $0.quality == .premium }) {
            recommendedVoice = enhancedVoice.name
        }
    }

    // Détection de la version iOS
    var iOSVersion: String {
        return UIDevice.current.systemVersion
    }

    var iOSMajorVersion: Int {
        let version = iOSVersion.split(separator: ".").first
        return Int(version ?? "0") ?? 0
    }

    // Instructions personnalisées selon la version iOS
    func getInstructions() -> [OnboardingStep] {
        let majorVersion = iOSMajorVersion

        if majorVersion >= 18 {
            // iOS 18+
            return [
                OnboardingStep(
                    number: 1,
                    icon: "gearshape.fill",
                    title: "Ouvrez Réglages",
                    description: "Appuyez sur l'icône Réglages de votre iPhone"
                ),
                OnboardingStep(
                    number: 2,
                    icon: "accessibility",
                    title: "Accessibilité",
                    description: "Faites défiler et sélectionnez 'Accessibilité'"
                ),
                OnboardingStep(
                    number: 3,
                    icon: "speaker.wave.3.fill",
                    title: "Contenu énoncé",
                    description: "Dans la section AUDITION, touchez 'Contenu énoncé'"
                ),
                OnboardingStep(
                    number: 4,
                    icon: "person.wave.2.fill",
                    title: "Voix",
                    description: "Sélectionnez 'Voix' en haut de l'écran"
                ),
                OnboardingStep(
                    number: 5,
                    icon: "globe.asia.australia.fill",
                    title: "Chinois (Chine)",
                    description: "Touchez 'Chinois (Chine)' dans la liste"
                ),
                OnboardingStep(
                    number: 6,
                    icon: "arrow.down.circle.fill",
                    title: "Télécharger Ting-Ting",
                    description: "Touchez l'icône ☁️ à côté de 'Ting-Ting (Qualité supérieure)' pour télécharger la voix (~60 MB)"
                )
            ]
        } else if majorVersion >= 16 {
            // iOS 16-17
            return [
                OnboardingStep(
                    number: 1,
                    icon: "gearshape.fill",
                    title: "Ouvrez Réglages",
                    description: "Appuyez sur l'icône Réglages de votre iPhone"
                ),
                OnboardingStep(
                    number: 2,
                    icon: "accessibility",
                    title: "Accessibilité",
                    description: "Descendez et touchez 'Accessibilité'"
                ),
                OnboardingStep(
                    number: 3,
                    icon: "speaker.wave.3.fill",
                    title: "Contenu énoncé",
                    description: "Dans AUDITION, sélectionnez 'Contenu énoncé'"
                ),
                OnboardingStep(
                    number: 4,
                    icon: "person.wave.2.fill",
                    title: "Voix",
                    description: "Touchez 'Voix'"
                ),
                OnboardingStep(
                    number: 5,
                    icon: "globe.asia.australia.fill",
                    title: "Chinois (Chine)",
                    description: "Sélectionnez 'Chinois (Chine)'"
                ),
                OnboardingStep(
                    number: 6,
                    icon: "arrow.down.circle.fill",
                    title: "Télécharger la voix",
                    description: "Appuyez sur l'icône nuage à côté de 'Ting-Ting' pour télécharger"
                )
            ]
        } else {
            // iOS 15 et antérieur
            return [
                OnboardingStep(
                    number: 1,
                    icon: "gearshape.fill",
                    title: "Réglages",
                    description: "Ouvrez l'app Réglages"
                ),
                OnboardingStep(
                    number: 2,
                    icon: "accessibility",
                    title: "Accessibilité",
                    description: "Touchez 'Accessibilité'"
                ),
                OnboardingStep(
                    number: 3,
                    icon: "speaker.wave.3.fill",
                    title: "Contenu énoncé",
                    description: "Sélectionnez 'Contenu énoncé'"
                ),
                OnboardingStep(
                    number: 4,
                    icon: "person.wave.2.fill",
                    title: "Voix",
                    description: "Touchez 'Voix'"
                ),
                OnboardingStep(
                    number: 5,
                    icon: "globe.asia.australia.fill",
                    title: "Chinois",
                    description: "Choisissez 'Chinois (Chine)'"
                ),
                OnboardingStep(
                    number: 6,
                    icon: "arrow.down.circle.fill",
                    title: "Télécharger",
                    description: "Téléchargez la voix Ting-Ting"
                )
            ]
        }
    }

    // Ouvrir l'app Réglages
    func openSettings() {
        // Apple ne permet pas d'ouvrir directement des pages spécifiques des Réglages
        // On ouvre l'app Réglages en général et l'utilisateur devra naviguer manuellement
        // en suivant les instructions du guide
        if let settingsUrl = URL(string: "App-Prefs:root=General") {
            // Tenter d'ouvrir la page Général des Réglages
            UIApplication.shared.open(settingsUrl) { success in
                if !success {
                    // Si ça échoue, ouvrir juste l'app Réglages
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
    }
}

// Modèle pour les étapes du guide
struct OnboardingStep: Identifiable {
    let id = UUID()
    let number: Int
    let icon: String
    let title: String
    let description: String
}
