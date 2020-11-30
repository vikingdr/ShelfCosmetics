//
//  CommentCell.swift
//  Shelf
//
//  Created by Matthew James on 22/07/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI
class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var dotImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelWidthConstraint: NSLayoutConstraint!
    
    var comment : SComment? {
        didSet {
            let comm = comment!
            descriptionLabel.text   = comm.message
            descriptionLabel.textColor = UIColorFromRGB(0xee748d)
            timeLabel.textColor=UIColorFromRGB(0xf0adb6)
            self.profileImageView.image = UIImage(named: "default-post-user-photo")
            
            // Display brand color
            comm.user?.fetchIfNeededInBackground(block: { (user, error) -> Void in
                if error == nil {
                    
                    let sUser = SUser(dataUser: user)
                    
                    self.nameLabel.text = "@" + sUser.username
                    self.timeLabel.text = comm.createdAt?.getTimeAsString(false)
                    self.timeLabelWidthConstraint.constant = Constants.getWidthForText(self.timeLabel.text!, font: self.timeLabel.font!)
                    
                    if (user != nil) {
                        let author = SUser(dataUser: user as? PFUser)
                        
                        self.profileImageView?.file = author.imageFile
                        self.profileImageView.load(inBackground: { (image, error) -> Void in
                            if self.comment == comm && error == nil {
//                                self.profileImageView.image = image
                            }
                        })
                    }
                }
            })
        }
    }
    
    override func awakeFromNib() {

        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2.0
        profileImageView.clipsToBounds = true

        dotImageView.layer.cornerRadius = dotImageView.frame.width/2
        dotImageView.clipsToBounds = true

    }
}
func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
