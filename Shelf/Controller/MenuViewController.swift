//
//  MenuViewController.swift
//  Shelf
//
//  Created by Matthew James on 29/04/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import SpriteKit
import ParseFacebookUtilsV4
import MBProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
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


let kMenuVCIdentifier = "MenuVC"

enum LoginType {
    case login
    case registration
    case facebook
    case none
}

class MenuViewController: UIViewController {

    @IBOutlet weak var backgroundSKView: SKView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    fileprivate var welcomeBackLabel : UILabel!
    fileprivate var logging: Bool = false
    fileprivate var email = ""
    fileprivate var password = ""
    fileprivate var loginButton : UIButton!
    fileprivate var loginButtonView : UIView!
    fileprivate let cellTitles = ["USERNAME", "PASSWORD"]
    var loginType: LoginType = .none
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundAnimations()
        setupTableView()
        
        // Transition to LoginVC
        if loginType == .login {
            //transitionToLogInVC(true)
        }
        // Transition to RegistrationVC
        else if loginType == .registration {
            transitionToRegistrationVC(true)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.onProfileUpdated(_:)), name: NSNotification.Name.FBSDKProfileDidChange, object: nil)
        
        //navigationController?.navigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logging = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Setup helper functions
    func setupBackgroundAnimations() {
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
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LoginCell", bundle: nil), forCellReuseIdentifier: "LoginCell")
    }
    
    // MARK: - NSNotification
    func keyboardWillShow(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = frame.height
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
           self.tableViewBottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) -> Void in
            let path = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: path, at: .middle, animated: true)
            
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: duration, animations: {
            self.tableViewBottomConstraint.constant = 12
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) in
            
        }) 
    }
    
    func onProfileUpdated(_ notification: Notification) {
        print("userInfo: \(notification.userInfo)")
    }
    
    // MARK: - IBAction
    override func backPressed() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        backPressed()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func emailEdited(_ emailField : UITextField) {
        email = emailField.text!
        verifyEnteredText()
    }
    
    @IBAction func passwordEdited(_ passwordField : UITextField) {
        password = passwordField.text!
        verifyEnteredText()
    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        checkFirstField(email.lowercased(), password: password)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: AnyObject) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Transition helper functions
    fileprivate func transitionToLogInVC(_ animated: Bool) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kLoginVCIdentifier) as! LoginViewController
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    fileprivate func transitionToRegistrationVC(_ animated: Bool) {
        let vc = storyboard?.instantiateViewController(withIdentifier: kRegistrationVCIdentifier) as! RegistrationViewController
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    //MARK: - Login With Facebook
    fileprivate func getDetailsAndLogin() {
        if logging {
            return
        }
        logging = true
        requestFacebook()
    }
    
    fileprivate func requestFacebook() {
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.labelText = "Logging In"

        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, picture.type(large), email, cover.type(large)"])
		request?.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result1: Any?, error: Error?) in
            print("result: \(result1)")
            if error == nil && result1 != nil {
				let result = result1 as! [String: String?]
                if let firstName = result["first_name"],
                    let lastName = result["last_name"],
                    let email = result["email"] {
                    self.loginFBParse(firstName!, lastName: lastName!, email: email!, result: result as AnyObject)
                }
                else {
                    self.logoutFacebook()
                    self.presentFBLoginErrorAlert()
                }
            }
            else {
                self.presentFBLoginErrorAlert()
            }
        })
    }
    
    fileprivate func queryExistingNonFBUser(_ email: String, result: AnyObject) {
        if let query = PFUser.query() {
            query.whereKey("email", equalTo: email)
            query.whereKeyDoesNotExist("authData")

            query.countObjectsInBackground(block: { (count: Int32, error: Error?) in
                if error == nil {
                    print("count: \(count)")
                    if count > 0 {
                        let message = "The email address \(email) has already been taken. Please Login with your existing email and password."
                        let alertC = UIAlertController(title: "Facebook Login Error", message: message, preferredStyle: .alert)
                        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertC, animated: true, completion: nil)
                        
                        self.logoutFacebook()
                        // Parse creates a new user with PFFacebookUtils that needs to be deleted.
                        do {
                            try PFUser.current()?.delete()
                        } catch {
                            
                        }
                        PFUser.logOut()
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    }else {
                        if let currentUser = PFUser.current() {
                            currentUser.email = email
                            self.saveProfilePic(result)
                        }
                        else {
                            self.presentFBLoginErrorAlert()
                            self.logoutFacebook()
                            PFUser.logOut()
                        }
                    }
                }
                else {
                    self.logoutFacebook()
                    PFUser.logOut()
                    self.presentFBLoginErrorAlert()
                }
            })
        } else {
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        }
    }
    
    fileprivate func loginFBParse(_ firstName: String, lastName: String, email: String, result: AnyObject) {
		PFFacebookUtils.logInInBackground(with: FBSDKAccessToken.current()) { (user: PFUser?, error: Error?) in
            if error == nil && user != nil {
                if let currentUser = PFUser.current() {
                    currentUser["firstName"] = firstName
                    currentUser["lastName"] = lastName
                    currentUser["searchText"] = firstName.lowercased() + lastName.lowercased() + email.lowercased()
                    
                    // Check if existing FB user
                    if let _ = currentUser.email {
                        currentUser.email = email
                        self.saveProfilePic(result)
                    }
                    // New FB User, query to see if email exists for another account
                    else {
                        self.queryExistingNonFBUser(email, result: result)
                    }
                    
                }
                else {
                    self.presentFBLoginErrorAlert()
                    self.logoutFacebook()
                    PFUser.logOut()
                }
            }
            else {
                self.presentFBLoginErrorAlert()
                self.logoutFacebook()
                print("error occurred while signing in ")
//                print(error)
            }
        }
    }
    
    fileprivate func saveProfilePic(_ result: AnyObject) {
        if let profilePic = result.object(forKey: "picture")?.object(forKey: "data")?.object(forKey: "url") as? String {
            let imageData = try? Data(contentsOf: URL(string: profilePic)!)
            
            let compressedImage = compressImage( UIImage(data: imageData!)!)
            let picFile = PFFile(name: "profilePic.jpg", data: UIImageJPEGRepresentation(UIImage(data: compressedImage)!, 1.0)!)
			
			picFile?.saveInBackground(block: { (success: Bool, error: Error?) in
                if error == nil && success == true {
                    if let currentUser = PFUser.current() {
                        currentUser["image"] = picFile
                    }
                    self.saveCoverPic(result)
                }
                else {
                    self.presentFBLoginErrorAlert()
                    self.logoutFacebook()
                }
            })
        }
        // No FB profile picture url
        else {
            self.saveCoverPic(result)
        }
    }
    
    fileprivate func saveCoverPic(_ result: AnyObject) {
        if let coverPic = result.object(forKey: "cover")?.object(forKey: "source") as? String {
            let imageDataCover = try? Data(contentsOf: URL(string: coverPic)!)
            
            let compressedImage = compressImage( UIImage(data: imageDataCover!)!)
            let coverFile = PFFile(name: "coverPic.jpg", data: UIImageJPEGRepresentation(UIImage(data: compressedImage)!, 1.0)!)
            
            coverFile?.saveInBackground(block: { (success: Bool, error: Error?) in
                if error == nil && success == true {
                    if let currentUser = PFUser.current() {
                        currentUser["coverImage"] = coverFile
                    }
                    self.saveCurrentUser()
                }
                else {
                    self.presentFBLoginErrorAlert()
                    self.logoutFacebook()
                }
            })
        }
        // No FB cover picture url
        else {
            self.saveCurrentUser()
        }
    }
    
    fileprivate func saveCurrentUser() {
        if let currentUser = PFUser.current() {
            self.addVersionToUser(currentUser)
            currentUser.saveInBackground(block: { (success: Bool, error: Error?) in
                if error == nil && success {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    if currentUser.object(forKey: "hasUpdatedUsername") != nil && currentUser.object(forKey: "hasUpdatedUsername") as! Bool == true {
                        SFollow.refreshFollowing()
                        SFollow.refreshFollowers()
                        AnalyticsHelper.sendCustomEvent(kFIREventLogin)
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sb.instantiateViewController(withIdentifier: "HomeTBC") as! CustomTabbarController
                        self.present(vc, animated: true, completion: nil)
                    }else {
                        let userNameEntry = self.storyboard?.instantiateViewController(withIdentifier: "UserNameEntryVC") as! UserNameEntryVC
                        userNameEntry.user = currentUser
                        self.navigationController?.pushViewController(userNameEntry, animated: true)
                        
                    }

                }
                else {
                    self.presentFBLoginErrorAlert()
                    self.logoutFacebook()
                    PFUser.logOut()
                }
            })
        }
        else {
            self.presentFBLoginErrorAlert()
            self.logoutFacebook()
            PFUser.logOut()
        }
    }
    
    fileprivate func logoutFacebook() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        logging = false
        
    }
    
    fileprivate func presentFBLoginErrorAlert() {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        let alertC = UIAlertController(title: "Facebook Login Error", message: "Error occurred while signing in with Facebook, please try again.", preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertC, animated: true, completion: nil)
    }
    
    func setupFBLoginButton(_ fbLoginButton : FBSDKLoginButton) {
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.delegate = self
        fbLoginButton.layer.cornerRadius = 8
        fbLoginButton.layer.masksToBounds = true
        let aStr = NSMutableAttributedString(string: "Log in With Facebook")
        let color = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 1)
        aStr.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, aStr.length))
        aStr.addAttribute(NSKernAttributeName, value: 0.4, range:  NSMakeRange(0, aStr.length))
        let font = UIFont(name: "Avenir-Black", size: 12)
        aStr.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, aStr.length))
        fbLoginButton.setAttributedTitle(aStr, for: UIControlState())
        fbLoginButton.titleLabel?.adjustsFontSizeToFitWidth = true
        fbLoginButton.titleLabel?.lineBreakMode = .byClipping
        
        fbLoginButton.contentHorizontalAlignment = .left
        fbLoginButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
    }
    
    // MARK: - Helper functions
    func verifyEnteredText() {
        if email.characters.count > 0 && password.characters.count > 0 {
            loginButtonView.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 182/255, blue: 96/255, alpha: 1)
            loginButtonView.roundAndAddDropShadow(8.0, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
            loginButtonView.layer.borderWidth = 0.0
            loginButtonView.layer.borderColor = UIColor.clear.cgColor
            loginButton.isUserInteractionEnabled = true
        } else {
            loginButtonView.backgroundColor = UIColor.clear
            loginButtonView.layer.borderWidth = 1.0
            loginButtonView.layer.borderColor = UIColor.white.cgColor
            loginButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.0, width: 0, height: 0, shadowRadius: 0)
            loginButton.isUserInteractionEnabled = false
        }
    }
    
    func checkFirstField(_ email: String, password: String) {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.labelText = "Logging In"
        
        var username = email
        if let _ = username.characters.index(of: "@") {
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
		PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
           MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            guard error == nil, let user = user else {
                print(error!._code)
                
                let alertController = UIAlertController(title: "Login Error", message: "Please try again!", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    // Dismiss the alert
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            self.view.endEditing(true)
            self.addVersionToUser(user)
            PFInstallation.current()?.setObject(user, forKey: "user")
            PFInstallation.current()?.saveEventually(nil)
            SFollow.refreshFollowing()
            SFollow.refreshFollowers()
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.showContent()
            AnalyticsHelper.sendCustomEvent(kFIREventLogin)
        }
    }
    
    func addVersionToUser(_ user : PFUser ) {
        //Adds in app version
        let version: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        if let versionString = version as? String {
            if let appVersionString = user["AppVersion"] as? String{
                if versionString.compare(appVersionString, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending  {
                    user["AppVersion"] = versionString
                }
            }else
                if user["AppVersion"] as? String == nil {
                    user["AppVersion"] = versionString
                    print(user["AppVersion"])
                    
            }
        }
    }
    
    func createPlaceHolderString(_ row : Int) -> NSAttributedString{
        let font = UIFont(name: "Avenir-Black", size: 10.5)
        let color = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.7)
        let str = NSAttributedString(string: cellTitles[row], attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName : font! , NSKernAttributeName : 1.8])
        return str
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MenuViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoginCell") as! LoginCell
        cell.selectionStyle = .none
        cell.forgotPasswordButton.addTarget(self, action: #selector(MenuViewController.forgotPasswordButtonPressed(_:)), for: .touchUpInside)
        cell.loginButton.addTarget(self, action: #selector(MenuViewController.loginButtonPressed(_:)), for: .touchUpInside)
        cell.userNameField.addTarget(self, action: #selector(MenuViewController.emailEdited(_:)), for: .editingChanged)
        cell.userNameField.tag = 0
        cell.passwordField.tag = 1
        cell.userNameField.delegate = self
        cell.passwordField.delegate = self
        cell.passwordField.addTarget(self, action: #selector(MenuViewController.passwordEdited(_:)), for: .editingChanged)
        loginButton = cell.loginButton
        loginButtonView = cell.loginButtonView
        setupFBLoginButton(cell.facebookLoginButton)
        welcomeBackLabel = cell.welcomeBackLabel
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 506
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if let lbl = welcomeBackLabel {
            if offset > 0 {
                lbl.alpha = 1 - (offset/60)
            }else{
                lbl.alpha = 1
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension MenuViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing( _ textField : UITextField) {
        textField.resignFirstResponder()
        textField.attributedPlaceholder = createPlaceHolderString(textField.tag)
    }
}

// MARK: - FBSDKLoginButtonDelegate
extension MenuViewController: FBSDKLoginButtonDelegate {
	/*!
	@abstract Sent to the delegate when the button was used to login.
	@param loginButton the sender
	@param result The results of the login
	@param error The error (if any) from the login
	*/
	public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            // Display Alert
            print("error: \(error)")
        } else if result.isCancelled {
            // Display Alert
            print("result.isCancelled: \(result.isCancelled)")
        } else {
            if result.grantedPermissions.contains("email") {
                self.getDetailsAndLogin()
            } else {
                // if user doesn't grant email permissions deny access  and log them out
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                logging = false
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}
