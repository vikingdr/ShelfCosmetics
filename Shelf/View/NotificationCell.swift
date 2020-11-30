//
//  NotificationCell.swift
//  Shelf
//
//  Created by Matthew James on 10/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import ParseUI
class NotificationCell: UITableViewCell {
    
    
    @IBOutlet var profileImageView: PFImageView!
    @IBOutlet var lblNotification: TSLabel!
    // @IBOutlet var btnAdd: UIButton!
    
    
    @IBOutlet var btnBlock: UIButton!
    
    @IBOutlet var btnAdd: UIButton!
    @IBOutlet weak var postImageView: PFImageView!
    
    var updateFollowing : ((Bool, Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
        
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2.0
        
        postImageView.layer.masksToBounds = true
        postImageView.layer.cornerRadius = 5.0
        
        
    }
    
    var notification : SNotification? {
        didSet {
            let not = notification!
            
            if (not.fromUser != nil) {
                self.profileImageView!.image = UIImage(named: "default-post-user-photo")
                do {
                    try not.fromUser!.fetchIfNeeded()
                } catch {
                    
                }
                let author = SUser(dataUser: not.fromUser)
                
                let nameFont:UIFont = UIFont(name: "Avenir-Black", size: 11.0)!
                let notificationFont:UIFont = UIFont(name: "Avenir-Black", size: 11.0)!
                
                let nameString = NSMutableAttributedString(string: "@"+author.username)
                nameString.addAttribute(NSLinkAttributeName, value: URL(string: "https://name")!, range: NSMakeRange(0, nameString.length))
                nameString.addAttribute(NSFontAttributeName, value: nameFont, range: NSMakeRange(0, nameString.length))
                
                var notificationString = NSMutableAttributedString()
                
                if not.type == "follow" {
                    notificationString = NSMutableAttributedString(string: " started following you. ")
                    notificationString.addAttribute(NSFontAttributeName, value: notificationFont, range: NSMakeRange(0, notificationString.length))
                    btnAdd.isHidden = false
                    btnBlock.isHidden = false
                    postImageView.isHidden = true
                } else if not.type == "like" || not.type == "mention" {
                    if not.type == "like" {
                        
                    notificationString = NSMutableAttributedString(string: " loved your post. ")
                        
                    }
                    else if not.type == "mention" {
                        var commentText = ""
                        if let comment = not.comment {
                            if let message = comment["message"] as? String {
                               
                                commentText = message
                            }
                        }
                        notificationString = NSMutableAttributedString(string: " mentioned you in a comment: \(commentText) ")
                    }
                    
                    notificationString.addAttribute(NSFontAttributeName, value: notificationFont, range: NSMakeRange(0, notificationString.length))
                    
                    btnAdd.isHidden = true
                    btnBlock.isHidden = true
                    postImageView.isHidden = true
                    
                    if(not.color != nil) {
                        postImageView.isHidden = false
                        postImageView.image = UIImage(named: "default-thumbnail")
                        
                        let color = SColor(data: not.color!)
                        postImageView.file = color.imageFile!
                        postImageView.loadInBackground()
                    }
                }
                
                nameString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 82.0/255.0, green: 83.0/255.0, blue: 110.0/255.0, alpha: 1.0), range: NSMakeRange(0, nameString.length))
       
                 notificationString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 240.0/255.0, green: 116.0/255.0, blue: 137.0/255.0, alpha: 1.0), range: NSMakeRange(0, notificationString.length))
                
                let timeString = NSMutableAttributedString(string: not.createdAt!.getTimeAgoAsString(false))
                timeString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 240.0/255.0, green: 116.0/255.0, blue: 137.0/255.0, alpha: 0.9), range: NSMakeRange(0, timeString.length))
                
                
                
                
                
                
                let text:NSMutableAttributedString = NSMutableAttributedString(attributedString: nameString)
                text.append(notificationString)
                text.append(timeString)
                
                self.lblNotification.attributedText = text
                self.lblNotification.numberOfLines = 3
                self.lblNotification.setLinkAttributes([NSForegroundColorAttributeName: UIColor.shelfTextColor()], for: UIControlState())
                self.lblNotification.setLinkAttributes([NSForegroundColorAttributeName: UIColor.shelfTextColor()], for: .highlighted)
                
                self.btnAdd.isSelected = false
                self.btnBlock.isSelected = false
                for follow in SFollow.currentFollowing() {
                    if follow != nil {
                        if let user = follow!.toUser {
                            if user.objectId == author.objectId {
                                self.btnAdd.isSelected = true
                                btnAdd.isHidden = true
                                btnBlock.isHidden = true
                                break
                            }
                        }
                    }
                }
                
                self.profileImageView!.file = author.imageFile
                self.profileImageView!.load(inBackground: { (image, error) -> Void in
                    if self.notification == not && error == nil {
                        //                                self.profileImageView!.image = image
                    }
                })
            }
        }
    }
    
    @IBAction func onAdd(_ sender: AnyObject) {
        // Update
        btnAdd.isSelected = !btnAdd.isSelected
        if let updateFollowing = self.updateFollowing {
            updateFollowing(self.btnAdd.isSelected, self.btnAdd.tag)
        }
        
        superview?.superview?.isUserInteractionEnabled = false
        if let fromUser = notification?.fromUser {
            if btnAdd.isSelected {
                SFollow.followTo(fromUser, view: superview!, completionClosure : { success in
                    self.superview?.superview?.isUserInteractionEnabled = true
                    guard success == true else {
                        // Follow failed, reset back to previous states
                        self.btnAdd.isSelected = !self.btnAdd.isSelected
                        if let updateFollowing = self.updateFollowing {
                            updateFollowing(self.btnAdd.isSelected, self.btnAdd.tag)
                        }
                        return
                    }
                })
            } else {
                SFollow.unFollowTo(fromUser, view: superview!, completionClosure : { success in
                    self.superview?.superview?.isUserInteractionEnabled = true
                    guard success == true else {
                        // Unfollow failed, reset back to previous states
                        self.btnAdd.isSelected = !self.btnAdd.isSelected
                        if let updateFollowing = self.updateFollowing {
                            updateFollowing(self.btnAdd.isSelected, self.btnAdd.tag)
                        }
                        return
                    }
                })
            }
        }
    }
}
