//
//  AddCardCell.swift
//  Shelf
//
//  Created by Matthew James on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class AddCardCell: UICollectionViewCell {
    
    @IBOutlet weak var cardBackgroundClearView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cardBackgroundClearView.layer.shadowColor = UIColor.black.cgColor
        cardBackgroundClearView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardBackgroundClearView.layer.shadowOpacity = 1
        cardBackgroundClearView.layer.shadowRadius = 1
        cardBackgroundClearView.alpha = 0.1
        cardBackgroundClearView.layer.cornerRadius = 12
        // Initialization code
    }

}
