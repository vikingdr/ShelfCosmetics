//
//  PromoCodeCell.swift
//  Shelf
//
//  Created by Matthew James on 11/1/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

let kPromoCodeCellIdentifier = "PromoCodeCell"

class PromoCodeCell: UITableViewCell {

    @IBOutlet weak var backgroundPromo: UIView!
    @IBOutlet weak var promoCode: UITextView!
    let placeholderText = "Shelf2016"
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundPromo.layer.cornerRadius = 8
        backgroundPromo.layer.masksToBounds = true
        promoCode.text = placeholderText
        promoCode.textColor = UIColor.lightGray
    }
    
}
