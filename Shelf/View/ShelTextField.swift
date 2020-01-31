//
//  ShelfTextField.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class ShelfTextField: UITextField {

    func setPlaceHolder( _ kerningDefault : Double, placeholderString : String){
        
        let ph = NSMutableAttributedString(string: placeholderString)
        let color = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 0.4)
        ph.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, ph.length))
        ph.addAttribute(NSKernAttributeName, value: kerningDefault, range:  NSMakeRange(0, ph.length))
        let font = UIFont(name: "Avenir-Black", size: 12)
        ph.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, ph.length))
        
        self.attributedPlaceholder = ph
    }
    
    @IBInspectable var kerning: Float {
        get {
            var range = NSMakeRange(0, (text ?? "").characters.count)
            guard let kern = attributedText?.attribute(NSKernAttributeName, at: 0, effectiveRange: &range),
                let value = kern as? NSNumber else {
                    return 0
            }
            return value.floatValue
        }
        set {
            var attText: NSMutableAttributedString
            
            if let attributedText = attributedText {
                attText = NSMutableAttributedString(attributedString: attributedText)
            } else if let text = text {
                attText = NSMutableAttributedString(string: text)
            } else {
                attText = NSMutableAttributedString(string: "")
            }
            
            let range = NSMakeRange(0, attText.length)
            attText.addAttribute(NSKernAttributeName, value: NSNumber(value: newValue as Float), range: range)
            self.attributedText = attText
        }
    }
    
    @IBInspectable var lineHeight: Float {
        get {
            var range = NSMakeRange(0, (text ?? "").characters.count)
            guard let space = attributedText?.attribute(NSParagraphStyleAttributeName, at: 0, effectiveRange: &range),
                let value = space as? NSNumber else {
                    return 0
            }
            return value.floatValue
        }
        set {
            var attText: NSMutableAttributedString
            
            if let attributedText = attributedText {
                attText = NSMutableAttributedString(attributedString: attributedText)
            } else if let text = text {
                attText = NSMutableAttributedString(string: text)
            } else {
                attText = NSMutableAttributedString(string: "")
            }
            
            let range = NSMakeRange(0, attText.length)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = CGFloat(newValue)
            paragraphStyle.alignment = .center
            attText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
            self.attributedText = attText
        }
    }
    
    func updateAttributedTextWithColor(_ color: UIColor) {
        guard let attributedText = attributedText else {
            return
        }
        
        let attrText = NSMutableAttributedString(attributedString: attributedText)
        attrText.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, attrText.length))
        self.attributedText = attrText
    }
    
    func updateAttributedTextWithString(_ string: String) {
        guard let attributedText = attributedText else {
            return
        }
        
        let attrText = NSMutableAttributedString(attributedString: attributedText)
        attrText.mutableString.setString(string)
        self.attributedText = attrText
    }
    
    func updateAttributedTextTextAlignment(_ textAlignment: NSTextAlignment) {
        guard let attributedText = attributedText else {
            return
        }
        
        let attrText = NSMutableAttributedString(attributedString: attributedText)
        var range = NSMakeRange(0, attrText.length)
        var paragraphStyle = NSMutableParagraphStyle()
        if let currParagraphStyle = attrText.attribute(NSParagraphStyleAttributeName, at: 0, effectiveRange: &range) as? NSParagraphStyle {
            if #available(iOS 9.0, *) {
                paragraphStyle.setParagraphStyle(currParagraphStyle)
            } else {
                // Fallback on earlier versions
                paragraphStyle = currParagraphStyle.mutableCopy() as! NSMutableParagraphStyle
            }
            paragraphStyle.alignment = textAlignment
            attrText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
            self.attributedText = attrText
        }
    }
}
