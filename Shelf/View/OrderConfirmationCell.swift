//
//  OrderConfirmationCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/26/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import Buy

let kOrderConfirmationCellIdentifier = "OrderConfirmationCell"

class OrderConfirmationCell: UITableViewCell {
    @IBOutlet weak var orderNumberLabel: ShelfLabel!
    @IBOutlet weak var orderTotalLabel: ShelfLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateWithData(_ checkout: BUYCheckout) {
        if let order = checkout.order {
            orderNumberLabel.updateAttributedTextWithString("#\(order.identifier)")
        }
        
        if let totalPrice = checkout.totalPrice.currencyFormat {
            orderTotalLabel.updateAttributedTextWithString(totalPrice)
        }
    }
}
