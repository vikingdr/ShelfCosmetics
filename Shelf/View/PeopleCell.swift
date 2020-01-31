//
//  PeopleCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 06.07.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import ParseUI
class PeopleCell: UITableViewCell {
    fileprivate (set) var user : SUser?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var contentImage: PFImageView!
    @IBOutlet var btnFollow: UIImageView!
    @IBOutlet weak var btnFollowing: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentImage?.layer.shadowColor = UIColor.black.cgColor
        self.contentImage?.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.contentImage?.layer.shadowOpacity = 0.32
        self.contentImage?.layer.shadowRadius = 1.0
        self.contentImage?.backgroundColor = UIColor.clear
        
        let borderView = UIView()
        borderView.frame = contentImage!.bounds
        borderView.layer.cornerRadius = contentImage.width / 2
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = 2.0
        borderView.layer.masksToBounds = true
        contentImage!.addSubview(borderView)
        
        contentImage.layer.cornerRadius = contentImage.width / 2
        contentImage.layer.masksToBounds = true
        btnFollowing.isHidden = true
    }
    
    func setSUser(_ newUser : SUser) {
        user = newUser
        
        labelUserName.text = user!.firstName + " " + user!.lastName
        label.text = "@" + user!.username
        
        DispatchQueue.main.async(execute: {
            self.contentImage.image = UIImage(named: "default-post-user-photo")
            self.contentImage.file = self.user?.imageFile
            self.contentImage.loadInBackground()
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
    }
}
