//
//  HomeCell.swift
//  Shelf
//
//  Created by Matthew James on 10/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import ParseUI
class HomeCell: UITableViewCell {
    
    @IBOutlet var lblTitle :UILabel?
    @IBOutlet var lbllikescount :UILabel?
    @IBOutlet var lblchatcount :UILabel?
    @IBOutlet var lblUsername : UILabel?
    @IBOutlet var lblColorName: UILabel!
    @IBOutlet var imgproduct : PFImageView?
    @IBOutlet var imgprofile : PFImageView?
    @IBOutlet var productView: UIView!
    @IBOutlet var regularCell: UIView!
    
    @IBOutlet var flippedOverlay: UIView!
    @IBOutlet var btnLikers: UIButton!
    @IBOutlet var btnComments: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var lblComments: TSLabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var snapshot: UIImageView!
    
    @IBOutlet weak var coatsImage: UIImageView!
    @IBOutlet weak var numberOfCoats: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    
    @IBOutlet weak var commentsTxtView: UIView!

    @IBOutlet weak var commentsTxtViewHeightConstraint: NSLayoutConstraint!
    
    // Details View Properties
    @IBOutlet weak var brandLogo: UIImageView!
    @IBOutlet var btnColorProfile: UIButton!
    @IBOutlet var imgColor: PFImageView!
    @IBOutlet weak var colorTitle: UILabel!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var likeActivityIndicator: UIActivityIndicatorView!
    var borderView : UIView!
    var isLiked = false
    enum BrandName : String {
        case Gelish = "Gelish",
        Zoya = "ZOYA",
        Opi = "OPI",
        Essie = "Essie",
        Shellac = "Shellac"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblTitle?.text = ""
        lbllikescount!.text = ""
        lblchatcount?.text = ""
        lblUsername?.text = ""
        lblColorName.text = ""
        snapshot.isHidden = true
        if let recognizers = gestureRecognizers{
            for recognizer in recognizers  {
                removeGestureRecognizer(recognizer)
            }
        }
        snapshot.tag = 0
        ratingView.isUserInteractionEnabled = false
        bottomView.isHidden = false
        imgprofile?.isHidden = false
        
    }
    
    var doubleTap : UITapGestureRecognizer!
   
    //fill data with color object
    var color : SColor? {
        didSet {
            
            self.imgproduct!.image = UIImage(named: "defaultPhoto")
            self.imgprofile!.image = UIImage(named: "default-post-user-photo")
            
            self.likeButton.layer.cornerRadius = 3
            self.likeButton.layer.masksToBounds = true
            self.commentButton.layer.cornerRadius = 3
            self.commentButton.layer.masksToBounds = true
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
//            self.lblUsername?.text = ""
            
            //dateAgoLabel.text = color?.createdAt!.getTimeAgoAsString(true)
            lbllikescount?.text = String(color!.numLikes)
            lblchatcount?.text = String(color!.numComments)
            lblTitle?.text = color!.comment
            if color!.createdBy != nil {
                color?.createdBy?.fetchIfNeededInBackground(block: { (authorObject, error) -> Void in
                    let author = SUser(dataUser: authorObject!)
                    self.lblUsername?.text = author.firstName + " " + author.lastName
//                    self.imgprofile!.image = UIImage(named: "default-post-user-photo")
                    //Prevents flicker from occuring when image loads
                    UIView.setAnimationsEnabled(false)
                    let pImageView = PFImageView()
                    pImageView.file = author.imageFile
                    pImageView.frame = self.borderView.bounds
                    self.borderView?.addSubview(pImageView)
                    UIView.setAnimationsEnabled(true)
                        pImageView.load(inBackground: { (image, error) -> Void in
    //                        self.imgprofile!.image = image
                        })
                })
            }
            
            // Disable like button interaction until the API call is returned
            likeButton.isUserInteractionEnabled = false
            likeButton.setTitle("", for: UIControlState())
            likeActivityIndicator.isHidden = false
            likeActivityIndicator.startAnimating()
            
            // Like button status
            let query = PFQuery(className: "Like")
            query.whereKey("user", equalTo: PFUser.current()!)
            query.whereKey("color", equalTo: PFObject(withoutDataWithClassName: "Color", objectId: color!.id))
            query.findObjectsInBackground { (response, error) in
                
                // Stop Animating & Hide
                self.likeActivityIndicator.stopAnimating()
                self.likeActivityIndicator.isHidden = true
                self.likeButton.isUserInteractionEnabled = true

                if error == nil {
                    if response?.count == 0 {
                        self.likeButton.setTitle("LIKE", for: UIControlState())
                    } else {
                        self.likeButton.setTitle("UNLIKE", for: UIControlState())
                    }
                } else {
                    self.likeButton.setTitle("LIKE", for: UIControlState())
                }
            }
            
            // Display brand color
            color?.brand_color?.fetchIfNeededInBackground(block: { (brandColor, error) -> Void in
                if error == nil && brandColor != nil {
                    let sBrandColor = SBrandColor(data: brandColor!)
                    
                    // Has brand color image
//                    self.imgColor.hidden = true
                    if sBrandColor.image != nil {
//                        self.imgColor.hidden = false
//                        self.imgColor.alpha = 0
                        self.imgColor.image = nil
                        self.imgColor.file = brandColor!["image"] as? PFFile
						self.imgColor.load(inBackground: { (image, error) in
//                            self.imgColor.image = image
//                            UIView.animateWithDuration(0.2, animations: { () -> Void in
//                                self.imgColor.alpha = 1
//                            })
                        })
                    }
                    // Has no brand color image, use hex values
                    else if sBrandColor.hex != "" {
                        self.imgColor.image = nil
                        self.imgColor.isHidden = false
                        self.imgColor.backgroundColor = UIColor(rgba: sBrandColor.hex)
                    }
                    
                    // Display brand name
                    let trimmed = sBrandColor.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    self.lblColorName.text = trimmed
                    
                    setImageViewFromBrand(brandColor!["brand"] as? String, imgViewBrand: self.brandLogo)
                }
            })
            
            // Title
            let trimmed = color?.colorName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            lblColorName.text = trimmed
            
            // Brand Rating
            if color?.rating != nil {
                if let rating = color?.rating{
                    ratingView.rating = rating
                }
            }
        }
    }
    
    
    // prepare cell gui
    override func awakeFromNib() {
        super.awakeFromNib()
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

        self.ratingView.isUserInteractionEnabled = false

        imgColor.layer.borderColor = UIColor.white.cgColor
    }
}
