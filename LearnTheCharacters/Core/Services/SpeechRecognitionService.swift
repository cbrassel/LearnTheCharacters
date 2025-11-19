//
//  SpeechRecognitionService.swift
//  LearnTheCharacters
//
//  Created by Claude on 17/11/2025.
//

import Foundation
import Speech
import AVFoundation
import Combine

// Helper pour logs avec timestamp
private func logWithTime(_ message: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    let timestamp = formatter.string(from: Date())
    print("[\(timestamp)] \(message)")
}

class SpeechRecognitionService: ObservableObject {
    static let shared = SpeechRecognitionService()

    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var recordingStartTime: Date?
    private var minimumRecordingDuration: TimeInterval = 1.0 // 1 seconde minimum

    private init() {
        // Initialisation avec le chinois mandarin
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))

        // Pré-initialiser l'audio session ET l'audio engine EN MODE MEASUREMENT pour éviter le délai
        DispatchQueue.global(qos: .userInitiated).async {
            // Petit délai pour laisser l'app se charger
            Thread.sleep(forTimeInterval: 0.5)

            do {
                let audioSession = AVAudioSession.sharedInstance()
                // IMPORTANT : Utiliser .measurement dès le départ
                try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetoothA2DP])
                try audioSession.setActive(true)

                // FORCER l'initialisation en accédant aux propriétés
                let _ = audioSession.category
                let _ = audioSession.mode
                let _ = audioSession.currentRoute
                let _ = audioSession.sampleRate

                logWithTime("✅ Audio session pré-initialisée")

                // CRITIQUE: Pré-initialiser l'audio engine et forcer l'accès au inputNode
                // C'est ici que se produit le délai de 4+ secondes à la première utilisation
                let inputNode = self.audioEngine.inputNode
                let _ = inputNode.outputFormat(forBus: 0)
                self.audioEngine.prepare()

                logWithTime("✅ Audio engine + inputNode pré-initialisés")
            } catch {
                print("⚠️ Erreur pré-initialisation audio session/engine: \(error)")
            }
        }
    }

    // MARK: - Autorisation

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
                completion(status == .authorized)
            }
        }
    }

    // MARK: - Reconnaissance vocale

    func startRecording(completion: @escaping (String, Double) -> Void) throws {
        // Vérifier l'autorisation
        guard authorizationStatus == .authorized else {
            throw RecognitionError.notAuthorized
        }

        // Empêcher les démarrages multiples
        if isRecording {
            print("⚠️ Enregistrement déjà en cours, ignoré")
            return
        }

        logWithTime("🎤 Démarrage de l'enregistrement...")

        // Annuler la tâche en cours si elle existe
        if let task = recognitionTask {
            task.cancel()
            recognitionTask = nil
        }
        logWithTime("  ↳ Tâche précédente nettoyée")

        // S'assurer que la session audio est active (déjà configurée en init)
        let audioSession = AVAudioSession.sharedInstance()
        logWithTime("  ↳ Audio session obtenue")

        // Simplement activer si nécessaire (category et mode déjà configurés)
        if !audioSession.isOtherAudioPlaying {
            logWithTime("  ↳ Activation de la session...")
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            logWithTime("  ↳ Session activée")
        } else {
            logWithTime("  ↳ Session déjà active")
        }

        logWithTime("🎧 Session audio prête")

        // Nettoyer l'audio engine s'il est en cours
        logWithTime("  ↳ Vérification audio engine...")
        let inputNode = audioEngine.inputNode
        if audioEngine.isRunning {
            logWithTime("  ↳ Arrêt audio engine en cours...")
            audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            Thread.sleep(forTimeInterval: 0.1)
            logWithTime("  ↳ Audio engine arrêté")
        }

        // Créer la requête de reconnaissance
        logWithTime("  ↳ Création de la requête de reconnaissance...")
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw RecognitionError.unableToCreateRequest
        }
        logWithTime("  ↳ Requête créée")

        recognitionRequest.shouldReportPartialResults = true

        // Augmenter le timeout et détecter la fin de parole plus tard
        if #available(iOS 16, *) {
            recognitionRequest.addsPunctuation = false
        }

        // Configuration pour reconnaissance chinoise optimisée
        recognitionRequest.taskHint = .dictation

        // Forcer la reconnaissance on-device pour de meilleures performances
        // (Plus rapide, fonctionne hors ligne, pas de latence réseau)
        if #available(iOS 17, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
            print("📱 Mode on-device (rapide et local)")
        }

        // Variable pour stocker le meilleur résultat
        var bestResult: (text: String, confidence: Double) = ("", 0.0)

        // Créer la tâche de reconnaissance
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false

            if let result = result {
                let transcription = result.bestTranscription.formattedString
                let confidence = result.bestTranscription.segments.first?.confidence ?? 0.0

                // Vérifier si c'est une reconnaissance on-device ou serveur
                if #available(iOS 17, *) {
                    let isOnDevice = result.bestTranscription.segments.first?.alternativeSubstrings.isEmpty ?? true
                    print("🔍 Reconnaissance: \(isOnDevice ? "📱 On-Device" : "☁️ Cloud")")
                }

                DispatchQueue.main.async {
                    self.recognizedText = transcription
                    print("📝 Reconnu: '\(transcription)' (confiance: \(confidence))")
                }

                // Garder le meilleur résultat
                if !transcription.isEmpty && Double(confidence) > bestResult.confidence {
                    bestResult = (transcription, Double(confidence))
                }

                isFinal = result.isFinal

                if isFinal {
                    print("✅ Reconnaissance finale: '\(transcription)'")
                    completion(transcription, Double(confidence))
                }
            }

            if let error = error {
                let nsError = error as NSError
                print("❌ Erreur reconnaissance: \(error.localizedDescription)")
                print("   Code d'erreur: \(nsError.code)")

                // Vérifier si c'est une erreur réseau
                // Codes d'erreur Speech Framework :
                // - 1101: Network issue (server unreachable)
                // - 1110: No speech detected (PAS une erreur réseau!)
                // - 203: Connection failed
                let isNetworkError = nsError.domain == NSURLErrorDomain ||
                                    nsError.code == 1101 || // Network/Server issue
                                    nsError.code == 203     // Connection failed

                // Code 1110 = No speech detected (erreur utilisateur, pas réseau)
                let isNoSpeechError = nsError.code == 1110

                if isNoSpeechError {
                    print("🎤 Aucune parole détectée - Vérifiez votre microphone ou parlez plus fort")
                } else if isNetworkError {
                    print("🌐 Erreur réseau détectée (ne devrait pas arriver en mode on-device)")
                }

                // Même en cas d'erreur, utiliser le meilleur résultat partiel si disponible
                if !bestResult.text.isEmpty {
                    print("📋 Utilisation du meilleur résultat partiel: '\(bestResult.text)'")
                    completion(bestResult.text, bestResult.confidence)
                } else {
                    print("⚠️ Aucun résultat partiel disponible")
                }
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }

        // Utiliser le format natif de l'input node
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        print("🎙️ Format d'enregistrement: \(recordingFormat.sampleRate)Hz, \(recordingFormat.channelCount) canaux")

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            // Vérifier que le buffer contient des données avant de l'envoyer
            guard buffer.floatChannelData != nil else { return }
            let frameLength = buffer.frameLength

            // Ignorer les buffers vides
            if frameLength > 0 {
                recognitionRequest.append(buffer)
            }
        }

        // Marquer comme en enregistrement AVANT de démarrer
        DispatchQueue.main.async {
            self.isRecording = true
            self.recognizedText = ""
        }

        // Enregistrer l'heure de début
        recordingStartTime = Date()

        // Démarrer l'engine audio
        audioEngine.prepare()
        try audioEngine.start()

        logWithTime("✅ Enregistrement actif, en attente de parole...")
    }

    func stopRecording() {
        guard isRecording else {
            print("⚠️ Pas d'enregistrement en cours")
            return
        }

        // Vérifier la durée minimum
        if let startTime = recordingStartTime {
            let duration = Date().timeIntervalSince(startTime)
            print("🛑 Arrêt demandé - Durée: \(String(format: "%.2f", duration))s")

            if duration < minimumRecordingDuration {
                print("⏱️ Durée trop courte, attente \(minimumRecordingDuration)s minimum...")
                // Attendre le temps restant
                let waitTime = minimumRecordingDuration - duration
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    self.finishRecording()
                }
                return
            }
        }

        finishRecording()
    }

    private func finishRecording() {
        print("🏁 Fin de l'enregistrement")

        // Terminer l'enregistrement audio proprement
        recognitionRequest?.endAudio()

        // Laisser plus de temps pour le traitement (1.5s au lieu de 0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Arrêter l'audio engine AVANT de retirer le tap pour éviter le warning buffer
            if self.audioEngine.isRunning {
                self.audioEngine.stop()

                // Petit délai pour laisser l'engine se stabiliser
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Vérifier que le tap existe avant de le retirer
                    let inputNode = self.audioEngine.inputNode
                    if inputNode.numberOfInputs > 0 {
                        inputNode.removeTap(onBus: 0)
                    }
                }
            }

            self.recognitionTask?.finish()

            self.recognitionRequest = nil
            self.recognitionTask = nil

            self.isRecording = false
            self.recordingStartTime = nil

            // Garder le mode .measurement pour le prochain enregistrement (pas de reconfiguration)
            // La session reste active et prête
            print("✅ Enregistrement terminé, session audio restaurée")
        }
    }

    // MARK: - Validation prononciation

    func validatePronunciation(expected: String, recognized: String, difficulty: GameSession.Difficulty = .intermediate, acceptedAlternatives: [String] = []) -> PronunciationResult {
        // Normalisation des textes
        let normalizedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedRecognized = recognized.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Si rien n'a été reconnu
        if normalizedRecognized.isEmpty {
            return PronunciationResult(
                isCorrect: false,
                accuracy: 0.0,
                feedback: "Aucun son détecté"
            )
        }

        // Vérification exacte
        if normalizedExpected == normalizedRecognized {
            return PronunciationResult(isCorrect: true, accuracy: 1.0, feedback: "Parfait!")
        }

        // Vérification des alternatives (ex: "14" pour "十四")
        print("🔍 Vérification alternatives pour '\(normalizedRecognized)'")
        print("📋 Alternatives disponibles: \(acceptedAlternatives)")
        for alternative in acceptedAlternatives {
            let normalizedAlt = alternative.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            print("   Comparaison: '\(normalizedAlt)' == '\(normalizedRecognized)' → \(normalizedAlt == normalizedRecognized)")
            if normalizedAlt == normalizedRecognized {
                print("✅ Alternative trouvée!")
                return PronunciationResult(isCorrect: true, accuracy: 1.0, feedback: "Correct!")
            }
        }

        // Vérification spéciale pour les nombres : si l'utilisateur dit un nombre arabe
        // et que le caractère attendu est un nombre chinois, extraire et comparer
        if let recognizedNumber = Int(normalizedRecognized) {
            print("🔢 Nombre détecté: \(recognizedNumber)")

            // Essayer d'extraire un nombre depuis les alternatives (traductions)
            for alternative in acceptedAlternatives {
                // Chercher des nombres dans les alternatives
                if let altNumber = Int(alternative.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    print("   Comparaison nombres: \(altNumber) == \(recognizedNumber) → \(altNumber == recognizedNumber)")
                    if altNumber == recognizedNumber {
                        print("✅ Nombre correspondant trouvé!")
                        return PronunciationResult(isCorrect: true, accuracy: 1.0, feedback: "Correct!")
                    }
                }

                // Chercher aussi la correspondance avec les noms français de nombres
                let numberWords = [
                    "zéro": 0, "un": 1, "deux": 2, "trois": 3, "quatre": 4, "cinq": 5,
                    "six": 6, "sept": 7, "huit": 8, "neuf": 9, "dix": 10,
                    "onze": 11, "douze": 12, "treize": 13, "quatorze": 14, "quinze": 15,
                    "seize": 16, "dix-sept": 17, "dix-huit": 18, "dix-neuf": 19, "vingt": 20
                ]

                let normalizedAlt = alternative.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if let altNumber = numberWords[normalizedAlt], altNumber == recognizedNumber {
                    print("✅ Nombre français '\(normalizedAlt)' correspond à \(recognizedNumber)")
                    return PronunciationResult(isCorrect: true, accuracy: 1.0, feedback: "Correct!")
                }
            }
        }

        // Vérification des homophones chinois (même prononciation mais caractère différent)
        // Ex: 电 (diàn) reconnu au lieu de 店 (diàn)
        if isChineseCharacter(normalizedRecognized) && isChineseCharacter(normalizedExpected) {
            // Si les deux sont des caractères chinois, vérifier si c'est un homophone via le pinyin
            // On accepte si le pinyin de l'alternative correspond
            let recognizedWithoutTones = removeTones(from: normalizedRecognized)

            // Vérifier si le pinyin attendu (sans tons) correspond
            for alternative in acceptedAlternatives {
                let altWithoutTones = removeTones(from: alternative.lowercased())
                if altWithoutTones == recognizedWithoutTones && !altWithoutTones.isEmpty {
                    print("⚠️ Homophone détecté: '\(normalizedRecognized)' a la même base que '\(normalizedExpected)'")

                    // Vérifier si les tons sont corrects (comparaison exacte avec le pinyin)
                    let exactPinyinMatch = acceptedAlternatives.contains { alt in
                        alt.lowercased() == normalizedRecognized.lowercased()
                    }

                    if exactPinyinMatch {
                        // Les tons sont corrects mais c'est le mauvais caractère (homophone parfait)
                        print("✅ Tons corrects pour l'homophone")
                        return PronunciationResult(
                            isCorrect: true,
                            accuracy: 0.85,
                            feedback: "Bons tons, mais attention au caractère!"
                        )
                    } else {
                        // Les tons sont probablement incorrects
                        print("⚠️ Tons potentiellement incorrects")
                        return PronunciationResult(
                            isCorrect: true,
                            accuracy: 0.6,
                            feedback: "Attention aux tons!"
                        )
                    }
                }
            }
        }

        // Vérification supplémentaire : comparer le pinyin attendu avec le texte reconnu
        // pour détecter les prononciations approximatives (ex: "dian" vs "diàn")
        for alternative in acceptedAlternatives {
            let altWithoutTones = removeTones(from: alternative.lowercased())
            let recognizedWithoutTones = removeTones(from: normalizedRecognized)

            // Si le pinyin sans tons correspond (ex: "dian" == "dian")
            if !altWithoutTones.isEmpty && altWithoutTones == recognizedWithoutTones {
                print("🔍 Pinyin sans tons correspond: '\(recognizedWithoutTones)'")

                // Vérifier si les tons correspondent exactement
                if alternative.lowercased() == normalizedRecognized {
                    print("✅ Pinyin avec tons parfait!")
                    return PronunciationResult(
                        isCorrect: true,
                        accuracy: 0.95,
                        feedback: "Excellent! Tons parfaits!"
                    )
                } else {
                    // Base correcte mais tons approximatifs
                    print("⚠️ Base correcte mais tons à améliorer")

                    // Selon la difficulté, accepter ou non
                    let shouldAccept = difficulty == .beginner || difficulty == .intermediate

                    return PronunciationResult(
                        isCorrect: shouldAccept,
                        accuracy: 0.7,
                        feedback: shouldAccept ? "Bien! Attention aux tons." : "Presque! Vérifiez les tons."
                    )
                }
            }
        }

        // Seuils de tolérance selon la difficulté
        let (acceptanceThreshold, nearThreshold) = difficulty.pronunciationThresholds

        // Vérification partielle (similitude)
        let similarity = calculateSimilarity(normalizedExpected, normalizedRecognized)

        print("🎯 Similarité calculée: \(String(format: "%.2f", similarity)) | Seuil d'acceptation: \(String(format: "%.2f", acceptanceThreshold))")

        if similarity >= acceptanceThreshold {
            return PronunciationResult(
                isCorrect: true,
                accuracy: similarity,
                feedback: "Très bien!"
            )
        } else if similarity >= nearThreshold {
            return PronunciationResult(
                isCorrect: false,
                accuracy: similarity,
                feedback: "Presque! Réessayez."
            )
        } else {
            return PronunciationResult(
                isCorrect: false,
                accuracy: similarity,
                feedback: "Essayez encore."
            )
        }
    }

    private func calculateSimilarity(_ str1: String, _ str2: String) -> Double {
        // Algorithme simple de distance de Levenshtein normalisée
        let distance = levenshteinDistance(str1, str2)
        let maxLength = max(str1.count, str2.count)
        guard maxLength > 0 else { return 1.0 }
        return 1.0 - (Double(distance) / Double(maxLength))
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let m = s1.count
        let n = s2.count
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m {
            matrix[i][0] = i
        }
        for j in 0...n {
            matrix[0][j] = j
        }

        for i in 1...m {
            for j in 1...n {
                let cost = s1[s1.index(s1.startIndex, offsetBy: i - 1)] ==
                           s2[s2.index(s2.startIndex, offsetBy: j - 1)] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }

        return matrix[m][n]
    }

    private func isChineseCharacter(_ text: String) -> Bool {
        // Vérifier si le texte contient des caractères chinois
        let chineseRange = text.unicodeScalars.contains { scalar in
            (0x4E00...0x9FFF).contains(scalar.value) || // CJK Unified Ideographs
            (0x3400...0x4DBF).contains(scalar.value) || // CJK Extension A
            (0x20000...0x2A6DF).contains(scalar.value)  // CJK Extension B
        }
        return chineseRange
    }

    private func removeTones(from text: String) -> String {
        // Supprimer les tons du pinyin ou nettoyer le texte
        // Pour simplifier, on garde juste les lettres et espaces
        let cleaned = text.lowercased()
            .replacingOccurrences(of: "ā", with: "a")
            .replacingOccurrences(of: "á", with: "a")
            .replacingOccurrences(of: "ǎ", with: "a")
            .replacingOccurrences(of: "à", with: "a")
            .replacingOccurrences(of: "ē", with: "e")
            .replacingOccurrences(of: "é", with: "e")
            .replacingOccurrences(of: "ě", with: "e")
            .replacingOccurrences(of: "è", with: "e")
            .replacingOccurrences(of: "ī", with: "i")
            .replacingOccurrences(of: "í", with: "i")
            .replacingOccurrences(of: "ǐ", with: "i")
            .replacingOccurrences(of: "ì", with: "i")
            .replacingOccurrences(of: "ō", with: "o")
            .replacingOccurrences(of: "ó", with: "o")
            .replacingOccurrences(of: "ǒ", with: "o")
            .replacingOccurrences(of: "ò", with: "o")
            .replacingOccurrences(of: "ū", with: "u")
            .replacingOccurrences(of: "ú", with: "u")
            .replacingOccurrences(of: "ǔ", with: "u")
            .replacingOccurrences(of: "ù", with: "u")
            .replacingOccurrences(of: "ǖ", with: "v")
            .replacingOccurrences(of: "ǘ", with: "v")
            .replacingOccurrences(of: "ǚ", with: "v")
            .replacingOccurrences(of: "ǜ", with: "v")
            .replacingOccurrences(of: "ü", with: "v")
        return cleaned
    }

    enum RecognitionError: Error {
        case notAuthorized
        case unableToCreateRequest
        case audioEngineError
    }
}

struct PronunciationResult {
    let isCorrect: Bool
    let accuracy: Double // 0.0 to 1.0
    let feedback: String
}
