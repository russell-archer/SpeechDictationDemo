//
//  TrafficLightIndicator.swift
//  SpeechDictationDemo
//
//  Created by Russell Archer on 07/10/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import UIKit

public class TrafficLightIndicator: UIView {
    
    public enum State { case red, green, amber }
    
    public var state = State.amber {
        didSet {
            switch state {
                case .red:   backgroundColor = UIColor.red
                case .green: backgroundColor = UIColor.green
                case .amber: backgroundColor = UIColor.orange
            }
        }
    }
    
    /// Draw ourselves as a circular object
    override public func draw(_ rect: CGRect) {
        let width = bounds.width < bounds.height ? bounds.width : bounds.height
        let mask = CAShapeLayer()
        
        mask.path = UIBezierPath(ovalIn: CGRect(
            x: bounds.midX - width / 2,
            y: bounds.midY - width / 2,
            width: width, height: width)).cgPath
        
        layer.mask = mask
    }
}
