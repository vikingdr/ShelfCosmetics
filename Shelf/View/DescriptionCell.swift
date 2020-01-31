//
//  DescriptionCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 9/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class DescriptionCell: UITableViewCell {

    @IBOutlet weak var textDescription: UITextView!
    let kDescriptionText = "Loving this new shade! \n #autumn #seasonal"
    let kDescriptionTextColor = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 0.15)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textDescription.layer.cornerRadius = 7;
        textDescription.layer.masksToBounds = true;
        
        textDescription.text = "Loving this new shade! \n #autumn #seasonal"
        textDescription.textColor = kDescriptionTextColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textDescription.text = "Loving this new shade! \n #autumn #seasonal"
        textDescription.textColor = kDescriptionTextColor
    }

    
}
