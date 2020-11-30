//
//  OrderHistoryCell.swift
//  Shelf
//
//  Created by Matthew James on 11/2/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import ParseUI

let kOrderHistoryCellIdentifier = "OrderHistoryCell"

class OrderHistoryCell: UICollectionViewCell {

    @IBOutlet weak var orderBackgroundClearView: UIView!
    @IBOutlet weak var orderBackgroundView: UIView!
    @IBOutlet weak var orderBottomView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var backProductImageView: UIImageView!
    @IBOutlet weak var orderNumberLabel: ShelfLabel!
    @IBOutlet weak var orderDateLabel: ShelfLabel!
    @IBOutlet weak var productImagesViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Round Product ImageViews
        backProductImageView.roundAndAddDropShadow(6, shadowOpacity: 0.15)
        productView.roundAndAddDropShadow(6, shadowOpacity: 0.15)
        productImageView.layer.cornerRadius = 6
        productImageView.layer.masksToBounds = true
        
        // Round Background View
       // orderBackgroundView.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
       // orderBackgroundView.layer.cornerRadius = 12
       // orderBackgroundView.layer.masksToBounds = true
        orderBackgroundView.layer.shadowColor = UIColor.black.cgColor
        orderBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
        orderBackgroundView.layer.shadowOpacity = 1
        orderBackgroundView.layer.shadowRadius = 1
        orderBackgroundView.alpha = 0.05
        orderBackgroundView.layer.cornerRadius = 12
        
        //orderBackgroundClearView.layer.cornerRadius = 12
        
    }

    override func layoutSubviews() {
        let shape = CAShapeLayer()
        let path = UIBezierPath(roundedRect:orderBackgroundClearView.bounds, byRoundingCorners:[.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 12,height: 12))
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        orderBackgroundClearView.layer.mask = maskLayer

        
        shape.path = UIBezierPath(roundedRect: CGRect(x: orderBottomView.bounds.origin.x, y: orderBottomView.bounds.origin.y, width: contentView.frame.width, height: orderBottomView.bounds.height), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 12, height: 12)).cgPath
        orderBottomView.layer.mask = shape
    }
    
    func updateWithData(_ order: SOrder) {
        if let products = order.products {
            if products.count > 1 {
                productImagesViewWidthConstraint.constant = 61
                backProductImageView.isHidden = false
            }
            else {
                productImagesViewWidthConstraint.constant = 50
                backProductImageView.isHidden = true
            }
            contentView.layoutIfNeeded()
            
            // Display the first product image of the order
            if let imageUrl = products[0].imageUrl {
				// removed by KMHK
//                productImageView.kf_setImageWithURL(URL(string: imageUrl))
				productImageView.setImageWith(URL(string: imageUrl)!)
            }
        }
        
        if let orderId = order.orderId {
            orderNumberLabel.updateAttributedTextWithString("#\(orderId)")
        } else {
            orderNumberLabel.updateAttributedTextWithString("#--")
        }
        
        if let orderDate = order.createdAt {
            orderDateLabel.updateAttributedTextWithString(orderDate.formatDateToShortStyleString())
        } else {
            orderDateLabel.updateAttributedTextWithString("--")
        }
    }
}
