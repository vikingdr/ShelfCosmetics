//
//  NumberOfCoatsCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 9/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class NumberOfCoatsCell: UITableViewCell {

    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!

    @IBOutlet weak var numberOfCoatsLabel: UILabel!
    @IBOutlet weak var numberOfCoats: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let attributedString = NSAttributedString(string: numberOfCoatsLabel.text!, attributes: [NSKernAttributeName : 4.7])
        
     //   attributedString.addAttribute(NSKernAttributeName, value: 0.6, range: NSMakeRange(0, attributedString.length))
        numberOfCoatsLabel.attributedText = attributedString
    }

}
