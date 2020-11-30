//
//  ProfileListCell.swift
//  Shelf
//
//  Created by Matthew James on 17/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import ParseUI
class ProfileListCell: UICollectionViewCell {
    
    @IBOutlet var lblTitle :UILabel?
    @IBOutlet var lbllikescount :UILabel?
    @IBOutlet var lblchatcount :UILabel?
    @IBOutlet var lblUsername : UILabel?
    @IBOutlet weak var lblColorName: UILabel!
    @IBOutlet var imgproduct : PFImageView?
    @IBOutlet var imgprofile : PFImageView?
    @IBOutlet weak var imgBrandLogo: UIImageView!
    @IBOutlet var productView: UIView!
    @IBOutlet var regularCell: UIView!
    @IBOutlet var flippedOverlay: UIView!
    @IBOutlet var btnColorProfile: UIButton!
    @IBOutlet var imgColor: PFImageView!
    @IBOutlet var btnLikers: UIButton!
    @IBOutlet var btnComments: UIButton!
    @IBOutlet weak var ratingView: RatingView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var lblComments: UILabel!
    
    @IBOutlet weak var btnCommentsInCommentsView: UIButton!
    @IBOutlet weak var btnLikeInCommentsView: UIButton!
    @IBOutlet weak var likeActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var snapshotView: UIImageView!
    @IBOutlet weak var coatsIcon: UIImageView!
    @IBOutlet weak var coats: UILabel!
    @IBOutlet weak var timeAgo: UILabel!
    var doubleTap : UITapGestureRecognizer!
    var isLiked = false
    var borderView : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        super.awakeFromNib()
        
        imgColor.layer.borderColor = UIColor.white.cgColor
          self.ratingView.isUserInteractionEnabled = false
        likeActivityIndicator.isHidden = true
        
        self.imgprofile?.layer.shadowColor = UIColor.black.cgColor
        self.imgprofile?.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.imgprofile?.layer.shadowOpacity = 0.32
        self.imgprofile?.layer.shadowRadius = 1.0
        self.imgprofile?.backgroundColor = UIColor.clear
        borderView = UIView()
        borderView.frame = imgprofile!.bounds
        borderView.layer.cornerRadius = 35
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = 2.0
        borderView.layer.masksToBounds = true
        imgprofile!.addSubview(borderView)
        
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.14
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblTitle?.text = ""
        lbllikescount!.text = ""
        lblchatcount?.text = ""
        lblUsername?.text = ""
        lblColorName.text = ""
        if snapshotView != nil {
            snapshotView.isHidden = true
        }
        if let recognizers = gestureRecognizers{
            for recognizer in recognizers  {
                removeGestureRecognizer(recognizer)
            }
        }
    }
    
    //fill data with color object
    var color : SColor? {
        didSet {
            self.imgproduct!.image = UIImage(named: "defaultPhoto")
            self.imgprofile!.image = UIImage(named: "default-post-user-photo")
            
            self.btnLikeInCommentsView.layer.cornerRadius = 3
            self.btnLikeInCommentsView.layer.masksToBounds = true
            self.btnCommentsInCommentsView.layer.cornerRadius = 3
            self.btnCommentsInCommentsView.layer.masksToBounds = true
            
//            self.imgproduct!.image = nil
//            self.imgproduct!.alpha = 0
            self.imgproduct!.file = color!.imageFile
            self.imgproduct!.load(inBackground: { (image, error) -> Void in
//                self.imgproduct!.image = image
//                UIView.animateWithDuration(0.2, animations: { () -> Void in
//                    self.imgproduct!.alpha = 1
//                })
            })
            
            // remove placeholder text from username label
            self.lblUsername?.text = ""
            self.lblTitle?.text = color?.comment
            
           // dateAgoLabel.text = color?.createdAt!.getTimeAgoAsString(true)
            lbllikescount?.text = String(color!.numLikes)
            lblchatcount?.text = String(color!.numComments)
            lblTitle?.text = color!.comment
            if color!.createdBy != nil {
                color?.createdBy?.fetchIfNeededInBackground(block: { (authorObject, error) -> Void in
                    let author = SUser(dataUser: authorObject!)
                    self.lblUsername?.text = author.firstName + " " + author.lastName
//                    self.imgprofile!.image = nil
                    let pImageView = PFImageView()
                    pImageView.file = author.imageFile
                    pImageView.frame = self.borderView.bounds
                    self.borderView!.addSubview(pImageView)

                    self.imgprofile!.load(inBackground: { (image, error) -> Void in
//                        self.imgprofile!.image = image
                    })
                })
            }
            
            // Display brand color
            color?.brand_color?.fetchIfNeededInBackground(block: { (brandColor, error) -> Void in
                if error == nil {
                    let sBrandColor = SBrandColor(data: self.color!.brand_color!)
                    
                    // Has brand color image
                    if sBrandColor.image != nil {
                        self.imgColor.alpha = 0
                        self.imgColor.image = nil
                        self.imgColor.file = brandColor!.object(forKey: "image") as? PFFile
						self.imgColor.load(inBackground: { (image, error) in
//                            self.imgColor.image = image
                            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                                self.imgColor.alpha = 1
                            })
                        })
                    }
                    // Has no brand color image, use hex values
                    else if sBrandColor.hex != "" {
                        self.imgColor.image = nil
                        self.imgColor.isHidden = false
                        self.imgColor.backgroundColor = UIColor(rgba: sBrandColor.hex)
                    }
                    
                    // Display brand name
                    self.lblColorName.text = sBrandColor.name
                    
                    setImageViewFromBrand(sBrandColor.brand, imgViewBrand: self.imgBrandLogo)
                
                }
            })
            
            if color?.rating != nil {
                 if let rating = color?.rating{
                    ratingView.rating = rating
                }
            }
        }
    }
}
