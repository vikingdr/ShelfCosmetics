//
//  CommentsVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 22/07/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

let placeholderText = "Join the conversation..."

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var sendViewLayout: NSLayoutConstraint!

    @IBOutlet weak var bottomView   : UIView!
    @IBOutlet weak var tableView    : UITableView!
    @IBOutlet weak var textBackgroundView: UIView!
    @IBOutlet weak var textView     : UITextView!
    @IBOutlet weak var sendButton   : UIButton!
    
    var needShowKeyboard = false
    var color : SColor!
    var comments : [SComment] = []
    
    //Mark: - lyfeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()
        
        
        
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.clear
        
        textBackgroundView.layer.cornerRadius = 5
        textBackgroundView.clipsToBounds = true
        
        textView.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 0)
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        
        
        sendButton.layer.cornerRadius = 5
        sendButton.clipsToBounds = true
        sendButton.alpha = 0.5
        
        
        
//        AnalyticsHelper.sendScreenView(kScreenCommentsKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needShowKeyboard {
//            textView.becomeFirstResponder()
        }
        reloadData()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    func tapBlurButton(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        textView.resignFirstResponder()
    }
    
    // MARK: -
    
    func setupNavBar() {
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let titleView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 55.0, height: 30.0)
        self.navigationItem.titleView = titleView
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.navigationItem.titleView!.frame.size.width, height: 21))
        label.textAlignment = NSTextAlignment.center
        label.text = "Comment"
        label.textColor=UIColor.white;
        //label.font = label.font.fontWithSize(20)
        label.font = UIFont (name: "Avenir-Heavy", size: 18)
        self.navigationItem.titleView=label
        
        
        // back button
        self.navigationItem.hidesBackButton = true
        let backButton = UIButton(type: UIButtonType.system)
        backButton.frame = CGRect(x: 0, y: 0, width: 10, height: 18)
        backButton.tintColor = UIColor.white
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(CommentsVC.backButtonPressed(_:)), for:.touchUpInside)
        
        let backBarButton:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
    }
    
    
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func reloadData() {
        AppDelegate.showActivity()
        comments = []
        
        let query = PFQuery(className: "Comment")
        query.whereKey("color", equalTo: color.object!)
        query.order(byDescending: "createdAt")
        
        query.findObjectsInBackground { (array, error) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
                if (error == nil)
                {
                    for object in array! {
                        let comment = SComment(data:object)
                        if comment.user != nil {
                            self.comments.append(comment)
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    AppDelegate.hideActivity()
                    self.tableView.reloadData()
//                    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.height)
                })
            })
        }
        
    }
    
    func backButtonPressed(_ sender: AnyObject) {
        textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Buttons
    @IBAction func onSend(_ sender: AnyObject) {
        guard let user = PFUser.current() else {
            return
        }
        let newComment        = SComment()
        newComment.message      = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
        newComment.user         = user
        newComment.color        = self.color
        newComment.updatedAt    = newComment.createdAt
        
        var userTags            = [String]()
        // Check for '@'
        for word: String in textView.text.components(separatedBy: " ") {
            if word.characters.count > 1 && Constants.isStringUserTag(word) {
                userTags.append(word.substring(from: word.characters.index(word.startIndex, offsetBy: 1)))
            }
        }
        
        newComment.userTags = userTags
        
        textView.resignFirstResponder()
        AppDelegate.showActivity()
        newComment.save({ (comment) -> Void in
//            self.comments.append(comment)
            self.comments.insert(comment, at: 0)
            
            DispatchQueue.main.async(execute: {
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
                self.textView.text = placeholderText
                self.color.numComments += 1
                NotificationCenter.default.post(name: Notification.Name(rawValue: "CommentAdd"), object: self.color)
                AppDelegate.hideActivity()
            })
        }, onFailed: { (error) -> Void in
            AppDelegate.hideActivity()
        })
    }
    
    //MARK: - tableView datasource Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 + getCommentLabelHeight(self.comments[indexPath.row].message!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
        cell.backgroundColor = UIColor.clear
        cell.comment = self.comments[indexPath.row]
        
        
        cell.profileImageView.tag = indexPath.row
        cell.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CommentsVC.profileTapped(_:))))
        cell.nameLabel.tag = indexPath.row
        cell.nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CommentsVC.profileTapped(_:))))
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(CommentsVC.profileTapped(_:)))
        profileTap.numberOfTapsRequired = 1
        cell.profileImageView!.tag = indexPath.row
        cell.profileImageView!.isUserInteractionEnabled = true
        cell.profileImageView!.addGestureRecognizer(profileTap)
        
        let userNameTap = UITapGestureRecognizer(target: self, action: #selector(CommentsVC.profileTapped(_:)))
        userNameTap.numberOfTapsRequired = 1
        cell.nameLabel!.tag = indexPath.row
        cell.nameLabel!.isUserInteractionEnabled = true
        cell.nameLabel!.addGestureRecognizer(userNameTap)
        
        if indexPath.row == comments.count - 1 {
            cell.seperatorView.isHidden = true
        }
        
        return cell
    }
    
    //MARK: - textView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
			textView.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholderText
			textView.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let updatedString = textView.text + text
        var isEmptyText = updatedString == ""
        
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        // Check if backspace pressed
        if isBackSpace == -92 {
            // if backspace pressed and there is only one character in the textview,
            // user is deleting that character. Update and disable send button
            if updatedString.characters.count == 1 {
                isEmptyText = true
            }
        }
        
        if !isEmptyText {
            // Enable send button
            sendButton.isUserInteractionEnabled = true
            sendButton.alpha = 1
        } else {
            // Disable send button
            sendButton.isUserInteractionEnabled = false
            sendButton.alpha = 0.5
        }
        
        return true
    }
    
    //MARK: - Keyboard methods
    
    func keyboardWillShow (_ notification: Notification){
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            sendViewLayout.constant = endFrame!.size.height + 7
            UIView.animate(withDuration: duration,
                delay: TimeInterval(0),
                options: animationCurve,
                animations: {
                    self.view.layoutIfNeeded()
//                    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.height)

                },
                completion: nil)
        }
    }
    
    func keyboardWillHide (_ notification: Notification){
        sendViewLayout.constant = 7
    }
    
    //MARK: -
    func profileTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        
        let comment = comments[row!]
        
        do {
            try comment.user!.fetchIfNeeded()
        } catch {
            
        }
        
        let user = SUser(dataUser: comment.user!)
        transitionToProfile(user)
        
    }
    
    func getCommentLabelHeight(_ title: String) -> CGFloat {
        let constraint = CGSize(width: self.tableView!.frame.width - 90.0, height: CGFloat(MAXFLOAT))
        let titleStr: NSString = title as NSString
        
        let rect: CGRect = titleStr.boundingRect(with: constraint, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 10)!], context: nil)
        
        if rect.size.height < 20.0 {
            return 0
        } else {
            return rect.size.height - 20.0
        }
    }
}
