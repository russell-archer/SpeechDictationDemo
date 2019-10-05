//
//  SpeechHelper.swift
//  Writerly
//
//  Created by Russell Archer on 09/02/2017.
//  Copyright © 2017 Russell Archer. All rights reserved.
//

import Foundation
import UIKit
import Speech

public protocol SpeechHelperProtocol {
    func recordButtonUpdate(enable: Bool, title: String?, info: String?, for state: UIControl.State?)
    func onDeviceRecog(isAvailable: Bool)
    func textUpdate(text: String, isFinal: Bool)
    func recordingStarted()
    func recordingFinished()
}

open class SpeechHelper: NSObject {
    /// Singleton access. Guaranteed to be lazily initialized only once, even when accessed
    /// across multiple threads simultaneously
    public static let shared: SpeechHelper = SpeechHelper()

    fileprivate let audioEngine = AVAudioEngine()
    fileprivate var speechRecognizer: SFSpeechRecognizer?
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    
    public var delegate: SpeechHelperProtocol?
    
    /// Private initializer prevents more than a single instance of this class being created.
    /// See the open static shared property
    private override init() { super.init() }
    
    /// Should be called when the host UIViewController's viewDidAppear() method's called
    public func initialize() -> (success: Bool, error: String?) {
        // Create a speech recognizer for the device's current locale, if supported. Will be nil 
        // if not supported. Note that supported does not mean currently available, because some 
        // locales may require an internet connection, for example
        speechRecognizer = SFSpeechRecognizer()
        
        guard speechRecognizer != nil else { return (success: false, error: "Speech recognition not available in your location.") }
        guard speechRecognizer!.isAvailable else { return (success: false, error: "Speech recognition temporarily unavailable. Try again later.") }
        
        speechRecognizer!.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // The callback may not be called on the main thread
            // Add an operation to the main queue to allow protocol implementors to update the record button's state
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.delegate?.onDeviceRecog(isAvailable: self.speechRecognizer!.supportsOnDeviceRecognition)
                    self.delegate?.recordButtonUpdate(enable: true, title: nil, info: "Speech recognition ready", for: nil)
                    
                case .denied:
                    self.delegate?.recordButtonUpdate(enable: false, title: nil, info: "Speech recognition access denied", for: .disabled)
                    
                case .restricted:
                    self.delegate?.recordButtonUpdate(enable: false, title: nil, info: "Speech recognition restricted", for: .disabled)
                    
                case .notDetermined:
                    self.delegate?.recordButtonUpdate(enable: false, title: nil, info: "Speech recognition not authorized", for: .disabled)
                    
                default:
                    fatalError()
                }
                
                
            }
        }
        
        return (success: true, error: nil)
    }
    
    public func startStopDictation() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            delegate?.recordButtonUpdate(enable: true, title: "Start Dictation", info: nil, for: [])
            delegate?.recordingFinished()
            
        } else {
            try! startDictation()
        }
    }
    
    public func cancel() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
    }
    
    fileprivate func startDictation() throws {
        guard speechRecognizer != nil else { return }
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.record)))
        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else { return }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session
        // We keep a reference to the task so that it can be cancelled
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let r = result {
                self.delegate?.textUpdate(text: r.bestTranscription.formattedString, isFinal: r.isFinal)
                isFinal = r.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        print("All OK and listening for speech")
        delegate?.textUpdate(text: "Go ahead, I'm listening...", isFinal: false)
        delegate?.recordButtonUpdate(enable: true, title: "Recording", info: nil, for: [])
        delegate?.recordingStarted()
    }
}

// MARK: SFSpeechRecognizerDelegate

extension SpeechHelper: SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {

        if available {
            delegate?.recordButtonUpdate(enable: true, title: "Start Dictation", info: nil, for: [])
            
        } else {
            delegate?.recordButtonUpdate(
                enable: false,
                title: "Start Dictation",
                info: "Speech recognition temporarily unavailable. Try again later.",
                for: .disabled)
        }
        
        delegate?.onDeviceRecog(isAvailable: speechRecognizer.supportsOnDeviceRecognition)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
