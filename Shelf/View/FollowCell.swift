//
//  FollowCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 6/24/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI

let kFollowCellIdentifier = "FollowCell"
typealias FollowActionAlias = (_ success:Bool, _ followAction: FollowAction) -> Void

enum FollowAction {
    case follow
    case unfollow
}

class FollowCell: UITableViewCell {
    
    @IBOutlet weak var  imgProfile      : PFImageView!
    @IBOutlet var       labelUsername   : UILabel!
    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet var       btnAdd          : UIButton!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var  addIndicatorView: UIActivityIndicatorView!
    
    var     isFollowing : Bool   = false
    var followActionAlias : FollowActionAlias?
    var vc: UIViewController!
    fileprivate var user: PFUser?
    
    override func awakeFromNib() {

        imgProfile.layer.masksToBounds = true

        imgProfile.layer.cornerRadius = 30
        imgProfile.layer.borderColor = UIColor.white.cgColor
        imgProfile.layer.borderWidth = 2.0
        
        imgProfile.layer.shadowColor = UIColor.lightGray.cgColor
        imgProfile.layer.shadowOffset = CGSize(width: 1, height: 3)
        imgProfile.layer.shadowOpacity = 0.7
        imgProfile.layer.shadowRadius = 3.0
        
    }
    
    func updateCellWithUser(_ pfUser: PFUser?, isFollowing: Bool) {
        // Reset to default state for cell
        imgProfile.image = UIImage(named: "default-post-user-photo")
        labelUsername.text = ""
        btnAdd.isHidden = false
        
        guard let pfUser = pfUser else {
            return
        }
        
        //Do Stuff
        user = pfUser
        if let imageFile = pfUser["image"] as? PFFile {
            imgProfile.file = imageFile
            imgProfile.load(inBackground: nil)
        }
        
        let sUser = SUser(dataUser: user)
        
        labelFullName.text = sUser.firstName + " " + sUser.lastName
        labelUsername.text = "@" + sUser.username


        if let currUser = PFUser.current() {
            // Check if the user is not the current user
            guard pfUser.objectId != currUser.objectId else {
                btnAdd.isHidden = true
                return
            }
        }
        
        // Check following for FollowersVC and LikersVC
        guard isFollowing else {
            return
        }
        btnAdd.isSelected = isFollowing
    }
    
    // MARK: - buttons
    
    @IBAction func btnAddPressed(_ sender: AnyObject) {
        guard let user = user else {
            return
        }
        
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        if btnAdd.isSelected {
            SFollow.followTo(user, view: vc.view, completionClosure: { (success) in
                if success == false {
                    // followUser failed, revert add button back to previous state
                    button.isSelected = !self.btnAdd.isSelected
                }
                
                // Invoke callback to display error alert
                if let followActionAlias = self.followActionAlias {
                    followActionAlias(success, .follow)
                }
            })
        } else {
            SFollow.unFollowTo(user, view: vc.view, completionClosure: { (success) in
                if success == false {
                    // unFollowUser failed, revert add button back to previous state
                    button.isSelected = !self.btnAdd.isSelected
                }
                
                // Invoke callback to display error alert
                if let followActionAlias = self.followActionAlias {
                    followActionAlias(success, .unfollow)
                }
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgProfile.image = UIImage(named: "default-post-user-photo")
        labelUsername.text = ""
        btnAdd.isSelected = false
    }
    
    
}
