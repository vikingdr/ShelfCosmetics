//
//  OrderDetailsLineCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit

let kOrderDetailsLineCellIdentifier = "OrderDetailsLineCell"

class OrderDetailsLineCell: UITableViewCell {
    
    @IBOutlet weak var productBackgroundView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productTitleLabel: ShelfLabel!
    @IBOutlet weak var priceLabel: ShelfLabel!
    @IBOutlet weak var quantityLabel: ShelfLabel!

    @IBOutlet weak var productBackgroundViewTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productBackgroundView.backgroundColor = UIColor.init(white: 1, alpha: 0.05)
        
        // Round Product ImageView
        productView.roundAndAddDropShadow(6, shadowOpacity: 0.15)
        productImageView.layer.cornerRadius = 6
        productImageView.layer.masksToBounds = true
        
        productTitleLabel.updateAttributedTextTextAlignment(.left)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(_ isFirst: Bool) {
        let shape = CAShapeLayer()
        if isFirst {
            productBackgroundViewTopConstraint.constant = 29
            contentView.layoutIfNeeded()
            shape.path = UIBezierPath(roundedRect: productBackgroundView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
        } else {
            productBackgroundViewTopConstraint.constant = 0
            contentView.layoutIfNeeded()
            shape.path = UIBezierPath(rect: productBackgroundView.bounds).cgPath
        }
        productBackgroundView.layer.mask = shape
    }

    func updateWithData(_ lineItem: ShopifyLineItem, sOrder: SOrder) {
        if let productId = lineItem.productId, let products = sOrder.products {
            for product in products {
                if let id = product.id, id == String(productId) {
                    if let url = product.imageUrl {
						productImageView.setImageWith(URL(string: url)!)
//                        productImageView.kf_setImageWithURL(URL(string: url))
                        break
                    }
                }
            }
        }
        
        if let title = lineItem.title {
            productTitleLabel.updateAttributedTextWithString(title)
        }
        
        if let price = lineItem.price {
            let priceString = "Price: $" + price
            priceLabel.updateAttributedTextWithString(priceString)
            priceLabel.updateAttributedTextWithColorAtRange(UIColor.white, range: NSMakeRange(6, priceLabel.attributedText!.length - 6))
        }
        
        if let quantity = lineItem.quantity {
            let quantityString = "Qty: \(quantity)"
            quantityLabel.updateAttributedTextWithString(quantityString)
            quantityLabel.updateAttributedTextWithColorAtRange(UIColor.white, range: NSMakeRange(4, quantityLabel.attributedText!.length - 4))
        }
    }
}
