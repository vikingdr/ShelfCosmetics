//
//  ShoppingCartCell.swift
//  Shelf
//
//  Created by Matthew James on 10/25/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import Buy

let kShoppingCartCellIdentifier = "ShoppingCartCell"

class ShoppingCartCell: UITableViewCell {

    @IBOutlet weak var translucentBackgroundImageView: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
 
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var itemCost: ShelfLabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var enclosingView: UIView!
    @IBOutlet weak var imageEnclosingView: UIView!
    @IBOutlet weak var countViewShadow: UIView!
    @IBOutlet weak var numberOfItems: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    var shoppingCartItemUpdated : ((Int?, Bool) -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        enclosingView.layer.cornerRadius = 8
        countView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let shape1 = CAShapeLayer()
        shape1.path = UIBezierPath(roundedRect: productImage.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
        productImage.layer.mask = shape1
        let shape2 = CAShapeLayer()
        shape2.path = UIBezierPath(roundedRect: imageEnclosingView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
        imageEnclosingView.layer.mask = shape2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func updateWithData(_ lineItem: BUYCartLineItem) {
        let variant = lineItem.variant
        let product = variant?.product
        
        productTitle.text = product?.title

        if let imgLink = product?.images.firstObject as? BUYImageLink {
            let url = imgLink.imageURL(with: BUYImageURLSize.size600x600)
			productImage.setImageWith(url)
//            productImage.kf_setImageWithURL(url)
        }
        
        if let price = variant?.price.currencyFormat {
            itemCost.updateAttributedTextWithString(price)
        }
        
        numberOfItems.text = "\(lineItem.quantity)"
    }
    
    @IBAction func minusTapped(_ sender: AnyObject) {
        guard let row = sender.tag else {
            return
        }
        
        let lineItem = BUYCart.sharedCart.mutableLineItemsArray()[row]
        lineItem.decrementQuantity()
        if lineItem.quantity == NSDecimalNumber.zero {
            lineItem.incrementQuantity()
        }
        // Non-zero, update
        else {
            numberOfItems.text = "\(lineItem.quantity)"
            shoppingCartItemUpdated(nil, false)
        }
    }
    
    @IBAction func plusTapped(_ sender: AnyObject) {
        guard let row = sender.tag else {
            return
        }
        
        let lineItem = BUYCart.sharedCart.mutableLineItemsArray()[row]
        lineItem.incrementQuantity()
        numberOfItems.text = "\(lineItem.quantity)"
        shoppingCartItemUpdated(nil, false)
    }
    
    @IBAction func removeButtonPressed(_ sender: AnyObject) {
        guard let row = sender.tag else {
            return
        }
        
        shoppingCartItemUpdated(row, true)
        removeButton.isUserInteractionEnabled = false
    }
}
