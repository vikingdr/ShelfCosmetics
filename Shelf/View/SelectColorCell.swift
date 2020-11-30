//
//  SelectColorCell.swift
//  Shelf
//
//  Created by Matthew James on 6/22/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import ParseUI
class SelectColorCell: UITableViewCell {
    @IBOutlet var colorImage: PFImageView!
    @IBOutlet var colorLabel: UILabel!
    
    override func awakeFromNib() {
        colorImage.layer.cornerRadius = colorImage.frame.width / 2
        colorImage.clipsToBounds = true
    }
    
    var brandColor : SBrandColor? {
        didSet {
            let col = brandColor!

            self.colorImage.image = nil
            self.colorImage.alpha = 0
            if (col.image != nil) {
                self.colorImage?.file = col.image
                self.colorImage.load(inBackground: { (image, error) -> Void in
                    if self.brandColor == col && error == nil {
//                        self.colorImage.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.colorImage.alpha = 1
                        })
                    }
                })
            }
            else {
                self.colorImage.backgroundColor = UIColor(rgba: col.hex)
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.colorImage.alpha = 1
                })
            }
        }
    }
    
}
