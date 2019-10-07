//
//  UIView+round.swift
//  SpeechDictationDemo
//
//  Created by Russell Archer on 07/10/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /// Makes an image rounded
    func round() {
        let width = bounds.width < bounds.height ? bounds.width : bounds.height
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: CGRect(x: bounds.midX - width / 2, y: bounds.midY - width / 2, width: width, height: width)).cgPath
        layer.mask = mask
    }
}
