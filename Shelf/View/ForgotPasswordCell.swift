//
//  ForgotPasswordCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/29/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class ForgotPasswordCell: UITableViewCell {

    @IBOutlet var emailTextField: ShelfTextField!
    @IBOutlet var sendEmailButtonView: UIView!
    @IBOutlet var sendEmailButton: ShelfButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupSendButton()
        emailTextField.attributedPlaceholder = createPlaceHolderString()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupSendButton()
    }
    
    func setupSendButton() {
        sendEmailButtonView.roundAndAddDropShadow(8, shadowOpacity: 0, width: 0, height: 0, shadowRadius: 0)
        sendEmailButtonView.layer.borderWidth = 1.0
        sendEmailButtonView.layer.borderColor = UIColor.white.cgColor
        sendEmailButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.6), forState: .highlighted)
        sendEmailButton.layer.cornerRadius = 8
        sendEmailButton.layer.masksToBounds = true
        sendEmailButton.isUserInteractionEnabled = false
    }
    
    func createPlaceHolderString() -> NSAttributedString{
        let font = UIFont(name: "Avenir-Black", size: 10.5)
        let color = UIColor.init(white: 1, alpha: 0.65)
        let str = NSAttributedString(string: "EMAIL", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName : font! , NSKernAttributeName : 1.8])
        return str
    }
}
