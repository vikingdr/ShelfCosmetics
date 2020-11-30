//
//  MapSuggestionCell.swift
//  Shelf
//
//  Created by Matthew James on 9/20/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class MapSuggestionCell: UITableViewCell {

    @IBOutlet weak var myLocation: UIImageView!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var distance: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        distance.isHidden = false
        milesLabel.isHidden = false
        myLocation.isHidden = true
        
    }
}
