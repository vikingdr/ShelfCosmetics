//
//  ReviewOrderInfoCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/25/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy

let kReviewOrderInfoCellIdentifier = "ReviewOrderInfoCell"

class ReviewOrderInfoCell: UITableViewCell {
    
    @IBOutlet weak var shippingAddressLabel: ShelfLabel!
    @IBOutlet weak var shippingAddressEditButton: UIButton!
    @IBOutlet weak var shippingMethodNameLabel: ShelfLabel!
    @IBOutlet weak var shippingMethodLabel: ShelfLabel!
    @IBOutlet weak var shippingMethodEditButton: UIButton!
    @IBOutlet weak var paymentLabel: ShelfLabel!
    @IBOutlet weak var paymentEditButton: UIButton!
    @IBOutlet weak var promoCodeLabel: ShelfLabel!
    @IBOutlet weak var promoCodeEditButton: UIButton!
    
    @IBOutlet weak var itemsInOrderLabel: ShelfLabel!
    @IBOutlet weak var viewItemsButton: UIButton!
    @IBOutlet weak var subtotalLabel: ShelfLabel!
    @IBOutlet weak var shippingHandlingLabel: ShelfLabel!
    @IBOutlet weak var taxLabel: ShelfLabel!
    @IBOutlet weak var orderTotalLabel: ShelfLabel!
    
    @IBOutlet weak var confirmPurchaseButton: UIButton!
    
    override func awakeFromNib() {
        shippingAddressLabel.updateAttributedTextTextAlignment(.left)
        shippingMethodNameLabel.updateAttributedTextTextAlignment(.left)
    }
    
    func updateWithData(_ checkout: BUYCheckout) {
        // SHIP TO
        if let shippingAddress = checkout.shippingAddress {
            setupShippingInfo(shippingAddress)
        }
        
        // SHIPPING METHOD
        if let shippingRate = checkout.shippingRate {
            shippingMethodLabel.updateAttributedTextWithString(shippingRate.title)
        }
        
        // PAYMENT
        print("creditCard: \(checkout.creditCard)")
//        if let lastDigits = checkout.creditCard.lastDigits {
//            paymentLabel.updateAttributedTextWithString(lastDigits)
//        }
        
        // PROMO
        if let discount = checkout.discount {
            if discount.code.isEmpty == false {
                promoCodeLabel.updateAttributedTextWithString(discount.code)
                promoCodeLabel.alpha = 1
            }
        }
        else {
            promoCodeLabel.updateAttributedTextWithString("No promo code entered")
            promoCodeLabel.alpha = 0.31
        }
        
        // ITEMS IN ORDER (1)
        itemsInOrderLabel.updateAttributedTextWithString("ITEMS IN ORDER (\(BUYCart.sharedCart.mutableLineItemsArray().count))")
        
        // Subtotal
        if let subtotalPrice = checkout.subtotalPrice.currencyFormat {
            subtotalLabel.updateAttributedTextWithString(subtotalPrice)
        }
        
        // Shipping & Handling
        if let shippingPrice = checkout.shippingRate.price.currencyFormat {
            shippingHandlingLabel.updateAttributedTextWithString(shippingPrice)
        }
        
        // Tax
        if let taxPrice = checkout.totalTax.currencyFormat {
            taxLabel.updateAttributedTextWithString("\(taxPrice)")
        }
        
        // ORDER TOTAL
        if let totalPrice = checkout.totalPrice.currencyFormat {
            orderTotalLabel.updateAttributedTextWithString(totalPrice)
        }
    }
    
    fileprivate func setupShippingInfo(_ shippingAddress: BUYAddress) {
        var address = ""
        
        if let address1 = shippingAddress.address1 {
            address = address1
        }
        
        if let address2 = shippingAddress.address2, address2.isEmpty == false {
            address += ", \(address2)"
        }
        
        if let city = shippingAddress.city {
            address += "\n\(city)"
        }
        
        if let state = shippingAddress.provinceCode {
            address += ", \(state)"
        }
        
        if let zip = shippingAddress.zip {
            address += " \(zip)"
        }
        shippingAddressLabel.updateAttributedTextWithString(address)
    }
}
