//
//  OrderDetailsInfoCell.swift
//  Shelf
//
//  Created by Matthew James on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

let kOrderDetailsInfoCellIdentifier = "OrderDetailsInfoCell"

class OrderDetailsInfoCell: UITableViewCell {

    @IBOutlet weak var infoBackgroundView: UIView!
    @IBOutlet weak var orderNumberLabel: ShelfLabel!
    @IBOutlet weak var orderDateLabel: ShelfLabel!
    @IBOutlet weak var subtotalLabel: ShelfLabel!
    @IBOutlet weak var shippingHandlingLabel: ShelfLabel!
    @IBOutlet weak var taxLabel: ShelfLabel!
    @IBOutlet weak var orderTotalLabel: ShelfLabel!
    @IBOutlet weak var shippingAddressLabel: ShelfLabel!
    @IBOutlet weak var shippingMethodLabel: ShelfLabel!
    @IBOutlet weak var paymentLabel: ShelfLabel!
    @IBOutlet weak var promoLabel: ShelfLabel!
    @IBOutlet weak var distributorLabel: ShelfLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        infoBackgroundView.backgroundColor = UIColor.init(white: 1, alpha: 0.05)
    }
    
    override func layoutSubviews() {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: CGRect(x: infoBackgroundView.bounds.origin.x, y: infoBackgroundView.bounds.origin.y, width: contentView.frame.width, height: infoBackgroundView.bounds.height), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
        infoBackgroundView.layer.mask = shape
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWithData(_ shopifyOrder: ShopifyOrder) {
        // Order Number
        if let id = shopifyOrder.id {
            orderNumberLabel.updateAttributedTextWithString(String(format: "#%@", String(id)))
        }
        
        // Order Date
        if let dateString = shopifyOrder.createdAt {
            if let date = dateString.formatStringToDate() {
                orderDateLabel.updateAttributedTextWithString(date.formatDateToShortStyleString())
            }
        }
        
        // Subtotal
        if let subtotal = shopifyOrder.subtotalPrice {
            subtotalLabel.updateAttributedTextWithString(String(format: "$%@", subtotal))
        }
        
        // Shipping & Handling, SHIPPING METHOD
        var shippingHandling: Float = 0.0
        if let shippingLines = shopifyOrder.shippingLines {
            for index in 0..<shippingLines.count {
                let shippingLine = shippingLines[index]
                if index == 0 {
                    if let title = shippingLine.title {
                        shippingMethodLabel.updateAttributedTextWithString(title)
                    }
                }
                
                if let priceString = shippingLine.price {
                    if let price = Float(priceString) {
                        shippingHandling += price
                    }
                }
            }
        }
        if let shippingHandlingText = NSDecimalNumber(value: shippingHandling as Float).currencyFormat {
            shippingHandlingLabel.updateAttributedTextWithString(shippingHandlingText)
        }
        
        // Tax
        if let tax = shopifyOrder.totalTax {
            taxLabel.updateAttributedTextWithString(String(format: "$%@", tax))
        }
        
        // ORDER TOTAL
        if let totalPrice = shopifyOrder.totalPrice {
            orderTotalLabel.updateAttributedTextWithString(String(format: "$%@", totalPrice))
        }
        
        // SHIP TO
        if let shippingAddress = shopifyOrder.shippingAddress {
            var shippingAddressText = ""
            if let address1 = shippingAddress.address1 {
                shippingAddressText = address1
            }
            
            if let address2 = shippingAddress.address2 {
                shippingAddressText = shippingAddressText + " "  + address2
            }
            
            if let city = shippingAddress.city {
                shippingAddressText = shippingAddressText + "\n" + city
            }
            
            if let state = shippingAddress.province {
                shippingAddressText = shippingAddressText + ", " + state
            }
            
            if let zip = shippingAddress.zip {
                shippingAddressText = shippingAddressText + " " + zip
            }
            
            shippingAddressLabel.updateAttributedTextWithString(shippingAddressText)
        }
        
        // PAYMENT
        if let paymentDetails = shopifyOrder.paymentDetails {
            if let creditCardNumber = paymentDetails.creditCardNumber {
                paymentLabel.updateAttributedTextWithString(creditCardNumber)
            }
        }
        
        // PROMO
//        if let discountCodes = shopifyOrder.discountCodes {
//            // TODO:
//        }
        
        // DISTRIBUTOR
        
    }
}
