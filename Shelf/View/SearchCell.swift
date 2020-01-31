//
//  SearchCell.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI
class SearchCell: UICollectionViewCell {

    
    @IBOutlet var contentImage: PFImageView!
    var color : SColor? {
        didSet {
            self.contentImage.image = UIImage(named: "default-thumbnail")
            if(self.color!.thumbnail != nil) {
                self.contentImage.file = self.color!.thumbnail
            }
            else {
                self.contentImage.file = self.color!.imageFile
            }
            self.contentImage.load(inBackground: { (image, error) -> Void in
                if error == nil {
//                    self.contentImage.image = image
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setSColor(_ color : SColor) {
        
//        if(self.contentImage.file == nil) {
            self.contentImage.image = UIImage(named: "default-thumbnail")
//        }
        if let imgFile = color.imageFile {
            self.contentImage.file = imgFile
            self.contentImage.loadInBackground()
        }
//        self.contentImage.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
//            if image != nil && error == nil {
//                let resizedImage = image!.resizeImageToSize(self.contentImage.frame.size)
                
//                self.contentImage.image = resizedImage
//                self.contentImage.alpha = 1
//            }
//        })
    }
    
    func imageIsClicked(_ sender: AnyObject){
       // self.performSegueWithIdentifier("SearchdetailViewController", sender: nil)
    }
    
}
