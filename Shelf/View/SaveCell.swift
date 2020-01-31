//
//  SaveCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 9/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

class SaveCell: UITableViewCell {

    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveTapped(_ sender: AnyObject) {
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        saveButton.layer.cornerRadius = 5;
        saveButton.layer.masksToBounds = true;
    }
    
}
