//
//  LocationCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 9/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var selectALocation: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let attributedString = selectALocation.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(NSKernAttributeName, value: 3.4, range: NSMakeRange(0, attributedString.length))
        selectALocation.attributedText = attributedString
    }


}
