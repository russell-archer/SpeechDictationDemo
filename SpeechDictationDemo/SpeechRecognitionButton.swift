//
//  SpeechRecognitionButton.swift
//  SpeechDictationDemo
//
//  Created by Russell Archer on 08/10/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import UIKit

public class SpeechRecognitionButton: UIButton {
    
    public enum RecognitionState { case notAvailable, disabled, stopped, recognizing  }
    
    fileprivate var defaultColor: UIColor!
    fileprivate var defaultBgColor: UIColor!
    
    public var recognitionState = RecognitionState.stopped {
        didSet {
            switch recognitionState {
                case .notAvailable:
                    isEnabled = false
                    setTitle("Recognition Not Available", for: .disabled)
                    restoreDefaultColors()
                
                case .disabled:
                    isEnabled = false
                    setTitle("Temporarily Unavailable", for: .disabled)
                    restoreDefaultColors()
                
                case .stopped:
                    isEnabled = true
                    setTitle("Start Recognition", for: .normal)
                    restoreDefaultColors()
                
                case .recognizing:
                    isEnabled = true
                    setTitle("Stop Recognition", for: .normal)
                    recognizingColors()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        saveDefaultColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        saveDefaultColors()
    }

    fileprivate func saveDefaultColors() {
        defaultColor = self.tintColor
        defaultBgColor = self.backgroundColor
    }
    
    fileprivate func restoreDefaultColors() {
        self.tintColor = defaultColor
        self.backgroundColor = defaultBgColor
    }
    
    fileprivate func recognizingColors() {
        self.tintColor = UIColor.white
        self.backgroundColor = UIColor.systemRed
    }
}
