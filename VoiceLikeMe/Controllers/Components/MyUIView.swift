//
//  MyUIView.swift
//  VoiceLikeMe
//
//  Created by Alguz on 4/19/20.
//  Copyright © 2020 Andre Rosa. All rights reserved.
//

import UIKit

@IBDesignable class MyUIView: UIView {
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            layer.borderColor = self.borderColor.cgColor
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
//            layer.masksToBounds = true
            layer.cornerRadius = self.cornerRadius
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = self.borderWidth
        }
    }
    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            updateShadow()
        }
    }
    @IBInspectable var shadowLeft: CGFloat = 0 {
        didSet {
            updateShadow()
        }
    }
    @IBInspectable var shadowTop: CGFloat = 0 {
        didSet {
            updateShadow()
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            updateShadow()
        }
    }
    @IBInspectable var shadowOpacity: CGFloat = 0.2 {
        didSet {
            updateShadow()
        }
    }
    
    func updateShadow() {
        layer.shadowColor = self.shadowColor.cgColor
        layer.shadowOffset = CGSize(width: self.shadowLeft, height: self.shadowTop)
        layer.shadowRadius = self.shadowRadius
        layer.shadowOpacity = Float(self.shadowOpacity)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
