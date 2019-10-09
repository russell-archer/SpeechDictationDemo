//
//  SpeechViewController+Recognition.swift
//  SpeechDictationDemo
//
//  Created by Russell Archer on 07/10/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import Foundation
import UIKit

extension SpeechViewController: SpeechRecognitionProtocol {
    func recognitionUnavailableForLocale() {
        recognitionButton.recognitionState = .notAvailable
    }
    
    func recognitionTemporarilyUnavailable() {
        recognitionButton.recognitionState = .disabled
    }
    
    func recognition(isAuthorized: Bool) {
        recognitionButton.recognitionState = isAuthorized ? .stopped : .disabled
    }
    
    func recognition(isReady: Bool) {
        recognitionButton.recognitionState = isReady ? .stopped : .disabled
    }
    
    func recognitionStarted() {
        recognitionButton.recognitionState = .recognizing
    }
    
    func recognitionFinished() {
        recognitionButton.recognitionState = .stopped
    }
    
    func recognitionOnDevice(isAvailable: Bool) {
        doOnDeviceRecognition.state = isAvailable ? .green : .red
    }
    
    func recognitionTextUpdate(text: String, isFinal: Bool) {
        textView.text = text
    }
}
