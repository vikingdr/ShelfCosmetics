//
//  LegalJargonVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 8/25/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

enum LegalViewType {
    case termsAndConditions, privacyPolicy
}

class LegalJargonVC: BaseVC {
    
    // MARK:- Outlets
    @IBOutlet weak var textView: UITextView!
    
    // MARK:- Variables
    var type : LegalViewType?
    
    override func viewDidLoad() {
        setupNavigationBar()
        
        // Spacing issue fix above UITextView & below UINavigationBar
        edgesForExtendedLayout = UIRectEdge()
        
        if type == .termsAndConditions {
            // Format text
            let attributedString = NSMutableAttributedString(string: constant.TermsAndConditions)
            let range = (constant.TermsAndConditions as NSString).range(of: "If you do not agree to be bound by the Terms and Conditions, do not use this Service.")
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 12)!, range: range)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, attributedString.length))
            let linkRange = (constant.TermsAndConditions as NSString).range(of: "hello@SHELFcosmetics.com")
            attributedString.addAttribute(NSLinkAttributeName, value: "mailto://hello@SHELFcosmetics.com", range: linkRange)

            // Display Terms & Conditions in TextView
            textView.attributedText = attributedString
            textView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor(r: 255, g: 182, b: 96)]
        } else if type == .privacyPolicy {
            // Format text
            let attributedString = NSMutableAttributedString(string: constant.PrivacyPolicy)
            var range = (constant.PrivacyPolicy as NSString).range(of: "If you do not agree to be bound by the Privacy Policy, do not use this Service.")
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 12)!, range: range)
            range = (constant.PrivacyPolicy as NSString).range(of: "Our Commitment to Privacy")
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 12)!, range: range)
            range = (constant.PrivacyPolicy as NSString).range(of: "Gathering Information")
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 12)!, range: range)
            range = (constant.PrivacyPolicy as NSString).range(of: "Third Party Sharing")
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 12)!, range: range)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, attributedString.length))
            
            // Display Privacy Policy in TextView
            textView.attributedText = attributedString
        }
        textView.contentOffset.y = 0
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        if type == .termsAndConditions {
            // Display Title
            title = "Terms & Conditions"
        }
        else if type == .privacyPolicy {
            // Display Title
            title = "Privacy Policy"
        }
    }
}
