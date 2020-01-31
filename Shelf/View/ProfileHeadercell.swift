//
//  ProfileHeadercell.swift
//  Shelf
//
//  Created by Nathan Konrad on 17/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI
class ProfileHeadercell: UICollectionReusableView {
    
    @IBOutlet var imgProfile:PFImageView?
    @IBOutlet weak var lblBadge: UILabel!
    @IBOutlet var btngrid: UIButton!
    @IBOutlet var btnlist: UIButton!
    @IBOutlet var btnFollow: UIButton!
    
    @IBOutlet weak var nickLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var lblFollowing: UILabel!
    
    @IBOutlet weak var lblFollowers: UILabel!
    
    @IBOutlet weak var followerBlueUnder: UIView!
    @IBOutlet weak var followingRedUnder: UIView!
    
    @IBOutlet weak var lblBadgeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblBadgeWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        if lblBadge != nil {
           // lblBadge.layer.cornerRadius = lblBadgeHeightConstraint.constant / 2
             lblBadge.layer.cornerRadius = lblBadge.width / 2
            lblBadge.layer.masksToBounds = true
        }
    }
}
