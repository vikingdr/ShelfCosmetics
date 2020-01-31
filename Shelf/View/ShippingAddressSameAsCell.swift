//
//  ShippingAddressSameAsCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/2/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

let kShippingAddressSameAsCellIdentifier = "ShippingAddressSameAsCell"

class ShippingAddressSameAsCell: UITableViewCell {

    @IBOutlet weak var enterNewAddressButton: ShelfButton!
    @IBOutlet weak var shippingSameAsBillingToggle: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
