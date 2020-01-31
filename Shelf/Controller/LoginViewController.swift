//
//  LoginViewController.swift
//  Shelf
//
//  Created by Nathan Konrad on 30/04/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let kLoginVCIdentifier = "LoginVC"

class LoginViewController: UIViewController,UITabBarControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var textFieldEmail:UITextField?
    @IBOutlet var textFieldPassword:UITextField?

    @IBOutlet var backgroundImageView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!
     let validator = Validator()
    var activeTextField : UITextField?
    
    // MARK: - View Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imgBackButton = UIImage(named: "btnBack")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        btnBack.setImage(imgBackButton, for: UIControlState())
        
        textFieldEmail?.attributedPlaceholder = NSAttributedString(string:"EMAIL OR USERNAME",
            attributes:[NSForegroundColorAttributeName: UIColor.white, NSKernAttributeName: 4])
        
        textFieldPassword?.attributedPlaceholder = NSAttributedString(string:"PASSWORD",
            attributes:[NSForegroundColorAttributeName: UIColor.white, NSKernAttributeName: 4])
        
        
       // scrollView.bounces = false
        scrollView.isScrollEnabled = true

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.scrollView.setContentOffset(CGPoint(x: 0,y: -scrollView.contentInset.top) ,animated: false)
    }

    func dismissKeyboard() {
        view.endEditing(true)
        self.scrollView?.contentOffset = CGPoint(x: 0,y: 0 )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    // MARK: - ALL Validation  methods
    
    func validation() -> Bool{
        
        if textFieldEmail?.text==""{
            let alert = UIAlertController(title: "Shelf", message: "Please enter Email.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return false
        }
        else if textFieldPassword?.text==""{
            let alert = UIAlertController(title: "Shelf", message: "Please enter password.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return false
        }
        return true;
    }
     func isValidEmail(_ testStr:String) -> Bool {
        print("validate email: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        if let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx) as NSPredicate? {
            return emailTest.evaluate(with: testStr)
        }
        return false
    }
    // MARK: - Navigation
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.30, delay: 0, options: .beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
            self.activeTextField = textField
            
            self.scrollView?.contentOffset = CGPoint(x: 0, y: textField.frame.origin.y - 140)
            }, completion: nil)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField == textFieldEmail{
            textFieldEmail?.resignFirstResponder()
            textFieldPassword?.becomeFirstResponder()
        }
        else if textField == textFieldPassword{
            textFieldPassword?.resignFirstResponder()
            
        }
        
        return true
    }
    
    // MARK: - Custom Button methods
    @IBAction func LoginBtnAction(_ sender: AnyObject){
        checkFirstField(textFieldEmail!.text!.lowercased(), password: textFieldPassword!.text!)
    }
    
    @IBAction func backBtnAction(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkFirstField(_ email: String, password: String) {
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.labelText = "Logging In"
        
        var username = email
        if (username.characters.index(of: "@") != nil) {
            let query = PFQuery(className: "_User")
            query.whereKey("email", equalTo: username)
            query.findObjectsInBackground(block: { (objects, error) in

                if error == nil && objects != nil {
                    if objects?.count > 0 {
                        username = objects![0]["username"] as! String
                        self.login(username, password: password)
                    }
                    else {
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)                        
                        let alertController = UIAlertController(title: "Login Error", message: "Email not found, please try again!", preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            // Dismiss the alert
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true) {}
                    }
                }
                else {
                    print("error: \(error)")
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    
                    let alertController = UIAlertController(title: "Login Error", message: "Please try again!", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        // Dismiss the alert
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true) {}
                }
            })
        }
        else {
            login(username, password: password)
        }
    }
    
    func login(_ username: String, password: String) {
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) -> Void in
            if !(error != nil) {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.view.endEditing(true)
                PFInstallation.current()?.setObject(PFUser.current()!, forKey: "user")
                PFInstallation.current()?.saveEventually(nil)
                SFollow.refreshFollowing()
                SFollow.refreshFollowers()
                self.checkIfAppVersionOnParseIsCurrent()
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.showContent()
                AnalyticsHelper.sendCustomEvent(kFIREventLogin)
            } else {
                print(error!._code)
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                let alertController = UIAlertController(title: "Login Error", message: "Please try again!", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    // Dismiss the alert
                }
                
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func checkIfAppVersionOnParseIsCurrent(){
        if let user = PFUser.current(){
            //Adds in app version
            let version: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
            if let versionString = version as? String {
                if let appVersionString = user["AppVersion"] as? String{
                    if versionString.compare(appVersionString, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending  {
                        user["AppVersion"] = versionString
                        user.saveInBackground()
                    }
                }else
                    if user["AppVersion"] as? String == nil {
                        user["AppVersion"] = versionString
                        print(user["AppVersion"])
                        user.saveInBackground()
                }
            }
    }
}
}
