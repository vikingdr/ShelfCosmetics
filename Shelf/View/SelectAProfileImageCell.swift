//
//  SelectAProfileImageCell.swift
//  Shelf
//
//  Created by Matthew James on 11/29/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class SelectAProfileImageCell: UITableViewCell {

    
    @IBOutlet var profileView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        profileView.layer.cornerRadius = profileView.frame.size.height / 2
        profileView.layer.borderColor = UIColor(colorLiteralRed: 255/255, green: 182/255, blue: 96/255, alpha: 65/100).cgColor
        profileView.layer.borderWidth = 1
        
    }

    
}
