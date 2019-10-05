//
//  SpeechViewController.swift
//  Writerly
//
//  Created by Russell Archer on 04/02/2017.
//  Copyright © 2017 Russell Archer. All rights reserved.
//

import UIKit
import Speech

class SpeechViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var onDeviceRecognition: UISwitch!
    
    var defaultColor: UIColor!
    var defaultBgColor: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Save the default colors of the start/stop button
        defaultColor = recordButton.tintColor
        defaultBgColor = recordButton.backgroundColor
        
        // Disable the record buttons until authorization has been granted.
        recordButton.isEnabled = false
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let result = SpeechHelper.shared.initialize()
        if !result.success {
            recordButton.isEnabled = false
            print(result.error!)
            return
        }
        
        SpeechHelper.shared.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SpeechHelper.shared.cancel()  // Stop the speech engine if it's running
    }

    @IBAction func recordButtonTapped(_ sender: Any) {
        SpeechHelper.shared.startStopDictation()
    }
}

extension SpeechViewController: SpeechHelperProtocol {

    func recordButtonUpdate(enable: Bool, title: String?, info: String?, for state: UIControl.State?) {
        print("Speech recognition is available")
        recordButton.isEnabled = enable
        
        guard title != nil else { return }
        recordButton.setTitle(title!, for: state!)
    }
    
    func onDeviceRecog(isAvailable: Bool) {
        print("On-device recognition is available")
        onDeviceRecognition.isOn = isAvailable
    }
    
    func textUpdate(text: String, isFinal: Bool){
        print("Text update: \(text)")
        textView.text = text
    }
    
    public func recordingStarted() {
        recordButton.tintColor = UIColor.white
        recordButton.backgroundColor = UIColor.red
    }
    
    public func recordingFinished() {
        recordButton.tintColor = defaultColor
        recordButton.backgroundColor = defaultBgColor
    }
}


