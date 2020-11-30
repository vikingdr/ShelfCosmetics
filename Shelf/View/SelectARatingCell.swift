//
//  SelectARatingCell.swift
//  Shelf
//
//  Created by Matthew James on 9/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class SelectARatingCell: UITableViewCell {
    
    @IBOutlet weak var rating: RatingView!
    @IBOutlet weak var SelectARating: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let attributedString = SelectARating.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(NSKernAttributeName, value: 4.68, range: NSMakeRange(0, attributedString.length))
        SelectARating.attributedText = attributedString
        rating.allowTouches = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
