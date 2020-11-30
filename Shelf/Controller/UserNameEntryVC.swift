//
//  UserNameEntryVC.swift
//  Shelf
//
//  Created by Matthew James on 8/30/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import SpriteKit
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


class UserNameEntryVC: UIViewController {

    @IBOutlet weak var backgroundSKView: SKView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var infoTextLabel: ShelfLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinShelfButtonView: UIView!
    @IBOutlet weak var joinShelfButton: ShelfButton!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var joinShelfButtonViewBottomConstraint: NSLayoutConstraint!
    
    var user : PFUser!
    var username : String?
    var zipcode : String?
    var birthday : Date?
    var dateTextField : UITextField?
    let fieldTitles = ["USERNAME", "ZIPCODE", "BIRTHDAY"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackgroundAnimations()
        setupTopBar()
        setupTableView()
        setupBottomBar()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserNameEntryVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(UserNameEntryVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserNameEntryVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    fileprivate func setupTopBar() {
        infoTextLabel.layer.shadowColor = UIColor.black.cgColor
        infoTextLabel.layer.shadowRadius = 2
        infoTextLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        infoTextLabel.layer.shadowOpacity = 0.15
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RegisterCell" , bundle: nil), forCellReuseIdentifier: "RegisterCell")
    }
    
    fileprivate func setupBottomBar() {
        joinShelfButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
        joinShelfButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.6), forState: .highlighted)
        joinShelfButton.layer.cornerRadius = 8
        joinShelfButton.layer.masksToBounds = true
        
    }
    
    // MARK: - NSNotification
    func keyboardWillShow(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = frame.height
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableViewBottomConstraint.constant = keyboardHeight
            self.joinShelfButtonViewBottomConstraint.constant = keyboardHeight + 12
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) -> Void in
            
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: duration, animations: {
            self.tableViewBottomConstraint.constant = 0
            self.joinShelfButtonViewBottomConstraint.constant = 12
            self.view.layoutIfNeeded()
            
        }, completion: { (finished) in
            
        }) 
    }
    
    // MARK: - IBAction
    @IBAction func joinShelfButtonPressed(_ sender: AnyObject) {
        if validation() {
            saveUser()
        }
    }
    
    @IBAction func backSelected(_ sender: AnyObject) {
        logout()
        navigationController?.popViewController(animated: true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func userNameUpdated(_ textField : UITextField) {
        username = textField.text
    }
    
    func zipCodeUpdated(_ textField : UITextField) {
        zipcode = textField.text
    }
    
    func dateUpdated(_ datePicker : UIDatePicker) {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        let dateStr = f.string(from: datePicker.date)
        
        birthday = datePicker.date
        if let btf = dateTextField {
            btf.text = dateStr
        }
    }

    // MARK: - Helper functions
    func validation() -> Bool {
        if username == nil || username?.characters.count == 0 {
            presentUserNameError("Please enter username")
            return false
        }
        else if zipcode == nil || zipcode?.characters.count < 5{
            presentUserNameError("Please enter a valid zip code")
            return false
        }
        else if birthday == nil {
            presentUserNameError("Please enter a birthday")
            return false
        }
        
        return true
    }
    
    func presentUserNameError(_ message : String) {
        let alert = UIAlertController(title: "Shelf", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func logout() {
        PFUser.logOut()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    func saveUser() {
        AppDelegate.showActivity()
        if let userQuery = PFUser.query() {
            userQuery.whereKey("username", equalTo: username!.lowercased())
			
			userQuery.countObjectsInBackground(block: { (count, error) in
                
                if error == nil {
                    if count > 0 {
                        AppDelegate.hideActivity()
                        self.presentFBLoginErrorAlert("Username already exists, please enter a different username.")
                    }
                    // No username found
                    else {
                        self.user.setObject(true, forKey: "hasUpdatedUsername")
                        self.user.username = self.username
                        self.user["zipCode"] = self.zipcode
                        self.user["birthday"] = self.birthday
                        self.user.saveInBackground(block: { (success, error) in
                            AppDelegate.hideActivity()
                            if success == true {
                                let sb = UIStoryboard(name: "Main", bundle:  nil)
                                let vc = sb.instantiateViewController(withIdentifier: "HomeTBC")
                                self.present(vc, animated: true, completion: nil)
                                AnalyticsHelper.sendCustomEvent(kFIREventLogin)
                            }else{
                                self.presentFBLoginErrorAlert("Error occurred while saving username, please try again.")
                            }
                            
                        })
                        
                    }
                }
                else {
                    AppDelegate.hideActivity()
                    self.presentFBLoginErrorAlert("Error occurred while saving username, please try again.")
                }
            })
        }
    }
   
    func presentFBLoginErrorAlert(_ errorMessage : String ) {
        let alertC = UIAlertController(title: "Facebook Login Error", message: errorMessage, preferredStyle: .alert)
        alertC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertC, animated: true, completion: nil)
    }
    
    func createPlaceHolderString(_ row : Int) -> NSAttributedString{
        let font = UIFont(name: "Avenir-Black", size: 10.5)
        let color = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.7)
        let str = NSAttributedString(string: fieldTitles[row], attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName : font! , NSKernAttributeName : 1.8])
        return str
    }

}

extension UserNameEntryVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldTitles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCell") as! RegisterCell
        cell.selectionStyle = .none
        
        cell.contentOfCell.attributedPlaceholder = createPlaceHolderString(indexPath.row)
        cell.contentOfCell.tag = indexPath.row
        cell.contentOfCell.textColor = UIColor.white
        switch indexPath.row {
            case 0:
                cell.contentOfCell.addTarget(self, action: #selector(UserNameEntryVC.userNameUpdated(_:)), for: .editingChanged)
            case 1:
                cell.contentOfCell.addTarget(self, action: #selector(UserNameEntryVC.zipCodeUpdated(_:)), for: .editingChanged)
            case 2:
                let datePicker = UIDatePicker()
                datePicker.datePickerMode = .date
                datePicker.addTarget(self, action: #selector(UserNameEntryVC.dateUpdated(_:)), for: .valueChanged)
                cell.contentOfCell.inputView = datePicker
                cell.contentOfCell.delegate = self
                dateTextField = cell.contentOfCell
            default:
                break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
}

extension UserNameEntryVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing( _ textField : UITextField){
        textField.resignFirstResponder()
        textField.attributedPlaceholder = createPlaceHolderString(textField.tag)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
