//
//  EditColorCollectionViewCell.swift
//  Shelf
//
//  Created by Matthew James on 11/6/15.
//  Copyright © 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI
class EditColorCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var colorImageView: PFImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var color : SColor? {
        didSet {
            self.colorImageView.image = UIImage(named: "default-thumbnail")
            if(self.color!.thumbnail != nil) {
                self.colorImageView.file = self.color!.thumbnail
            }
            else {
                self.colorImageView.file = self.color!.imageFile
            }
            self.colorImageView.load(inBackground: { (image, error) -> Void in
                if error == nil {
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(patternImage: UIImage(named: "bg_profile")!)
    }
    
    func setSColor(_ color : SColor) {
        self.colorImageView.image = UIImage(named: "default-thumbnail")
        self.colorImageView.file = color.imageFile
        self.colorImageView.loadInBackground()
    }
    
}
