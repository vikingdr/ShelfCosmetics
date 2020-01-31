//
//  RegistrationViewController.swift
//  Shelf
//
//  Created by Nathan Konrad on 01/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import MobileCoreServices
import MBProgressHUD
import Firebase
import SpriteKit
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


let kRegistrationVCIdentifier = "RegistrationVC"

class RegistrationViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var backgroundSKView: SKView!
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet var backgroundImageView: UIImageView!
    let cellTitles = ["FULL NAME", "USERNAME", "BIRTHDAY", "ZIPCODE", "EMAIL", "PASSWORD", "REENTER PASSWORD"]
    fileprivate var profilePic: UIImage?
    var model = RegistrationModel()
    var profileView : UIView?
    var birthdayTextField : ShelfTextField?
    
    var joinShelfButtonView : UIView!
    var joinShelfButton : UIButton!
    
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundAnimations()
        
        //Line Spacing
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7
        navigationController?.isNavigationBarHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RegisterCell", bundle: nil), forCellReuseIdentifier: "RegisterCell")
        tableView.register(UINib(nibName: "SelectAProfileImageCell", bundle: nil), forCellReuseIdentifier: "SelectAProfileImageCell")
        
        tableView.register(UINib(nibName: "RegisterJoinCell", bundle: nil), forCellReuseIdentifier: "RegisterJoinCell")
        
        tableView.separatorStyle = .none        
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Setup helper functions
    func setupBackgroundAnimations() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let scene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
        var imageName = "RegistrationBackground"
        getDeviceBackgroundImageName(&imageName)
        scene.makeBackground(imageName)
        backgroundSKView.showsFPS = false
        backgroundSKView.showsNodeCount = false
        backgroundSKView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        backgroundSKView.presentScene(scene)
    }
    
    // MARK: - NSNotification
    func keyboardWillShow(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = frame.height
        self.tableViewBottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: duration, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) -> Void in
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        self.tableViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
        }) 
    }
    
    @IBAction func joinShelfButtonPressed(_ sender: AnyObject) {
        if validation() {
            if let stremail = model.email {
                if stremail.verifyEmail() {
                    view.endEditing(true)
                    if model.password == model.verifyPassword {
                        registerUser()
                    }
                    else {
                        let alert = UIAlertController(title: "Shelf", message: "Password mismatch. Please check password and re type password", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else{
                    let alert = UIAlertController(title: "Shelf", message: "Please enter valid email.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
   
    // MARK: - Validations
    func validation() -> Bool{
        let nameArray = model.fullName?.components(separatedBy: " ")
        var valid = true
        if model.fullName == nil || model.fullName?.isEmpty == true || nameArray == nil || nameArray?.count < 2 {
            /*
            let alert = UIAlertController(title: "Shelf", message: "Please enter full name", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
             */
            valid = false
        }
        
        else if model.userName == nil || model.userName?.isEmpty == true {
            /*
            let alert = UIAlertController(title: "Shelf", message: "Please enter username", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            valid = false
        }
        else if model.birthday == nil {
            /*
            let alert = UIAlertController(title: "Shelf", message: "Please enter a birthday", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            valid = false
        }
        else if model.zipCode == nil || model.zipCode?.isEmpty == true || model.zipCode?.characters.count < 5 {
            /*
            let alert = UIAlertController(title: "Shelf", message: "Please enter a valid zipcode", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            valid = false
        }
        else if model.email == nil || model.email?.isEmpty == true || model.email?.verifyEmail() == false {
            /*
            let alert = UIAlertController(title: "Shelf", message: "Please enter a valid email", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            valid = false
        }
        else if model.password == nil || model.password?.isEmpty == true{
            /*
            let alert = UIAlertController(title: "Shelf", message: "Please enter a valid password", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            valid = false
        }
        else if model.verifyPassword == nil || model.verifyPassword?.isEmpty == true || model.verifyPassword != model.password {
            /*
            let alert = UIAlertController(title: "Shelf", message: "Please enter password verification", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            valid = false
        }
        else if profilePic == nil {
            /*
            let alert = UIAlertController(title: "Shelf", message: "Please select a profile image", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            valid = false
        }
        
        if joinShelfButtonView != nil && joinShelfButton != nil {
            if valid == true {
                joinShelfButtonView.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 182/255, blue: 96/255, alpha: 1)
                joinShelfButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.15, width: 0, height: 1, shadowRadius: 1)
                joinShelfButtonView.layer.borderWidth = 0.0
                joinShelfButtonView.layer.borderColor = UIColor.clear.cgColor
                joinShelfButton.isUserInteractionEnabled = true
            } else {
                joinShelfButtonView.backgroundColor = UIColor.clear
                joinShelfButtonView.layer.borderWidth = 1.0
                joinShelfButtonView.layer.borderColor = UIColor.white.cgColor
                joinShelfButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.0, width: 0, height: 0, shadowRadius: 0)
                joinShelfButton.isUserInteractionEnabled = false
            }
        }
        return valid;
    }

    
    @IBAction func RegisterBtnAction(_ sender: AnyObject){

    }
 
    func registerUser() {
        if profilePic == nil {
            // Display alert view saying missing profile pic
            
            return
        }
        let compressedImage = compressImage(self.profilePic!)
        
        let profilePicFile: PFFile = PFFile(name: "profilepic.jpg", data: UIImageJPEGRepresentation(UIImage(data: compressedImage)!, 1.0)!)!
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.labelText = "Registering"
		profilePicFile.saveInBackground { (success, error) in
            if error == nil && success {
                // Create and save PFUser object in here
                var user: PFUser = PFUser()
                
                let searchString : String = self.model.fullName!.lowercased() + self.model.email!
                let nameArray = self.model.fullName?.components(separatedBy: " ")
                // Use email for required username field
                user.username = self.model.userName?.lowercased()
                user.email = self.model.email?.lowercased()
                user.password = self.model.password
                user["following"] = []
                user["followers"] = []
                user["bio"] = ""
                user["firstName"] = nameArray![0]
                user["lastName"] = nameArray![1]
                user["image"] = profilePicFile
                user["searchText"] = searchString.lowercased()
                user["zipCode"] = self.model.zipCode
                user["birthday"] = self.model.birthday
                self.addVersionToUser(&user)
                print("in registerUser")
				
				user.signUpInBackground(block: { (success, error) in
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    if !(error != nil) {
                        
                        self.view.endEditing(true)
                        PFInstallation.current()?.setObject(PFUser.current()!, forKey: "user")
                        PFInstallation.current()?.saveEventually(nil)
                        SFollow.refreshFollowing()
                        SFollow.refreshFollowers()
                        let delegate = UIApplication.shared.delegate as! AppDelegate
                        print("delegate ")
                        delegate.showContent()
                        AnalyticsHelper.sendCustomEvent(kFIREventSignUp)
                    } else {
                        print(error!._code)
                        let errorMessage: String = error!.localizedDescription
                        
                        let alertController = UIAlertController(title: "Registration Error", message: errorMessage, preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            // Dismiss the alert
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true) {}
                    }
                })

            } else {
                print("success: \(success)")
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
        }
    }


    func presentAlertForImageSource(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Capture Photo", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            print("Capture Photo")
            self .capture()
        })
        let saveAction = UIAlertAction(title: "Select From gallery", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            print("Capture Photo")
            
            self .selectFromgallery()
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    @IBAction func backBtnAction(_ sender: AnyObject){
      self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Capture Image code
    func capture() {
        print("Button capture")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.camera;
            imag.mediaTypes = [kUTTypeImage as String]
            imag.allowsEditing = true
            
            self.present(imag, animated: true, completion: nil)
            
        }
    }
    
    func selectFromgallery() {
        print("Button capture")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        {
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imag.mediaTypes = [kUTTypeImage as String]
            imag.allowsEditing = true
            
            self.present(imag, animated: true, completion: nil)
            
        }
    }
    
     // MARK: - ImagePicker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.profilePic = image;
        if let pv = profileView {
            let iv = UIImageView(frame: pv.bounds)
            iv.image = image
            iv.layer.cornerRadius = iv.frame.size.width / 2
            iv.layer.masksToBounds = true
            iv.layer.borderWidth = 2
            iv.layer.borderColor = UIColor.white.cgColor
            pv.addSubview(iv)
            pv.layer.borderWidth = 0
            pv.layer.shadowOpacity = 0.23
            pv.layer.shadowColor = UIColor.black.cgColor
            pv.layer.shadowRadius = 2
            pv.layer.shadowOffset = CGSize(width: 0, height: 2)
            
            //pv.roundAndAddDropShadow(8.0, shadowOpacity: 0.15,width: 1, height: 2, shadowRadius: 1)
        }
        validation()
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.30, delay: 0, options: .BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
            self.scollview?.contentOffset = CGPointMake(0, textField.frame.origin.y - 130)
            }, completion: nil)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if textField == textFieldFirstName{
            textFieldFirstName?.resignFirstResponder()
            textFieldLastName?.becomeFirstResponder()
        }
        else if textField == textFieldLastName{
            textFieldLastName?.resignFirstResponder()
            textFieldUsername?.becomeFirstResponder()
        }
        else if textField == textFieldUsername{
            textFieldLastName?.resignFirstResponder()
            textFieldEmail?.becomeFirstResponder()
        }
        else if textField == textFieldEmail{
            textFieldEmail?.resignFirstResponder()
            textFieldPassword?.becomeFirstResponder()
        }
        else if textField == textFieldPassword{
            textFieldPassword?.resignFirstResponder()
            tfReEnterPassword?.becomeFirstResponder()
        }
        else if textField == tfReEnterPassword{
            tfReEnterPassword?.resignFirstResponder()
        }
        return true
    }
    */
    func addVersionToUser(_ user : inout PFUser){
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
    
    func fullNameUpdated(_ textField : UITextField){
        model.fullName = textField.text
         validation()
    }
    
    func userNameUpdated(_ textField : UITextField){
        model.userName = textField.text
        validation()
    }
    
    func zipCodeUpdated(_ textField : UITextField){
        model.zipCode = textField.text
         validation()
    }
    
    func emailUpdated(_ textField : UITextField){
        model.email = textField.text
         validation()
    }
    
    func passwordUpdated(_ textField : UITextField){
        model.password = textField.text
         validation()
    }
    
    func reenterPasswordUpdated(_ textField : UITextField){
        model.verifyPassword = textField.text
         validation()
    }
    
    func parseDate(_ date : Date){
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        let dateStr = f.string(from: date)
        
        if let btf = birthdayTextField {
            btf.text = dateStr
        }
    }
    
    func birthdayUpdated(_ datePicker : UIDatePicker){

        parseDate(datePicker.date)
        model.birthday = datePicker.date
      
    }
    
    func tappedProfileView(){
        presentAlertForImageSource()
    }
    
    func createPlaceHolderString(_ row : Int) -> NSAttributedString{
        let font = UIFont(name: "Avenir-Black", size: 10.5)
        let color = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.7)
        let str = NSAttributedString(string: cellTitles[row], attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName : font! , NSKernAttributeName : 1.8])
        return str
    }
    
}

extension RegistrationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterCell") as! RegisterCell
        
        if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAProfileImageCell") as! SelectAProfileImageCell
            let tap = UITapGestureRecognizer(target: self, action: #selector(RegistrationViewController.tappedProfileView))
            cell.profileView.addGestureRecognizer(tap)
            profileView = cell.profileView
            cell.selectionStyle = .none
            return cell
        }
    
        if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterJoinCell") as! RegisterJoinCell
            cell.joinShelfButton.addTarget(self, action: #selector(RegistrationViewController.joinShelfButtonPressed(_:)), for: .touchUpInside)
            cell.selectionStyle = .none
            joinShelfButtonView = cell.joinShelfButtonView
            joinShelfButton = cell.joinShelfButton
            return cell
        }
        
        cell.contentOfCell.attributedPlaceholder = createPlaceHolderString(indexPath.row)
        cell.contentOfCell.tag = indexPath.row
        cell.contentOfCell.delegate = self
        
        //cell.titleOfCell.updateAttributedTextWithString(cellTitles[indexPath.row])
        switch indexPath.row {
        case 0 :
            if let name = model.fullName {
                cell.contentOfCell.text = name
            }
            cell.contentOfCell.addTarget(self, action: #selector(RegistrationViewController.fullNameUpdated(_:)), for: .editingChanged)
        case 1:
            if let usrName = model.userName {
                cell.contentOfCell.text = usrName
            }
            cell.contentOfCell.addTarget(self, action: #selector(RegistrationViewController.userNameUpdated(_:)), for: .editingChanged)
        case 2:
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(RegistrationViewController.birthdayUpdated(_:)), for: .valueChanged)
            cell.contentOfCell.inputView = datePicker
            cell.contentOfCell.delegate = self

            birthdayTextField = cell.contentOfCell
            if let birthdayDate = model.birthday {
                parseDate(birthdayDate as Date)
            }
        case 3:
            if let zipCode = model.zipCode {
                cell.contentOfCell.text = zipCode
            }
            cell.contentOfCell.addTarget(self, action: #selector(RegistrationViewController.zipCodeUpdated(_:)), for: .editingChanged)
            cell.contentOfCell.keyboardType = .numberPad
        case 4:
            if let email = model.email {
                cell.contentOfCell.text = email
            }
            cell.contentOfCell.addTarget(self, action: #selector(RegistrationViewController.emailUpdated(_:)), for: .editingChanged)
            cell.contentOfCell.keyboardType = .emailAddress
        case 5:
            if let pw = model.password {
                cell.contentOfCell.text = pw
            }
            cell.contentOfCell.addTarget(self, action: #selector(RegistrationViewController.passwordUpdated(_:)), for: .editingChanged)
            cell.contentOfCell.isSecureTextEntry = true
        case 6:
            if let pw = model.verifyPassword {
                cell.contentOfCell.text = pw
            }
            cell.contentOfCell.addTarget(self, action: #selector(RegistrationViewController.reenterPasswordUpdated(_:)), for: .editingChanged)
            cell.contentOfCell.isSecureTextEntry = true
        default:
            break;
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 7 {
            return 202
        }
        else {
            return 69
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 { //Birthday
            return false
        }else{
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing( _ textField : UITextField){
        textField.resignFirstResponder()
        textField.attributedPlaceholder = createPlaceHolderString(textField.tag)
    }
    

}
