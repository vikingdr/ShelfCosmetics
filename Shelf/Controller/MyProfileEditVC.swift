//
//  MyProfileEditVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 24.07.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//



import UIKit
import MobileCoreServices
import Parse
import ParseUI
class MyProfileEditVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //    @IBOutlet weak var lblViewTitle: UILabel!
    @IBOutlet weak var scrollBottomConstrain: NSLayoutConstraint!
    
    @IBOutlet var maxCharLbl: UILabel!
    @IBOutlet var tfUsername: UITextField!
    @IBOutlet weak var tfQuote: UITextView!
    @IBOutlet weak var tfQuoteBg: UIView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var cover: PFImageView!
    @IBOutlet weak var profileImgView: PFImageView!
    var isCoverChanging  = true
    @IBOutlet weak var profileImgViewOverlay: UIView!
    
    @IBOutlet weak var coverShadowView: UIView!
    @IBOutlet var coverWidth: NSLayoutConstraint!
    @IBOutlet var quoteBG: UIImageView!
    @IBOutlet var nameBG: UIImageView!
    @IBOutlet var profileButton: UIButton!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var rightItemView: UIBarButtonItem!
    var switchView: UIView!
    var navSwitch: UISwitch!
    var priPubLabel: UILabel!
    var coverImageChanged = false
    var profileImageChanged = false
    var newName : String?
    var newQuote : String?
    
    
    var bounds = UIScreen.main.bounds
    
    override func viewDidLoad() {
        //        super.viewDidLoad()
        setupNavigationBar()
        
        
        
        //        let title = NSMutableAttributedString(string: "EDIT YOUR PROFILE")
        //        title.addAttribute(NSKernAttributeName, value: 3, range: NSMakeRange(0, title.length))
        //        title.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, title.length))
        //        lblViewTitle.attributedText = title
        
        
        //self.coverWidth.constant = self.view.width
        
        maxCharLbl.text = "100 Characters Max"
        maxCharLbl.textColor = UIColor(red: 255/255, green: 180/255, blue: 109/255, alpha: 1.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileEditVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileEditVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MyProfileEditVC.endEditing)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configUI()
    }
    
    func editedName(){
        newName = tfName.text
    }
    
    func configUI() {
        cover.clipsToBounds = true
        
        profileImgView.layer.cornerRadius = profileImgView.height / 2
        profileImgView.layer.masksToBounds = true
        
        profileImgView.layer.borderColor = UIColor.white.cgColor
        profileImgView.layer.borderWidth = 3.0
        
        profileImgViewOverlay.layer.cornerRadius = profileImgViewOverlay.height / 2
        profileImgViewOverlay.layer.masksToBounds = true
        
        profileButton.titleLabel?.textAlignment = NSTextAlignment.center
        profileButton.layer.cornerRadius = 5
        //profileButton.setTitle("EDIT\nPROFILE\nPHOTO", forState: .Normal)
        
        coverShadowView.layer.shadowColor = UIColor.darkGray.cgColor
        coverShadowView.layer.shadowOffset = CGSize(width: 1, height: 2)
        coverShadowView.layer.shadowOpacity = 0.5
        coverShadowView.layer.shadowRadius = 2.0

        let user = SUser.currentUser
        
        //        var image = self.nameBG!.image
        //        image = image?.resizableImageWithCapInsets(UIEdgeInsetsMake(20, 20, 20, 20), resizingMode: .Stretch)
        //        self.nameBG.image = image
        //
        //        image = self.quoteBG!.image
        //        image = image?.resizableImageWithCapInsets(UIEdgeInsetsMake(20, 20, 20, 20), resizingMode: .Stretch)
        //        self.quoteBG.image = image
        
        
        
        underlined(tfUsername)
        
        tfQuote.text = user.bio
        tfQuoteBg.layer.cornerRadius = 5
        tfQuote.delegate = self
        
        underlined(tfName)
        tfName.text = user.firstName + " " + user.lastName
        tfName.addTarget(self, action: #selector(MyProfileEditVC.editedName), for: .editingChanged)
        
        profileImgView.file = user.imageFile
        profileImgView.load { (image, error) -> Void in
        }
        
        if user.coverImage != nil {
            user.coverImage?.getDataInBackground(block: { (data, error) -> Void in
                if data != nil {
                    self.cover.image = UIImage(data: data!)
                    //self.coverWidth.constant = self.view.width

                }
            })
        }

    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        title = "Edit Profile"
        
        switchView = UIView(frame: CGRect(x: (self.navigationController?.navigationBar.frame.size.width)!-100, y: 10, width: 100, height: 30))
        switchView.backgroundColor = UIColor.clear
        rightItemView = UIBarButtonItem(customView: switchView)
        navigationItem.rightBarButtonItem = rightItemView
        
        
        
        priPubLabel = UILabel(frame: CGRect(x: 0, y: 6, width: 60, height: 20))
        priPubLabel.textAlignment = NSTextAlignment.right
        priPubLabel.text = "PRIVATE"
        priPubLabel.textColor = UIColor.white
        priPubLabel.font = UIFont(name: "Avenir-Black", size: 9)
        switchView.addSubview(priPubLabel)
        
        let navSwitch = UISwitch(frame:CGRect(x: 60,y: 0, width: 0, height: 0))
        navSwitch.isOn = true
        navSwitch.onTintColor = UIColor(red: 82/255, green: 84/255, blue: 107/255, alpha: 1.0)
        navSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        navSwitch.setOn(true, animated: false)
        switchView.addSubview(navSwitch)
        navSwitch.addTarget(self, action: #selector(MyProfileEditVC.switchIsChanged(_:)), for: .valueChanged)
        
    }
    
    
    //
    //    override func setupNavBar() {
    //        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch), forBarMetrics: UIBarMetrics.Default)
    //
    //        let titleImgView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
    //        titleImgView.contentMode = UIViewContentMode.ScaleAspectFit
    //
    //        let titleView = UIView(frame: CGRectMake(0, 0, 55, 44))
    //        titleImgView.frame = titleView.bounds
    //        titleView.addSubview(titleImgView)
    //
    //        self.navigationItem.titleView = titleView;
    //
    //        self.navigationItem.rightBarButtonItem = nil
    //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnBack"), style: .Plain, target: self, action: #selector(BaseVC.backPressed))
    //        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
    //
    //    }
    
    override func backPressed()
    {
        if newName != nil || newQuote != nil || coverImageChanged == true || profileImageChanged == true {
            let user = SUser.currentUser
            let userObject = user.object!
            
            if let fullName = newName {
                let names = fullName.components(separatedBy: " ")
                if names.count > 0 {
                    userObject["firstName"] = names[0]
                    user.firstName = names[0]
                }
                if names.count > 1 {
                    userObject["lastName"] =  tfName.text!.components(separatedBy: " ").last
                    user.lastName = tfName.text!.components(separatedBy: " ").last!
                }
            }
            
            let compressedImageCover = compressImage(cover.image! )
            let compressedImageProfile = compressImage(profileImgView.image!)
            
            let coverImage = PFFile(name: "coverpic.jpg", data: UIImageJPEGRepresentation(UIImage(data: compressedImageCover)!, 1)!)
            let profileImage = PFFile(name: "profilepic.jpg", data: UIImageJPEGRepresentation(UIImage(data: compressedImageProfile)!, 1)!)
            
            if coverImageChanged == true {
                userObject["coverImage"] = coverImage
            }
            
            if profileImageChanged == true {
                userObject["image"] = profileImage
            }
            
            
            if let quote = newQuote {
                userObject["bio"] = quote
                user.bio = quote
            }
            user.imageFile = profileImage
            user.coverImage = coverImage
            
            AppDelegate.showActivity()
            userObject.saveInBackground { (success, error) -> Void in
                AppDelegate.hideActivity()
                self.navigationController?.popViewController(animated: true)
            }
        }else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
    @IBAction func onEditCoverPhoto(_ sender: AnyObject) {
        isCoverChanging = true
        pictureAction()
        
    }
    
    @IBAction func onProfileEdit(_ sender: AnyObject) {
        isCoverChanging = false
        pictureAction()
    }
    
    
    func pictureAction(){
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if isCoverChanging {
            cover.image = info[UIImagePickerControllerEditedImage] as? UIImage
            coverImageChanged = true
        } else {
            profileImgView.image = info[UIImagePickerControllerEditedImage] as? UIImage
            profileImageChanged = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Keyboard methods
    
    func keyboardWillShow (_ notification: Notification){
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            scrollBottomConstrain.constant = endFrame!.size.height - UITabBar.appearance().height
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: {
                                        self.view.layoutIfNeeded()
                                        self.scrollView.contentOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.height)
                },
                                       completion: nil)
        }
        
    }
    
    func keyboardWillHide (_ notification: Notification){
        scrollBottomConstrain.constant = 0
        
    }
    
    /**
     function for public and private switch
     */
    
    func switchIsChanged(_ mySwitch: UISwitch) {
        if mySwitch.isOn {
            mySwitch.onTintColor = UIColor(red: 82/255, green: 84/255, blue: 107/255, alpha: 1.0)
            priPubLabel.text = "PRIVATE"
            print("UISwitch is ON")
        } else {
            mySwitch.tintColor = UIColor(red: 255/255, green: 180/255, blue: 109/255, alpha: 1.0)
            mySwitch.layer.cornerRadius = 16
            mySwitch.backgroundColor = UIColor(red: 255/255, green: 180/255, blue: 109/255, alpha: 1.0)
            priPubLabel.text = "PUBLIC"
            print("UISwitch is OFF")
        }
    }
    
    /**
     for textview to limit characters upto 100 (includes spaces)
     */
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        //        print("character count:: \(updatedText.characters.count)")
        
        
        if updatedText.characters.count == 0{
            maxCharLbl.text = "100 Characters Max"
            maxCharLbl.textColor = UIColor(red: 255/255, green: 180/255, blue: 109/255, alpha: 1.0)
        }
        else{
            maxCharLbl.text = "\(100-updatedText.characters.count + 1) Characters Remaining"
            maxCharLbl.textColor = UIColor.red
        }
        
        return updatedText.characters.count <= 100
    }
    
    
    func underlined(_ textField: UITextField) -> Void {
        let border = CALayer()
        let b_width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        if bounds.size.height == 736.0
        {
            
            print("iphone 6+")
            textField.frame.size.width = bounds.size.width-100
            border.frame = CGRect(x: 0, y: textField.frame.size.height - b_width, width:  textField.frame.size.width, height: textField.frame.size.height)
        }
        else{
            border.frame = CGRect(x: 0, y: textField.frame.size.height - b_width, width:  textField.frame.size.width, height: textField.frame.size.height)
        }
        border.borderWidth = b_width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
}


extension MyProfileEditVC : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        newQuote = tfQuote.text
    }
}

//extension UITextField{
//    func underlined(){
//        let border = CALayer()
//        let width = CGFloat(1.0)
//        border.borderColor = UIColor.lightGrayColor().CGColor
//        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
//        border.borderWidth = width
//        self.layer.addSublayer(border)
//        self.layer.masksToBounds = true
//    }
//}
