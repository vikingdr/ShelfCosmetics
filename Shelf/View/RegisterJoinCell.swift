//
//  RegisterJoinCell.swift
//  Shelf
//
//  Created by Matthew James on 12/1/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class RegisterJoinCell: UITableViewCell {

    @IBOutlet var joinShelfButtonView: UIView!
    @IBOutlet var joinShelfButton: ShelfButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        joinShelfButtonView.roundAndAddDropShadow(8, shadowOpacity: 0.0, width: 0, height: 0, shadowRadius: 0)
        joinShelfButtonView.layer.borderWidth = 1.0
        joinShelfButtonView.layer.borderColor = UIColor.white.cgColor
        joinShelfButton.setBackgroundColor(UIColor.init(white: 1, alpha: 0.6), forState: .highlighted)
        joinShelfButton.layer.cornerRadius = 8.0
        joinShelfButton.layer.masksToBounds = true
        joinShelfButton.isUserInteractionEnabled = false
    }

}
