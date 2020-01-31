//
//  ColorProfile.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/28/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import ParseUI
class ColorProfileCell: UITableViewCell {
    
    @IBOutlet weak var colorTitle: ShelfLabel!
    @IBOutlet weak var productDescription: ShelfLabel!

    
    @IBOutlet weak var productCode: ShelfLabel!
    @IBOutlet weak var healthRating: UILabel!
    
    @IBOutlet weak var healthInfoButton: UIButton!

    @IBOutlet weak var colorImage: PFImageView!
    @IBOutlet weak var brandImage: UIImageView!
    var topBorder: CALayer!
    var bottomBorder: CALayer!
    override func awakeFromNib() {
        super.awakeFromNib()
        colorImage.layer.cornerRadius = colorImage.frame.height / 2.0
        colorImage.clipsToBounds = true
        
        colorImage.layer.borderColor = UIColor.white.cgColor
        colorImage.layer.borderWidth = 5.0
    }
    
    func updateWithData(_ brandColor: SBrandColor) {
        // Set image
        if let image = brandColor.image {
            colorImage.file = image
            colorImage.load(inBackground: nil)
        }
        // Set HEX color
        else {
            colorImage.backgroundColor = UIColor(rgba: brandColor.hex)
        }
        
        colorTitle.text = brandColor.name
        productDescription.text = brandColor.colorDescription
        setImageViewFromBrand(brandColor.brand, imgViewBrand: brandImage)
        productCode.text = brandColor.code.isEmpty == false ? brandColor.code : "N/A"
    }
}
