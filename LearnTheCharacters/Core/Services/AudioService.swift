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

    @Published var isPlaying = false

    private override init() {
        super.init()
        setupAudioSession()

        // Pré-charger le speechSynthesizer en lançant une synthèse silencieuse
        speechSynthesizer.delegate = self
        preloadSpeechSynthesizer()
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

        // Essayer d'obtenir une voix chinoise, sinon utiliser la voix par défaut
        if let chineseVoice = AVSpeechSynthesisVoice(language: "zh-CN") {
            utterance.voice = chineseVoice
            print("🔊 Utilisation de la voix chinoise")
        } else {
            print("⚠️ Voix chinoise non disponible, utilisation de la voix par défaut")
        }

        utterance.rate = 0.4 // Vitesse plus lente pour apprentissage
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0 // Volume maximum pour la voix
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1

        isPlaying = true
        speechSynthesizer.speak(utterance)

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
        if let chineseVoice = AVSpeechSynthesisVoice(language: "zh-CN") {
            utterance.voice = chineseVoice
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
