//
//  ShelfButton.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/25/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class ShelfButton: UIButton {
    @IBInspectable var kerning: Float {
        get {
            var range = NSMakeRange(0, (titleLabel?.text ?? "").characters.count)
            guard let kern = titleLabel?.attributedText?.attribute(NSKernAttributeName, at: 0, effectiveRange: &range),
                let value = kern as? NSNumber else {
                    return 0
            }
            return value.floatValue
        }
        set {
            var attrText: NSMutableAttributedString
            
            if let attributedText = titleLabel?.attributedText {
                attrText = NSMutableAttributedString(attributedString: attributedText)
            } else if let text = titleLabel?.text {
                attrText = NSMutableAttributedString(string: text)
            } else {
                attrText = NSMutableAttributedString(string: "")
            }
            
            let range = NSMakeRange(0, attrText.length)
            attrText.addAttribute(NSKernAttributeName, value: NSNumber(value: newValue as Float), range: range)
            titleLabel?.attributedText = attrText
        }
    }
    
    func updateAttributedTextWithString(_ string: String, forState state: UIControlState) {
        guard let attributedText = titleLabel?.attributedText else {
            return
        }
        
        let attrText = NSMutableAttributedString(attributedString: attributedText)
        attrText.mutableString.setString(string)
        setAttributedTitle(attrText, for: state)
    }
    
    func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: state)
    }
}
