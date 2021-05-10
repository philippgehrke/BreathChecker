//
//  AudioAnalyzer.swift
//  Breath_Checker
//
//  Created by Jan Philipp Gehrke on 5/7/21.
//

import Foundation
import AVFoundation
import SoundAnalysis

class AudioAnalyzer: NSObject, SNResultsObserving, ObservableObject {
    // Needed for inference
    //var soundClassifier: BreathCheckerModel
    //var analyzer: SNAudioStreamAnalyzer?
    
    @Published var prediction = ""
    @Published var confidence = 0
    
    var audioEngine: AVAudioEngine
    var audioSession: AVAudioSession
    
    override init() {
        //soundClassifier = BreathCheckerModel()
        
        audioEngine = AVAudioEngine()
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth])
            try audioSession.setActive(true)
        }
        catch {
        }
    }
    
    func startAudioEngine() {
        audioEngine.reset()
        audioEngine.connect(audioEngine.inputNode, to: audioEngine.mainMixerNode, format: audioEngine.inputNode.outputFormat(forBus: 0))
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: audioEngine.mainMixerNode.outputFormat(forBus: 0))
        
        //audioEngine.mainMixerNode.outputVolume = 0
        tapMicrophoneForRecording()

        try! audioEngine.start()
    }
    
    func tapMicrophoneForRecording() {
        let fileName = "recorded_breath.caf"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileURL = URL(fileURLWithPath: documentsPath).appendingPathComponent(fileName)
        var recordingFile = try! AVAudioFile(forWriting: fileURL, settings: audioEngine.inputNode.outputFormat(forBus: 0).settings)
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize:1024, format:audioEngine.inputNode.outputFormat(forBus: 0)) { buffer, time in
            do {
                try recordingFile.write(from: buffer)
            } catch {
            }
        }
    }
    
//    func tapMicrophoneForInference() {
//        analyzer = SNAudioStreamAnalyzer(format: audioEngine.inputNode.outputFormat(forBus: 0))
//        do {
//            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
//            try analyzer!.add(request, withObserver: self)
//        } catch {
//            return
//        }
//        audioEngine.inputNode.removeTap(onBus: 0)
//        
//        audioEngine.inputNode.installTap(onBus: 0, bufferSize:1024, format:audioEngine.inputNode.outputFormat(forBus: 0)) { buffer, time in
//            DispatchQueue.main.async {
//                self.analyzer!.analyze(buffer, atAudioFramePosition: time.sampleTime)
//            }
//        }
//    }
    
    func stopAudioEngine() {
        audioEngine.stop()
    }
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
            let classification = result.classifications.first else { return }
            DispatchQueue.main.async {
                self.prediction = classification.identifier
                self.confidence = Int(classification.confidence * 100)
            }
    }
}
