//
//  ShippingMethodCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/26/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

let kShippingMethodCellIdentifier = "ShippingMethodCell"

class ShippingMethodCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var shippingMethodLabel: ShelfLabel!
    @IBOutlet weak var shippingDetailsLabel: ShelfLabel!
    @IBOutlet weak var deliveryLabel: ShelfLabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateWithData(_ shippingOption: ShippingOption) {
        let price = String(format: "$%.2f", shippingOption.price)
        shippingMethodLabel.text = "\(shippingOption.name) \(price)"
        shippingDetailsLabel.text = shippingOption.timeDetail
        deliveryLabel.text = shippingOption.deliveryTime
    }
    
    func setMethodSelected(_ selected: Bool) {
        updateBackgroundImageView(selected)
        shippingMethodLabel.updateAttributedTextWithColor(selected ? UIColor.white : UIColor.init(white: 1.0, alpha: 0.64))
        shippingDetailsLabel.updateAttributedTextWithColor(selected ? UIColor.white : UIColor.init(white: 1.0, alpha: 0.64))
        deliveryLabel.updateAttributedTextWithColor(selected ? UIColor.white : UIColor.init(white: 1.0, alpha: 0.64))
        checkImageView.image = UIImage(named: selected ? "checkSelectedButton" : "checkUnselectedButton")
    }
    
    fileprivate func updateBackgroundImageView(_ selected: Bool) {
        if selected {
            backgroundImageView?.backgroundColor = UIColor(red: 1.0, green: 182.0/255.0, blue: 96.0/255.0, alpha: 1.0)
            backgroundImageView.layer.borderColor = UIColor.clear.cgColor
            backgroundImageView.layer.shadowColor = UIColor.black.cgColor
            backgroundImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
            backgroundImageView.layer.shadowOpacity = 0.17
            backgroundImageView.layer.shadowRadius = 4
        } else {
            backgroundImageView.backgroundColor = UIColor.clear
            backgroundImageView.layer.borderColor = UIColor.init(white: 1.0, alpha: 0.64).cgColor
            backgroundImageView.layer.borderWidth = 1.5
        }
    }
}
