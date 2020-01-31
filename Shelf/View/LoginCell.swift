//
//  LoginCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/29/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class LoginCell: UITableViewCell {

    @IBOutlet var welcomeBackLabel: ShelfLabel!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var loginButton: ShelfButton!
    @IBOutlet weak var facebookButtonBackground: UIView!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var forgotPasswordButton: ShelfButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let font = UIFont(name: "Avenir-Black", size: 10.5)
        let color = UIColor(white: 1, alpha: 0.57)
        let usrStr = NSAttributedString(string: "USERNAME", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName : font! , NSKernAttributeName : 1.81])
        let pwStr = NSAttributedString(string: "PASSWORD", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName : font! , NSKernAttributeName : 1.81])
    
        userNameField.attributedPlaceholder = usrStr
        passwordField.attributedPlaceholder = pwStr
        
        loginButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.0, width: 0, height: 0, shadowRadius: 0)
        loginButtonView.layer.borderWidth = 1.0
        loginButtonView.layer.borderColor = UIColor.white.cgColor
        loginButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.6), forState: .highlighted)
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        loginButton.isUserInteractionEnabled = false
        
        facebookButtonBackground.layer.cornerRadius = 8.0
        facebookButtonBackground.layer.masksToBounds = true
    }
    
}
