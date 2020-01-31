//
//  SettingsCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 06/06/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

let kSettingsCellIdentifier = "SettingsCell"

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var settingsLabel: ShelfLabel!
    @IBOutlet weak var settingsButton: ShelfButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingsButton.layer.shadowColor = UIColor.black.cgColor
        settingsButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        settingsButton.layer.shadowOpacity = 1
        settingsButton.layer.shadowRadius = 1
        settingsButton.layer.cornerRadius = 8
    }

    func updateWithData(_ imageName: String, labelText: String?) {
        settingsIcon.image = UIImage(named: imageName)
        settingsLabel.text = labelText
    }
}
