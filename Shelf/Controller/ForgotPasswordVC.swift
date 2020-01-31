//
//  ForgotPasswordVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/28/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import SpriteKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var backgroundSKView: SKView!
    @IBOutlet var tableView: UITableView!
    
    var email = ""
    var isVerified = false
    var sendEmailButton : UIButton!
    var sendEmailButtonView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundAnimations()
        setupTableView()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordVC.dismissKeyboard))
        //self.automaticallyAdjustsScrollViewInsets = false
        view.addGestureRecognizer(tap)
    }

    override func backPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    // MARK: - Setup helper functions
    fileprivate func setupBackgroundAnimations() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let scene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
        var imageName = "SplashBackground"
        getDeviceBackgroundImageName(&imageName)
        scene.makeBackground(imageName)
        backgroundSKView.showsFPS = false
        backgroundSKView.showsNodeCount = false
        backgroundSKView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        backgroundSKView.presentScene(scene)
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ForgotPasswordCell", bundle:  nil), forCellReuseIdentifier: "ForgotPasswordCell")
        tableView.backgroundColor = UIColor.clear
    }
    
    // MARK: - IBAction
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        backPressed()
    }
    
    @IBAction func sendEmailButtonPressed(_ sender: AnyObject) {
        AppDelegate.showActivity()
        PFUser.requestPasswordResetForEmail(inBackground: email, block: { (success, error) in
            AppDelegate.hideActivity()
            if success == true && error == nil {
                self.presentWarningDialog(title: "Password Reset", message: "Password Reset Email Sent!")
            } else {
                self.presentWarningDialog(title: "Password Reset", message: "User with Email not Found")
            }
        })
    }
    
    func emailEntered(_ textField : UITextField) {
        email = textField.text!
        if email.verifyEmail() == true {
            sendEmailButtonView.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 182/255, blue: 96/255, alpha: 1)
            sendEmailButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
            sendEmailButtonView.layer.borderWidth = 0.0
            sendEmailButtonView.layer.borderColor = UIColor.clear.cgColor
            sendEmailButton.isUserInteractionEnabled = true
            
        } else {
            sendEmailButtonView.backgroundColor = UIColor.clear
            sendEmailButtonView.layer.borderWidth = 1.0
            sendEmailButtonView.layer.borderColor = UIColor.white.cgColor
            sendEmailButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.0, width: 0, height: 0, shadowRadius: 0)
            sendEmailButton.isUserInteractionEnabled = false

        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ForgotPasswordVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForgotPasswordCell") as! ForgotPasswordCell
        cell.sendEmailButton.addTarget(self, action: #selector(ForgotPasswordVC.sendEmailButtonPressed(_:)), for: .touchUpInside)
        cell.emailTextField.addTarget(self, action: #selector(ForgotPasswordVC.emailEntered), for: .editingChanged)
        sendEmailButton = cell.sendEmailButton
        sendEmailButtonView = cell.sendEmailButtonView
        cell.selectionStyle = .none
        cell.emailTextField.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 667
    }
    
}

extension ForgotPasswordVC : UITextFieldDelegate {
    func createPlaceHolderString() -> NSAttributedString{
        let font = UIFont(name: "Avenir-Black", size: 10.5)
        let color = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.7)
        let str = NSAttributedString(string: "EMAIL", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName : font! , NSKernAttributeName : 1.8])
        return str
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing( _ textField : UITextField){
        textField.resignFirstResponder()
        textField.attributedPlaceholder = createPlaceHolderString()
    }
}
