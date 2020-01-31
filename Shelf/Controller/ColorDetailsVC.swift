//
//  ColorDetailsVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 6/19/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ColorDetailsVC: UIViewController {

    var color : SColor?
    var doubleTapGesture : UITapGestureRecognizer!
    var detailSingleTap : UITapGestureRecognizer!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var lblTitle :UILabel?
    @IBOutlet var lbllikescount :UILabel?
    @IBOutlet var lblchatcount :UILabel?
    @IBOutlet var lblUsername : UILabel!
    @IBOutlet var imgprofile : PFImageView!
    @IBOutlet var regularCell: UIView!
    @IBOutlet var btnLikers: UIButton!
    @IBOutlet var btnComments: UIButton!
    
    @IBOutlet weak var snapshot: UIImageView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    // Product View
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var imgproduct : PFImageView!
    @IBOutlet weak var postedTimeLabel: UILabel!

    // Overlay View
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var imgViewBrand: UIImageView!
    @IBOutlet weak var imgColor: PFImageView!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var btnColorProfile: UIButton!
    @IBOutlet weak var ratingView: RatingView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerGreaterThanHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var numberOfCoats: UILabel!
    
    @IBOutlet weak var timeAgo: UILabel!
    var isLiked = false
    var isLikeProcessing = false
    var borderView : UIView!
    @IBOutlet weak var likeActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var coatsImage: UIImageView!
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCommentAdd), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        NotificationCenter.default.addObserver(self, selector: #selector(ColorDetailsVC.addedComment(_:)), name: NSNotification.Name(rawValue: kCommentAdd), object: nil)
        
        let leftConstraint = NSLayoutConstraint(item: regularCell, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 25)
        view.addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item: regularCell, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -24)
        view.addConstraint(rightConstraint)
        
        let width = UIScreen.main.bounds.width
        containerHeightConstraint.constant = width - 25 - 24 + 153
        
        //
        self.regularCell.layer.masksToBounds = true
        self.regularCell.layer.cornerRadius = 5
        
        self.likeButton.layer.masksToBounds = true
        self.likeButton.layer.cornerRadius = 3
        
        self.commentButton.layer.masksToBounds = true
        self.commentButton.layer.cornerRadius = 3
        
        //
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
        
        regularCell.layer.shadowOffset = CGSize(width: 1, height: 1)
        regularCell.layer.shadowColor = UIColor.black.cgColor
        regularCell.layer.shadowRadius = 1
        regularCell.layer.shadowOpacity = 0.14
        imgColor.layer.borderColor = UIColor.white.cgColor
        
        self.imgproduct.image = nil
        self.imgproduct.alpha = 0
        self.imgproduct.file = color!.imageFile
        self.imgproduct.load(inBackground: { (image, error) -> Void in
//            self.imgproduct!.image = image
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.imgproduct!.alpha = 1
            })
        })
        
        let detailsViewTap = UITapGestureRecognizer(target: self, action: #selector(ColorDetailsVC.detailsViewTapped(_:)))
        detailsViewTap.numberOfTapsRequired = 1
      
        let overlayViewTap = UITapGestureRecognizer(target: self, action: #selector(ColorDetailsVC.overlayViewTapped(_:)))
        overlayViewTap.numberOfTapsRequired = 1
        overlayView.addGestureRecognizer(overlayViewTap)

        let lblUsernameTap = UITapGestureRecognizer(target: self, action: #selector(ColorDetailsVC.usernameTapped(_:)))
        lblUsernameTap.numberOfTapsRequired = 1
        lblUsername?.addGestureRecognizer(lblUsernameTap)
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(ColorDetailsVC.profileTapped(_:)))
        profileTap.numberOfTapsRequired = 1
        imgprofile!.isUserInteractionEnabled = true
        imgprofile!.addGestureRecognizer(profileTap)
        
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(ColorDetailsVC.overlayViewTappedTwice))
        doubleTapGesture.numberOfTapsRequired = 2
       // overlayView.addGestureRecognizer(doubleTapGesture)
        //verlayViewTap.requireGestureRecognizerToFail(doubleTapGesture)
        productView.addGestureRecognizer(doubleTapGesture)
        
        
        detailSingleTap = UITapGestureRecognizer(target: self, action: #selector(ColorDetailsVC.imgPdtTapped(_:)))
        detailSingleTap.numberOfTapsRequired = 1
        detailSingleTap.require(toFail: doubleTapGesture)
       // overlayView.addGestureRecognizer(detailSingleTap)
        productView.addGestureRecognizer(detailSingleTap)

        //dateAgoLabel.text = color?.createdAt!.getTimeAgoAsString(false)
        lbllikescount?.text = String(color!.numLikes)
        lblchatcount?.text = String(color!.numComments)
        
        self.imgprofile.image = UIImage(named: "default-post-user-photo")
        
        //Dynamically set the height of the comment
        lblTitle?.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblTitle?.text = color!.comment
        lblTitle?.numberOfLines = 0
        lblTitle?.sizeToFit()
        let attr = [ NSFontAttributeName: UIFont(name: "Avenir", size: 13)! ]
        let commentString = NSMutableAttributedString(string: color!.comment, attributes: attr )
        let commentHeight = heightWithConstraintedWidth(231, attrString: commentString)
        containerHeightConstraint.constant = width - 25 - 24 + 153 + (commentHeight - 37)
        
        let preHeight = lblTitle?.height
        lblTitle?.height = estimateTextSize(color!.comment as NSString, width: (lblTitle?.frame.width)!)

        heightConstraint.constant = heightConstraint.constant + estimateTextSize(color!.comment as NSString, width: (lblTitle?.frame.width)!) - preHeight!
        
        if color!.createdBy != nil {
            color?.createdBy?.fetchIfNeededInBackground(block: { (authorObject, error) -> Void in
                let author = SUser(dataUser: authorObject)
                self.lblUsername.text = author.firstName + " " + author.lastName
                //self.imgprofile.alpha = 0
               
                let pImageView = PFImageView()
                pImageView.file = author.imageFile
                pImageView.frame = self.borderView.bounds
                self.borderView?.addSubview(pImageView)
                pImageView.load(inBackground: { (image, error) -> Void in
//                    self.imgprofile.image = image
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        pImageView.alpha = 1
                    })
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
            
            // Enable user interaction
            self.likeButton.isUserInteractionEnabled = true
            
            if error == nil {
                if response?.count == 0 {
                    self.likeButton.setTitle("LIKE", for: UIControlState())
                    self.isLiked = false
                } else {
                    self.likeButton.setTitle("UNLIKE", for: UIControlState())
                    self.isLiked = true
                }
            } else {
                self.likeButton.setTitle("LIKE", for: UIControlState())
                self.isLiked = false
            }
        }
        
        // Brand Rating
        if color?.rating != nil {
            if let rating = color?.rating{
                ratingView.rating = rating
            }
            ratingView.isUserInteractionEnabled = false
        }
        
        if let timePosted = color?.createdAt {
            timeAgo.text = timePosted.getTimeAgoAsString(true)
        }
        if let time = color?.createdAt?.getTimeAgoAsString(true) {
            timeAgo.text = time
        }
        
        if let numberOfCoats = color?.numberOfCoats{
            var coatsString = ""
            if numberOfCoats == 1 {
                coatsString = "\(numberOfCoats) coat"
            }else{
                coatsString = "\(numberOfCoats) coats"
            }
            self.numberOfCoats.text = String(coatsString)
            self.numberOfCoats.isHidden = false
            coatsImage.isHidden = false
        }else{
            self.numberOfCoats.isHidden = true
            coatsImage.isHidden = true
        }
        
        
        // Display brand color
        if color?.brand_color != nil {
            do {
                try color?.brand_color?.fetchIfNeeded()
                let brandColor = SBrandColor(data: color!.brand_color!)
                
                // Display brand
                
//                if brandColor.brand == "Gelish" {
//                    imgViewBrand.image = UIImage(named: "gelishLogo")
//                } else if brandColor.brand == "OPI" {
//                    imgViewBrand.image = UIImage(named: "opiLogo")
//                } else if brandColor.brand == "Essie" {
//                    imgViewBrand.image = UIImage(named: "essieLogo")
//                } else if brandColor.brand == "ZOYA" {
//                    imgViewBrand.image = UIImage(named: "zoyaLogo")
//                } else if brandColor.brand == "Shellac" {
//                    imgViewBrand.image = UIImage(named: "shellacLogo")
//                }
                setImageViewFromBrand(brandColor.brand, imgViewBrand: imgViewBrand)
                
                // Has brand color image
                if brandColor.image != nil {
                    imgColor.alpha = 0
                    imgColor.image = nil
                    imgColor.file = color?.brand_color?.object(forKey: "image") as? PFFile
					imgColor.load(inBackground: { (image: UIImage?, error: Error?) in
                        self.imgColor.image = image
                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
                            self.imgColor.alpha = 1
                        })
                    })
                }
                    // Has no brand color image, use hex values
                else if brandColor.hex != "" {
                    imgColor.image = nil
                    imgColor.isHidden = false
                    imgColor.backgroundColor = UIColor(rgba: brandColor.hex)
                }
                
                // Display color name
                lblname.text = brandColor.name
            } catch {
                print("Brand color was unavailable")
            }
            

        }
        self.createMapSnapshot(color, width:  coverView.frame.width, completion: nil)
        
        if color!.mapsnapShot != nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(ColorDetailsVC.showMap))
            snapshot.addGestureRecognizer(tap)
            snapshot.isUserInteractionEnabled = true
        }
        overlayView.isHidden = true

    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    func showMap(){
        // Do not allow the bottom view to be shown
        let vc = storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vc.geopoint = color!.geopoint
        vc.locationName = color!.locationName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

 
    func heightWithConstraintedWidth(_ width: CGFloat, attrString : NSAttributedString) -> CGFloat {
        let constraintSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = attrString.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.height)
    }
    
    func estimateTextSize( _ text : NSString, width : CGFloat) -> CGFloat{
        let font = UIFont(name: "Avenir-Black", size: 13)
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text as String
        
        label.sizeToFit()
        return label.frame.height
    }
    
    
    func profileTapped(_ gr: UITapGestureRecognizer) {
        do {
            try color!.createdBy!.fetchIfNeeded()
        } catch {
            
        }
        
        let user = SUser(dataUser: color!.createdBy!)
        if (user.objectId != PFUser.current()?.objectId) {
            transitionToProfile(user)
        }
    }
    
    func imgProductTapped(_ sender: UITapGestureRecognizer) {
        
    }
    
    func detailViewTapped(_ sender: UITapGestureRecognizer) {
        
    }
    
    func addedComment(_ notification: Notification) {
        if let updatedColor = notification.object as? SColor {
            print("ColorDetailsVC: addedComment(): count: \(color?.numComments)")
            if updatedColor.objectId == color?.objectId {
                color = updatedColor
                lblchatcount!.text = String(color!.numComments)
            }
        }
    }
    
    func setupNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 45, height: 30))
        label.textAlignment = NSTextAlignment.center
        label.text = "Shelfie"
        label.textColor=UIColor.white;
        //label.font = label.font.fontWithSize(20)
        label.font = UIFont (name: "Avenir-Heavy", size: 18)
        self.navigationItem.titleView=label
        
        // back button
        self.navigationItem.hidesBackButton = true
        let backButton = UIButton(type: UIButtonType.system)
        backButton.frame = CGRect(x: 0, y: 0, width: 10, height: 18)
        backButton.tintColor = UIColor.white
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(ColorDetailsVC.backPressed as (ColorDetailsVC) -> () -> ()), for:.touchUpInside)
        
        let backBarButton:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
    }
    
    override func backPressed() {
        if self.navigationController != nil && self.navigationController!.viewControllers.count > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.contentSize.width = self.view.width
//        NSLog("scrollView.width = \(self.scrollView.width)")
    }
    
    @IBAction func backPressed(_ sender: AnyObject) {
        let transition: CATransition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        
        let containerView:UIView = self.view.window!
        containerView.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: { () -> Void in
            
        })
    }
    
    @IBAction func likersPressed(_ sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: LikersVC = storyboard.instantiateViewController(withIdentifier: "LikersVC") as! LikersVC
        vc.color = color
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func commentsPressed(_ sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: CommentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        vc.color = color
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func likePressed(_ sender: AnyObject) {

        if isLikeProcessing == true {
            return
        }
        isLikeProcessing = true
        
        if isLiked {

            likeButton.isUserInteractionEnabled = false
            let likesCount = Int((lbllikescount?.text!)!)! - 1
            lbllikescount?.text = String(likesCount)
            self.likeButton.setTitle("LIKE", for: UIControlState())
			
			PFCloud.callFunction(inBackground: kCloudFuncRemoveLike, withParameters: [kParseKeyColorId: color!.objectId!], block: { (result: Any?, error: Error?) in
                self.likeButton.isUserInteractionEnabled = true
                self.isLikeProcessing = false
                
                guard error == nil, let result = result as? PFObject else {
                    if let errorLocalized = error?.localizedDescription {
                        let errorData = errorLocalized.data(using: String.Encoding.utf8)
                        do {
                            let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                            if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                // INVALID_SESSION_TOKEN
                                if errorCode == kParseErrorCodeInvalidSessionToken {
                                    if let message = (errorJson as AnyObject).object(forKey: "message") as? String, message == "INVALID_SESSION_TOKEN" {
                                        self.presentParseUserError()
                                    }
                                }
                            }
                        } catch {
                            
                        }
                    }
                    
                    return
                }
                
                self.isLiked = false
                let updatedColor = SColor(data: result)
                self.lbllikescount?.text = "\(updatedColor.numLikes)"
            })
        } else {
            likeButton.isUserInteractionEnabled = false
            let likesCount = Int((lbllikescount?.text!)!)! + 1
            lbllikescount?.text = String(likesCount)
            self.likeButton.setTitle("UNLIKE", for: UIControlState())
			
			PFCloud.callFunction(inBackground: kCloudFuncAddLike, withParameters: [kParseKeyColorId: color!.objectId!], block: { (result: Any?, error: Error?) in
                self.likeButton.isUserInteractionEnabled = true
                self.isLikeProcessing = false
                
                guard error == nil, let result = result as? PFObject else {
                    if let errorLocalized = error?.localizedDescription {
                        let errorData = errorLocalized.data(using: String.Encoding.utf8)
                        do {
                            let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                            if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                // INVALID_SESSION_TOKEN
                                if errorCode == kParseErrorCodeInvalidSessionToken {
                                    if let message = (errorJson as AnyObject).object(forKey: "message") as? String, message == "INVALID_SESSION_TOKEN" {
                                        self.presentParseUserError()
                                    }
                                }
                            }
                        } catch {
                            
                        }
                    }
                    
                    return
                }
                
                self.isLiked = true
                let updatedColor = SColor(data: result)
                self.lbllikescount?.text = "\(updatedColor.numLikes)"
            })
        }
        
    }
    
    @IBAction func commentPressed(_ sender: AnyObject) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: CommentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        vc.color = color
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func fullColorProfileButtonPressed(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "ECommerce", bundle: nil)
        let vc: FullColorProfileVC = sb.instantiateViewController(withIdentifier: "FullColorProfileVC") as! FullColorProfileVC
        vc.color = color
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:-Gestures
    func imgPdtTapped(_ gr: UITapGestureRecognizer) {
        if let snapshot = color!.mapsnapShot {
            UIView.transition(with: regularCell, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                let tap = UITapGestureRecognizer(target: self, action: #selector(ColorDetailsVC.showMap))
                self.snapshot.addGestureRecognizer(tap)
        
                self.snapshot.image = snapshot
                self.snapshot.contentMode = .scaleAspectFill
                self.snapshot.isHidden = false
                self.snapshot.isUserInteractionEnabled = true
                self.imgprofile?.isHidden = true
                self.overlayView.isHidden = false
            }) { (finished) -> Void in
            }
        }else{
            // Animate to overlay view
            UIView.transition(with: regularCell, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                self.overlayView.isHidden = false
                self.imgprofile.isHidden = false
                self.snapshot.isHidden = true
            }) { (finished: Bool) -> Void in
            }
        }
    }
    
    func detailsViewTapped(_ gr: UITapGestureRecognizer) {

    }
    
    func overlayViewTapped(_ gr: UITapGestureRecognizer) {
        UIView.transition(with: regularCell, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                self.overlayView.isHidden = true
                self.snapshot.isHidden = true
                self.imgprofile?.isHidden = false
            }) { (finished: Bool) -> Void in
        }
    }
    
    func usernameTapped(_ gr: UITapGestureRecognizer) {
        let user = SUser(dataUser: color!.createdBy!)
        transitionToProfile(user)
    }
    
    func overlayViewTappedTwice() {
        likePressed(self.likeButton)
    }

}
