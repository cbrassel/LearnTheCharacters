//
//  AudioService.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()

    private var audioPlayer: AVAudioPlayer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var preferredChineseVoice: AVSpeechSynthesisVoice?

    @Published var isPlaying = false

    private override init() {
        super.init()
        setupAudioSession()

        // Trouver la meilleure voix chinoise disponible
        selectBestChineseVoice()

        // Pré-charger le speechSynthesizer en lançant une synthèse silencieuse
        speechSynthesizer.delegate = self
        preloadSpeechSynthesizer()
    }

    private func selectBestChineseVoice() {
        // Récupérer toutes les voix chinoises disponibles
        let chineseVoices = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("zh")
        }

        print("📱 Voix chinoises disponibles sur cet appareil:")
        for voice in chineseVoices {
            print("  - \(voice.name) [\(voice.language)] - Qualité: \(voice.quality.rawValue)")
        }

        // Priorité de sélection:
        // 1. Voix Enhanced Quality pour zh-CN
        // 2. Voix Premium Quality pour zh-CN
        // 3. N'importe quelle voix zh-CN
        // 4. N'importe quelle voix chinoise

        if let enhancedVoice = chineseVoices.first(where: {
            $0.language == "zh-CN" && $0.quality == .enhanced
        }) {
            preferredChineseVoice = enhancedVoice
            print("✅ Voix sélectionnée: \(enhancedVoice.name) (Enhanced Quality)")
        } else if let premiumVoice = chineseVoices.first(where: {
            $0.language == "zh-CN" && $0.quality == .premium
        }) {
            preferredChineseVoice = premiumVoice
            print("✅ Voix sélectionnée: \(premiumVoice.name) (Premium Quality)")
        } else if let standardVoice = chineseVoices.first(where: {
            $0.language == "zh-CN"
        }) {
            preferredChineseVoice = standardVoice
            print("✅ Voix sélectionnée: \(standardVoice.name) (Standard)")
        } else if let anyChineseVoice = chineseVoices.first {
            preferredChineseVoice = anyChineseVoice
            print("⚠️ Voix sélectionnée: \(anyChineseVoice.name) [\(anyChineseVoice.language)]")
        } else {
            print("❌ Aucune voix chinoise disponible - utilisation de la voix par défaut")
        }
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Utiliser .measurement comme SpeechRecognitionService pour éviter les conflits
            // Mode .measurement est optimisé pour minimiser les traitements audio et réduire la latence
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Erreur configuration session audio: \(error.localizedDescription)")
        }
    }

    // MARK: - Lecture fichiers audio

    func playAudioFile(url: URL, completion: (() -> Void)? = nil) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true

            DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
                self.isPlaying = false
                completion?()
            }
        } catch {
            print("Erreur lecture audio: \(error.localizedDescription)")
            isPlaying = false
            completion?()
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
    }

    // MARK: - Synthèse vocale

    func speakCharacter(_ character: Character, completion: (() -> Void)? = nil) {
        // Arrêter toute synthèse en cours
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        // Utilisation de la synthèse vocale chinoise
        let utterance = AVSpeechUtterance(string: character.simplified)

        // Utiliser la voix présélectionnée
        if let voice = preferredChineseVoice {
            utterance.voice = voice
            print("🔊 Prononciation: \(character.simplified) avec \(voice.name)")
        } else {
            print("⚠️ Aucune voix chinoise disponible, utilisation de la voix par défaut")
        }

        utterance.rate = 0.4 // Vitesse plus lente pour apprentissage
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0 // Volume maximum pour la voix
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1

        self.isPlaying = true
        self.speechSynthesizer.speak(utterance)

        // Estimation durée
        let duration = Double(character.simplified.count) * 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isPlaying = false
            completion?()
        }
    }

    func speakText(_ text: String, language: String = "zh-CN", rate: Float = 0.5) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        isPlaying = true
        speechSynthesizer.speak(utterance)

        let duration = Double(text.count) * 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isPlaying = false
        }
    }

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }

    private func preloadSpeechSynthesizer() {
        // Créer une synthèse silencieuse pour initialiser le moteur TTS
        let utterance = AVSpeechUtterance(string: " ")
        utterance.volume = 0.0
        if let voice = preferredChineseVoice {
            utterance.voice = voice
        }
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Effets sonores

    func playSuccessSound() {
        // Utiliser feedback haptique au lieu de son système trop fort
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Son système plus doux
        playSystemSound(1104) // Son de message plus doux
    }

    func playErrorSound() {
        // Utiliser feedback haptique au lieu de son système trop fort
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)

        // Son système plus doux
        playSystemSound(1107) // Son plus doux que 1053
    }

    func playTimerWarningSound() {
        // Son d'avertissement pour fin du temps
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension AudioService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isPlaying = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isPlaying = true
    }
}
