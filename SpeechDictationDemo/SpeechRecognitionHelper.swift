//
//  SpeechRecognitionHelper.swift
//
//  Created by Russell Archer on 05/10/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import Foundation
import UIKit
import Speech

public protocol SpeechRecognitionProtocol {
    func recognitionUnavailableForLocale()  // Speech recognition not available for the locale
    func recognitionTemporarilyUnavailable()  // Speech recognition not available temporarily
    func recognition(isAuthorized: Bool)  // The user has authorized speech recognition
    func recognition(isReady: Bool)  // Ready to start doing speech recognition
    func recognitionStarted()  // Speech-to-text process started
    func recognitionFinished()  // Speech-to-text process stopped
    func recognitionOnDevice(isAvailable: Bool)  // Speech recognition is available on-device (no network connection required)
    func recognitionTextUpdate(text: String, isFinal: Bool)  // Speech-to-text update available
}

open class SpeechRecognitionHelper: NSObject {
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate var speechRecognizer: SFSpeechRecognizer?
    fileprivate var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    
    /// Set this delegate before calling initialize()
    public var delegate: SpeechRecognitionProtocol?
    
    /// Initializes speech recognition. Should be called in the host UIViewController's viewDidAppear() method
    public func initialize() {
        guard delegate != nil else { fatalError() }
        
        // Create a speech recognizer for the device's current locale, if supported. Will be nil 
        // if not supported. Note that supported does not mean currently available, because some 
        // locales may require an internet connection, for example
        speechRecognizer = SFSpeechRecognizer()
        
        guard speechRecognizer != nil else {
            delegate?.recognitionUnavailableForLocale()
            return
        }
        
        guard speechRecognizer!.isAvailable else {
            delegate?.recognitionTemporarilyUnavailable()
            return
        }
        
        speechRecognizer!.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Dispatch on the main queue to allow protocol implementors to update the UI
            
            DispatchQueue.main.async {
                self.delegate?.recognition(isAuthorized: authStatus == .authorized)
                self.delegate?.recognition(isReady: authStatus == .authorized)
                self.delegate?.recognitionOnDevice(isAvailable: self.speechRecognizer!.supportsOnDeviceRecognition)
            }
        }
    }
    
    /// Starts and new speech recognition session, or stops the current one
    public func startStopRecognition() {
        if audioEngine.isRunning { stopRecognition() } else
        { try! startDictation() }
    }
    
    /// Cancels the current recognition session
    public func cancel() {
        stopRecognition(finish: false)
    }
    
    fileprivate func startDictation() throws {
        guard speechRecognizer != nil else { return }
        
        // Stop the previous task if it's running.
        stopRecognition()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard recognitionRequest != nil else { return }
        
        recognitionRequest!.shouldReportPartialResults = true  // Results are returned before audio recording is finished
        
        // New for iOS 13. Keep speech recognition data on device if possible (if it's supported)
        if #available(iOS 13, *) {
            recognitionRequest!.requiresOnDeviceRecognition = speechRecognizer!.supportsOnDeviceRecognition
        }
        
        // Configure the microphone input
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [unowned self] buffer, when in
            self.recognitionRequest?.append(buffer)
        }
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest!) { [unowned self] result, error in
            if error != nil { self.stopRecognition() }
            if let r = result {
                self.delegate?.recognitionTextUpdate(text: r.bestTranscription.formattedString, isFinal: r.isFinal)
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        delegate?.recognitionStarted()
    }
    
    fileprivate func stopRecognition(finish: Bool = true) {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        if finish {
            recognitionTask?.finish()
        } else {
            recognitionTask?.cancel()
        }
        
        delegate?.recognitionFinished()
        
        recognitionRequest = nil
        recognitionTask = nil
    }
}

// MARK: SFSpeechRecognizerDelegate

extension SpeechRecognitionHelper: SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        delegate?.recognition(isReady: available)
        delegate?.recognitionOnDevice(isAvailable: speechRecognizer.supportsOnDeviceRecognition)
    }
}

