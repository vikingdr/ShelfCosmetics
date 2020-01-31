//
//  ProductInfoCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/20/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import Buy
import Kingfisher

let kProductInfoCellIdentifier = "ProductInfoCell"

class ProductInfoCell: UITableViewCell {
    @IBOutlet weak var productImageBackView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var whiteBackgroundOverlayView: UIView!
    @IBOutlet weak var productTitleLabel: ShelfLabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var productPriceLabel: ShelfLabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var productCountLabel: ShelfLabel!
    @IBOutlet weak var productTypeLabel: ShelfLabel!
    @IBOutlet weak var productVendorLabel: ShelfLabel!
    @IBOutlet weak var productDescriptionLabel: ShelfLabel!
    @IBOutlet weak var productIdLabel: ShelfLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Base View
        productImageBackView.layer.shadowColor = UIColor.black.cgColor
        productImageBackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        productImageBackView.layer.shadowOpacity = 0.27
        productImageBackView.layer.shadowRadius = 8
        
        // Border SubView
        
        // ImageView
        productImageView.layer.cornerRadius = 8
        productImageView.layer.masksToBounds = true
        
        whiteBackgroundOverlayView.layer.cornerRadius = 8
        whiteBackgroundOverlayView.layer.masksToBounds = true
        
        productPriceLabel.layer.cornerRadius = 8
        productPriceLabel.layer.borderColor = UIColor(hex: 0xFFB660, alpha: 0.29).cgColor
        productPriceLabel.layer.borderWidth = 1
        productPriceLabel.layer.masksToBounds = true
    }
    
    func updateWithData(_ product: BUYProduct) {
        if let imgLink = product.images.firstObject as? BUYImageLink {
            let url = imgLink.imageURL(with: BUYImageURLSize.size600x600)
			productImageView.setImageWith(url)
//            productImageView.kf_setImageWithURL(url)
        }
        
        productTitleLabel.updateAttributedTextWithString(product.title)
        
        if let price = (product.variants.firstObject as AnyObject).price?.currencyFormat {
            productPriceLabel.updateAttributedTextWithString("PRICE: " + price)
        }
        
        let typeString = "Type: " + product.productType
        productTypeLabel.updateAttributedTextWithString(typeString)
        productTypeLabel.updateAttributedTextWithColorAtRange(UIColor.white, range: NSMakeRange(5, productTypeLabel.attributedText!.length - 5))
        
        let vendorString = "Vendor: " + product.vendor
        productVendorLabel.updateAttributedTextWithString(vendorString)
        productVendorLabel.updateAttributedTextWithColorAtRange(UIColor.white, range: NSMakeRange(7, productVendorLabel.attributedText!.length - 7))
        
        productDescriptionLabel.updateAttributedTextWithString(product.stringDescription)
        
        let idString = "Product ID: \(product.identifier)"
        productIdLabel.updateAttributedTextWithString(idString)
        productIdLabel.updateAttributedTextWithColorAtRange(UIColor.white, range: NSMakeRange(11, productIdLabel.attributedText!.length - 11))
    }
}
