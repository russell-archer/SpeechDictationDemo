//
//  SpeechViewController.swift
//
//  Created by Russell Archer on 05/10/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import UIKit
import Speech

class SpeechViewController: UIViewController {

    @IBOutlet weak var recognitionButton: SpeechRecognitionButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var doOnDeviceRecognition: TrafficLightIndicator!
    @IBOutlet weak var messagesLabel: UILabel!
    
    fileprivate let speechRecognitionHelper = SpeechRecognitionHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        speechRecognitionHelper.delegate = self
        speechRecognitionHelper.initialize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        speechRecognitionHelper.cancel()  // Stop the speech engine if it's running
    }

    @IBAction func recognitionButtonTapped(_ sender: Any) {
        speechRecognitionHelper.startStopRecognition()
    }
}
