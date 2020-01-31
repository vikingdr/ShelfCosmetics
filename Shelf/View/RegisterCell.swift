//
//  RegisterCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/29/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class RegisterCell: UITableViewCell {

    @IBOutlet var separatorView: UIView!
    @IBOutlet var contentOfCell: ShelfTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.frame.size.height = 1
    }
    
    override func prepareForReuse() {
        separatorView.frame.size.height = 1
        contentOfCell.isSecureTextEntry = false
        contentOfCell.isUserInteractionEnabled = true
        contentOfCell.keyboardType = .default
    }

}
