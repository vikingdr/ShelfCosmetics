//
//  TrendingListCell.swift
//  Shelf
//
//  Created by Matthew James on 6/24/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI
class TrendingListCell: UICollectionViewCell {
    @IBOutlet var lblTitle :UILabel?
    @IBOutlet var lbllikescount :UILabel?
    @IBOutlet var lblchatcount :UILabel?
    @IBOutlet var lblUsername : TSLabel!
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
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var ratingView: RatingView!
  
    @IBOutlet weak var timeAgo: UILabel!
    @IBOutlet weak var coatsIcon: UIImageView!
    @IBOutlet weak var numberOfCoats: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var lblComments: TSLabel!
    
    @IBOutlet weak var btnCommentsInCommentsView: UIButton!
    @IBOutlet weak var btnLikeInCommentsView: UIButton!
    @IBOutlet weak var likeActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var snapshot: UIImageView!
    
    var doubleTap : UITapGestureRecognizer!
    
    var delegate : TrendingListCellDelegate! = nil
    var isLiked = false
    var borderView : UIView!
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
            self.lblUsername.text = ""
            
            //dateAgoLabel.text = color?.createdAt!.getTimeAgoAsString(true)
            lbllikescount?.text = String(color!.numLikes)
            lblchatcount?.text = String(color!.numComments)
            lblTitle?.text = color!.comment
            lblTitle?.textColor=UIColorFromRGB(0xef7486)
            if color!.createdBy != nil {
                color?.createdBy?.fetchIfNeededInBackground(block: { (authorObject, error) -> Void in
                    let author = SUser(dataUser: authorObject)
                    self.lblUsername.text = author.firstName + " " + author.lastName
//                    self.imgprofile!.image = nil
                    let pImageView = PFImageView()
                    pImageView.file = author.imageFile
                    pImageView.frame = self.borderView.bounds
                    self.borderView?.addSubview(pImageView)
                    //self.imgprofile!.file = author.imageFile
                    pImageView.load(inBackground: { (image, error) -> Void in
//                        self.imgprofile!.image = image
                    })
                })
            }
            
            // Display brand color
//            if color?.brand_color != nil {
//                do {
//                    try color?.brand_color?.fetchIfNeeded()
//                } catch {
//                    
//                }
            
            if color!.brand_color != nil {
                color?.brand_color?.fetchIfNeededInBackground(block: { (brand_color, error) -> Void in
                    let brandColor = SBrandColor(data: brand_color!)
                    
                    // Has brand color image
                    if brandColor.image != nil {
                        self.imgColor.alpha = 0
                        self.imgColor.image = nil
                        self.imgColor.file = brand_color!.object(forKey: "image") as? PFFile
                        self.imgColor.load(inBackground: { (image: UIImage?, error: Error?) -> Void in
//                            self.imgColor.image = image
                            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                                self.imgColor.alpha = 1
                            })
                        })
                    }
                        
                    // Has no brand color image, use hex values
                    else if brandColor.hex != "" {
                        self.imgColor.image = nil
                        self.imgColor.isHidden = false
                        self.imgColor.backgroundColor = UIColor(rgba: brandColor.hex)
                    }
                    
                    // Display brand name
                    self.lblColorName.text = brandColor.name
                    
                    setImageViewFromBrand(brandColor.brand, imgViewBrand: self.imgBrandLogo)
                    
                })
            }
//            }
            
            // Title
            lblTitle!.text = color?.comment
            
            // Brand Rating
            if color?.rating != nil {
                if let rating = color?.rating{
                    ratingView.rating = rating
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgColor.layer.borderColor = UIColor.white.cgColor
        if likeActivityIndicator != nil {
            likeActivityIndicator.isHidden = true
        }
        self.ratingView.isUserInteractionEnabled = false
        
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
        snapshot.isHidden = true
        if let recognizers = gestureRecognizers{
            for recognizer in recognizers  {
                removeGestureRecognizer(recognizer)
            }
        }
    }
    
    //MARK: - Buttons
    
    @IBAction func btnCommentsPressed(_ sender: AnyObject) {
        delegate.trendingListCellBtnCommentPressed(self)
    }
    
    @IBAction func colorDetailsButtonPressed(_ sender: AnyObject) {
        delegate.trendingListCellBtnColorDetailsPressed(self)
    }
}

//MARK: - TrendingListCellDelegate

protocol TrendingListCellDelegate {
    
    func trendingListCellBtnCommentPressed(_ cell : TrendingListCell)
    func trendingListCellBtnColorDetailsPressed(_ cell : TrendingListCell)
}
