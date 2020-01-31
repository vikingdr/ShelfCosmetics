//
//  ProfileVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 6/20/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import Parse
import ParseUI
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

class ProfileVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    var headerView : ProfileHeadercell?
    var isGrid : Bool?
    fileprivate let coverHeaderHeight: CGFloat = 139.0
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var coverPhoto: PFImageView!
    var cellStates : [cellState] = []
    var comments: NSMutableDictionary = NSMutableDictionary()
    var singleTap : UITapGestureRecognizer!
    var data : [SColor] = []
    var user : SUser?
    var isFollowing : Bool?
    var row : Int?
//    var updateFollowing : ((Bool, Int) -> ())?
    fileprivate var followersCount : Int?
    fileprivate var followingCount : Int?
    
    enum cellState {
        case normal
        case detail
        case flipped
        case showComments
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kFollowUpdatedNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCommentAdd), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.followUpdated(_:)), name: NSNotification.Name(rawValue: kFollowUpdatedNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileVC.addedComment(_:)), name: NSNotification.Name(rawValue: kCommentAdd), object: nil)
        
        collectionView.register(UINib(nibName: "ProfileListCell", bundle: nil), forCellWithReuseIdentifier: "ProfileListCell")
        isGrid = true
        setupNavBar()
        
//        AnalyticsHelper.sendScreenView(kScreenProfileKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.showActivity()
        if let object = user?.object {
            let query = PFQuery(className: "Color")
            query.whereKey("createdBy", equalTo: object)
            query.order(byDescending: "createdAt")

            self.data = []
            cellStates = []
            
            query.findObjectsInBackground { (array, error) -> Void in
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
                    if (error == nil)
                    {
                        for object in array! {
                            let color = SColor(data:object)
                            self.data.append(color)
                            self.createMapSnapshot(color, width:  self.collectionView!.frame.width - 50.0, completion: nil)
                            
                            self.cellStates.append(cellState.normal)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        AppDelegate.hideActivity()
                        self.collectionView?.reloadData()
                    })
                })
            }
        }
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    func setupNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let titleView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 35.0, height: 30.0)
        self.navigationItem.titleView = titleView
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(ProfileVC.backPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
    }
    
    // MARK:- Actions
    
    override func backPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func listButtonPressed(_ sender: AnyObject) {
        print("listButtonPressed")
        isGrid = false
        collectionView?.reloadData()
    }
    @IBAction func gridButtonPressed(_ sender: AnyObject) {
        print("gridButtonPressed")
        isGrid = true
        collectionView?.reloadData()
    }
    
    func followButtonPressed(_ sender: AnyObject) {
        print("follow button pressed")
        let button = sender as! UIButton
        
        if isFollowing == nil {
            isFollowing = false
        }
        
        if followersCount == nil {
            followersCount = 0
        }
        
        var followTitle = NSMutableAttributedString(string: "FOLLOW")
        button.backgroundColor = UIColor.shelfPink()
        
        if isFollowing! {
            SFollow.unFollowTo(user!.object!, view: view, completionClosure: { (success) in
                // If false, change back to previous state and undo Followers count
                guard success == false else {
                    return
                }
                
                followTitle = NSMutableAttributedString(string: "FOLLOWING")
                button.backgroundColor = UIColor.shelfOrange()
                self.followersCount! += 1

                self.updateFollowStatus(followTitle, button: button)
                let title = "Unfollow User Error"
                let message = "Unable to unfollow user, please try again."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.navigationController?.present(alert, animated: true, completion: nil)
            })
            
            followersCount! -= 1
        } else {
            SFollow.followTo(user!.object!, view: view, completionClosure: { (success) in
                // If false, change back to previous state and undo Followers count
                guard success == false else {
                    return
                }
                
                followTitle = NSMutableAttributedString(string: "FOLLOW")
                button.backgroundColor = UIColor.shelfPink()
                self.followersCount! -= 1

                self.updateFollowStatus(followTitle, button: button)
                let title = "Follow User Error"
                let message = "Unable to follow user, please try again."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.navigationController?.present(alert, animated: true, completion: nil)
            })
            
            followTitle = NSMutableAttributedString(string: "FOLLOWING")
            button.backgroundColor = UIColor.shelfOrange()
            followersCount! += 1
        }
        
        updateFollowStatus(followTitle, button: button)
    }
    
    fileprivate func updateFollowStatus(_ followTitle: NSMutableAttributedString, button: UIButton) {
        followTitle.addAttribute(NSKernAttributeName, value: 5.0, range: NSMakeRange(0, followTitle.length))
        followTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, followTitle.length))
        button.setAttributedTitle(followTitle, for: UIControlState())
        
        isFollowing = !isFollowing!
//        checkForFollowingUpdate(isFollowing)
        guard let headerView = headerView else {
            return
        }
        headerView.lblFollowers.text = "\(followersCount!)"
    }
    
//    func checkForFollowingUpdate( following : Bool? ){
//        if self.updateFollowing != nil {
//            if let follow = following, let usrRow = row{
//                self.updateFollowing!(follow, usrRow)
//            }
//        }
//    }
    
    func productImageTapped(_ gr: UITapGestureRecognizer) {
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        if let snapshot = cell.color?.mapsnapShot {
            cellStates[item!] = cellState.normal
            self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadData()
                }, completion: { (completed) in
                    
                    UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                        cell.snapshotView.image = snapshot
                        cell.snapshotView.contentMode = .scaleAspectFill
                        cell.snapshotView.isHidden = false
                        cell.imgprofile?.isHidden = true
                        cell.flippedOverlay.isHidden = false
                        cell.bottomView.isHidden = true
                        cell.commentsView.isHidden = true
                        //cell.detailsView.hidden = true
                        self.cellStates[item!] = cellState.flipped
                    }) { (finished) -> Void in
                        
                    }
            })
            
        }else{
            UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                cell.flippedOverlay.isHidden = false
                cell.imgprofile?.isHidden = false
                cell.snapshotView.isHidden = true
                cell.bottomView.isHidden = false
                //cell.detailsView.hidden = true
                self.cellStates[item!] = cellState.flipped
            }) { (finished) -> Void in
                
            }
        }
    }
    
    func productImageTappedTwice(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(row: row!, section: 0)) as! ProfileListCell
        likePressed(cell.btnLikers)
    }
    
    func detailsTapped(_ gr: UITapGestureRecognizer) {
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        
        UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
            cell.flippedOverlay.isHidden = false
        //    cell.detailsView.hidden = true
            self.cellStates[item!] = cellState.flipped
            }) { (finished) -> Void in
                
        }
    }
    
    func openLikersVC(_ index: Int) {
        // fetch before opening the VC to make sure the color still exists
        let color = data[index]
        color.object?.fetchInBackground(block: { (object, error) -> Void in
            if error == nil {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: LikersVC = storyboard.instantiateViewController(withIdentifier: "LikersVC") as! LikersVC
                vc.color = color
                let navController = NickNavViewController(rootViewController: vc)
                self.present(navController, animated:true, completion: nil)

            } else {
                if error!._code == 101 {
                    // The color does not exist anymore. i.e it was deleted by user
                    self.data.remove(at: index)
                    self.cellStates.remove(at: index)
                    self.collectionView?.reloadData()
                    
                    let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            }
        })
    }
    
    func likersPressed(_ gr: UITapGestureRecognizer) {
        openLikersVC(gr.view!.tag)
    }
    
    func likePressed(_ sender: UIButton) {
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as! ProfileListCell
        guard let color = cell.color else {
            return
        }
        
        if cell.btnLikeInCommentsView.titleLabel?.text == "LIKE" {
            
            cell.btnLikeInCommentsView.setTitle("", for: UIControlState())
            cell.btnLikeInCommentsView.isUserInteractionEnabled = false
            cell.likeActivityIndicator.isHidden = false
            cell.likeActivityIndicator.startAnimating()
            cell.productView.removeGestureRecognizer(cell.doubleTap)
            
            PFCloud.callFunction(inBackground: kCloudFuncAddLike, withParameters: [kParseKeyColorId: color.objectId!]) { (result, error) in
                cell.btnLikeInCommentsView.isUserInteractionEnabled = true
                cell.likeActivityIndicator.stopAnimating()
                cell.likeActivityIndicator.isHidden = true
                
                guard error == nil, let _ = result else {
                    cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                    cell.productView.addGestureRecognizer(cell.doubleTap)
                    self.singleTap.require(toFail: cell.doubleTap)
                    
                    if let errorLocalized = error?.localizedDescription {
                        let errorData = errorLocalized.data(using: String.Encoding.utf8)
                        do {
                            let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                            if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                if errorCode == 101 {
                                    self.data.remove(at: sender.tag)
                                    self.cellStates.remove(at: sender.tag)
                                    self.collectionView?.reloadData()
                                    
                                    let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                                    alertView.show()
                                }
                                // INVALID_SESSION_TOKEN
                                else if errorCode == kParseErrorCodeInvalidSessionToken {
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
                
                color.object?.fetchInBackground(block: { (colorObject, error) -> Void in
                    guard error == nil, let colorObject = colorObject else {
                        cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                        cell.productView.addGestureRecognizer(cell.doubleTap)
                        self.singleTap.require(toFail: cell.doubleTap)
                        return
                    }
                    
                    let newColor = SColor(data: colorObject)
                    self.data[sender.tag] = newColor
                    cell.lbllikescount?.text = "\(newColor.numLikes)"
                    cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                    cell.productView.addGestureRecognizer(cell.doubleTap)
                    self.singleTap.require(toFail: cell.doubleTap)
                })
            }
        } else {
            
            cell.btnLikeInCommentsView.setTitle("", for: UIControlState())
            cell.btnLikeInCommentsView.isUserInteractionEnabled = false
            cell.likeActivityIndicator.isHidden = false
            cell.likeActivityIndicator.startAnimating()
            cell.productView.removeGestureRecognizer(cell.doubleTap)
            
            PFCloud.callFunction(inBackground: kCloudFuncRemoveLike, withParameters: [kParseKeyColorId: color.objectId!]) { (result, error) in
                cell.btnLikeInCommentsView.isUserInteractionEnabled = true
                cell.likeActivityIndicator.stopAnimating()
                cell.likeActivityIndicator.isHidden = true
                
                guard error == nil, let _ = result else {
                    cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                    cell.productView.addGestureRecognizer(cell.doubleTap)
                    
                    if let errorLocalized = error?.localizedDescription {
                        let errorData = errorLocalized.data(using: String.Encoding.utf8)
                        do {
                            let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                            if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                if errorCode == 101 {
                                    self.data.remove(at: sender.tag)
                                    self.cellStates.remove(at: sender.tag)
                                    self.collectionView?.reloadData()
                                    
                                    let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                                    alertView.show()
                                }
                                // INVALID_SESSION_TOKEN
                                else if errorCode == kParseErrorCodeInvalidSessionToken {
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
                
                color.object?.fetchInBackground(block: { (colorObject, error) -> Void in
                    guard error == nil, let colorObject = colorObject else {
                        cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                        cell.productView.addGestureRecognizer(cell.doubleTap)
                        return
                    }
                    
                    let newColor = SColor(data: colorObject)
                    self.data[sender.tag] = newColor
                    cell.lbllikescount?.text = "\(newColor.numLikes)"
                    cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                    cell.productView.addGestureRecognizer(cell.doubleTap)
                })

                
            }
        }
    }
    
    func openCommentsVC(_ index: Int) {
        // fetch before opening the VC to make sure the color still exists
        let color = data[index]
        color.object?.fetchInBackground(block: { (object, error) -> Void in
            if error == nil {
                let vc: CommentsVC = self.storyboard!.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
                vc.color = color
                let navController = NickNavViewController(rootViewController: vc)
                self.present(navController, animated:true, completion: nil)
            } else {
                if error!._code == 101 {
                    // The color does not exist anymore. i.e it was deleted by user
                    self.data.remove(at: index)
                    self.cellStates.remove(at: index)
                    self.collectionView?.reloadData()
                    
                    let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            }
        })
    }
    
    func commentsPressed(_ gr: UITapGestureRecognizer) {
        openCommentsVC(gr.view!.tag)
    }
    
    func commentButtonPressed(_ sender: UIButton) {
        openCommentsVC(sender.tag)
    }
    
    
    // MARK: - NSNotification
    func addedComment(_ notification: Notification) {
        if let color = notification.object as? SColor {
            let row = colorExistsInArray(color)
            print("ProfileVC addedComment(): colorExistsInArray: \(row) count: \(color.numComments)")
            if row >= 0 {
                data[row] = color
                
                if isGrid == false {
                    collectionView?.performBatchUpdates({
                        self.collectionView?.reloadItems(at: [IndexPath(row: row, section: 0)])
                        }, completion: { (finished: Bool) in
                            
                    })
                }
            }
        }
    }
    
    func followUpdated(_ notification: Notification) {
        print("followUpdated")
        if let userInfo = notification.userInfo {
            let objectId = userInfo["objectId"] as! String
            let following = userInfo["following"] as! Bool
            
            if isFollowing == nil {
                isFollowing = false
            }
            
            if let user = user, let button = headerView?.btnFollow, user.objectId == objectId && isFollowing != following {
                
                var followTitle: NSMutableAttributedString!
                if following == true {
                    followTitle = NSMutableAttributedString(string: "FOLLOWING")
                    button.backgroundColor = UIColor.shelfOrange()
                    followersCount! += 1
                } else {
                    followTitle = NSMutableAttributedString(string: "FOLLOW")
                    button.backgroundColor = UIColor.shelfPink()
                    followersCount! -= 1
                    if followersCount < 0 {
                        followersCount = 0
                    }
                }
                
                updateFollowStatus(followTitle, button: button)
            }
        }
    }
    
    func colorExistsInArray(_ color: SColor) -> Int {
        for i in 0..<data.count {
            if(data[i].objectId == color.objectId) {
                return i
            }
        }
        return -1
    }
    
    func flipBack(_ gr: UITapGestureRecognizer) {
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        cell.snapshotView.isHidden = true
        cell.imgprofile!.isHidden = false
        
        UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
            cell.flippedOverlay.isHidden = true
            self.cellStates[item!] = cellState.normal
            }) { (finished) -> Void in
                
        }
    }
    
    func detailsViewTapped(_ gr: UITapGestureRecognizer) {
        // move nav bar to it's original position
//        animateNavBarTo(STATUS_BAR_HEIGHT)
        
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        showFullColorProfileForColor(cell.color!)
    }
    
    func showColorDetailsView(_ color: SColor) {
		color.object?.fetchInBackground(block: { (object, error) in
            if error == nil {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: ColorDetailsVC = storyboard.instantiateViewController(withIdentifier: "ColorDetailsVC") as! ColorDetailsVC
                vc.color = color
                let navController = NickNavViewController(rootViewController: vc)
                self.present(navController, animated:true, completion: nil)
            } else {
                if error!._code == 101 {
                    // The color does not exist anymore. i.e it was deleted by user
                    let index = self.colorExistsInArray(color)
                    if(index >= 0) {
                        // Deleted color is in array
                        // Remove it from array
                        self.data.remove(at: index)
                        self.cellStates.remove(at: index)
                        self.collectionView?.reloadData()
                        
                        let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                        alertView.show()
                    }
                }
            }
        })
        

    }
    
    func showFullColorProfileForColor(_ color: SColor) {
        let sb = UIStoryboard(name: "ECommerce", bundle: nil)
        let vc: FullColorProfileVC = sb.instantiateViewController(withIdentifier: "FullColorProfileVC") as! FullColorProfileVC
        vc.color = color
        
        let transition: CATransition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        
        let containerView:UIView = self.view.window!
        containerView.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func bottomViewTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag

        if self.cellStates[row!] == cellState.flipped{
            return
        }
        
        
        let color = data[row!]
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: row!, section: 0)) as! ProfileListCell
        
        
        
        // get first 3 comments
        let commentsQuery = PFQuery(className: "Comment")
        commentsQuery.whereKey("color", equalTo: color.object!)
        commentsQuery.includeKey("user")
        commentsQuery.limit = 3
        commentsQuery.order(byAscending: "createdAt")
        
        commentsQuery.findObjectsInBackground { (results, error) -> Void in
            if error == nil {
                print("first 3 comments \(results)")
                let commentsArray: NSMutableArray = NSMutableArray()
                for object in results! {
                    let comment = SComment(data: object)
                    commentsArray.add(comment)
                }
                
                self.comments.setObject(commentsArray, forKey: color.objectId! as NSCopying)
            }
            
            switch self.cellStates[row!] {
            case cellState.showComments:
                self.cellStates[row!] = cellState.normal
            default:
                self.cellStates[row!] = cellState.showComments
            }
            
            UIView.transition(with: cell.commentsView, duration: 0.2, options: UIViewAnimationOptions(), animations: { () -> Void in
                if self.cellStates[row!] != cellState.showComments {
                    cell.commentsView.isHidden = true
                }
                
                self.collectionView?.reloadItems(at: [IndexPath(item: row!, section: 0)])
                }) { (finished) -> Void in
            }
        }
    }
    
    // MARK:- UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: "ProfileHeadercell", for: indexPath)
                as? ProfileHeadercell
            
            // Update current user cover image
            if let file = user!.coverImage {
                coverPhoto.file = file
                coverPhoto.load(inBackground: nil)
            }
            
            let header = headerView!
            
            header.imgProfile?.image = UIImage(named: "default-profile")
            header.imgProfile?.file = user!.imageFile
            header.imgProfile?.load(inBackground: nil)
            
            header.imgProfile?.layer.masksToBounds = true
            header.imgProfile?.layer.cornerRadius = 80
            header.nameLabel.text = user!.firstName + " " + user!.lastName
            header.nickLabel.text = "@" + user!.username
            
            // Followers count
            var followers = "0"
            if let followersCount = followersCount {
                followers = "\(followersCount)"
            } else {
                let followersQuery = PFQuery(className: kClassNameFollow)
                followersQuery.whereKey(kKeyTo, equalTo: (user?.object)!)
				followersQuery.countObjectsInBackground(block: { (count: Int32, error: Error?) in
                    guard error == nil else {
                        return
                    }
                    
                    self.followersCount = Int(count)
                    header.lblFollowers.text = "\(count)"
                })
            }
            header.lblFollowers.text = followers
            
            // Following count
            var following = "0"
            if let followingCount = followingCount {
                following = "\(followingCount)"
            } else {
                let followingQuery = PFQuery(className: kClassNameFollow)
                followingQuery.whereKey(kKeyFrom, equalTo: user!.object!)
				followingQuery.countObjectsInBackground(block: { (count: Int32, error: Error?) in
                    guard error == nil else {
                        return
                    }
                    
                    self.followingCount = Int(count)
                    header.lblFollowing.text = "\(count)"
                })
            }
            header.lblFollowing.text = following
            
            if isGrid == true {
                headerView?.btngrid?.isSelected = true
                headerView?.btnlist?.isSelected = false
            }
            else{
                headerView?.btngrid?.isSelected = false
                headerView?.btnlist?.isSelected = true
            }
            
//            headerView!.btnlist.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            
            headerView!.btngrid.addTarget(self, action: #selector(ProfileVC.gridButtonPressed(_:)), for: .touchUpInside)
            headerView!.btnlist.addTarget(self, action: #selector(ProfileVC.listButtonPressed(_:)), for: .touchUpInside)
            
            // Follow state
            var followTitle = NSMutableAttributedString(string: "FOLLOW")
            if let isFollowing = isFollowing {
                if isFollowing {
                    followTitle = NSMutableAttributedString(string: "FOLLOWING")
                    headerView?.btnFollow.backgroundColor = UIColor.shelfOrange()
                }
            } else {
                let isFollowingQuery = PFQuery(className: kClassNameFollow)
                isFollowingQuery.whereKey(kKeyFrom, equalTo: PFUser.current()!)
                isFollowingQuery.whereKey(kKeyTo, equalTo: user!.object!)
                isFollowingQuery.countObjectsInBackground(block: { (count: Int32, error: Error?) in
                    guard error == nil && count > 0 else {
                        return
                    }
                    
                    self.isFollowing = true
                    followTitle = NSMutableAttributedString(string: "FOLLOWING")
                    followTitle.addAttribute(NSKernAttributeName, value: 3.0, range: NSMakeRange(0, followTitle.length))
                    followTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, followTitle.length))
                    self.headerView?.btnFollow.setAttributedTitle(followTitle, for: UIControlState())
                    self.headerView?.btnFollow.addTarget(self, action: #selector(ProfileVC.followButtonPressed(_:)), for: .touchUpInside)
                    self.headerView?.btnFollow.backgroundColor = UIColor.shelfOrange()
                })
            }
            
            followTitle.addAttribute(NSKernAttributeName, value: 3.0, range: NSMakeRange(0, followTitle.length))
            followTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, followTitle.length))
            headerView?.btnFollow.setAttributedTitle(followTitle, for: UIControlState())
            headerView?.btnFollow.addTarget(self, action: #selector(ProfileVC.followButtonPressed(_:)), for: .touchUpInside)
            
            return headerView! as UICollectionReusableView
            
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        if isGrid == true{
            let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
            collectionViewCell.backgroundColor = UIColor(patternImage: UIImage(named: "bg_profile")!)
            
            let color : SColor = data[indexPath.item]
            collectionViewCell.color = color
//            collectionViewCell.contentImage?.file = color.imageFile
//            collectionViewCell.contentImage?.loadInBackground({ (image, error) -> Void in
//                collectionViewCell.contentImage!.image = image
//            })
            
            return collectionViewCell
        }
        else{
            let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileListCell", for: indexPath) as! ProfileListCell
            collectionViewCell.backgroundColor = UIColor(patternImage: UIImage(named: "bg_profile")!)
            
            collectionViewCell.regularCell.layer.masksToBounds = true
            collectionViewCell.regularCell.layer.cornerRadius = 5
            
            switch cellStates[indexPath.item] {
            case cellState.normal:
              //  collectionViewCell.detailsView.hidden = true
                collectionViewCell.flippedOverlay.isHidden = true
                collectionViewCell.commentsView.isHidden = true
            case cellState.flipped:
                collectionViewCell.flippedOverlay.isHidden = false
            //    collectionViewCell.detailsView.hidden = true
                collectionViewCell.commentsView.isHidden = true
            case cellState.showComments:
              //  collectionViewCell.detailsView.hidden = false
                collectionViewCell.flippedOverlay.isHidden = true
                collectionViewCell.commentsView.isHidden = false
            default:
              //  collectionViewCell.detailsView.hidden = false
                collectionViewCell.flippedOverlay.isHidden = true
                collectionViewCell.commentsView.isHidden = true
            }
            
            let color : SColor = data[indexPath.item]
            
            collectionViewCell.color = color
            
            singleTap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.productImageTapped(_:)))
            singleTap.numberOfTapsRequired = 1
            collectionViewCell.productView.tag = indexPath.item
            collectionViewCell.productView?.isUserInteractionEnabled = true
            collectionViewCell.productView?.addGestureRecognizer(singleTap)
            if collectionViewCell.doubleTap == nil {
                collectionViewCell.doubleTap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.productImageTappedTwice(_:)))
                collectionViewCell.doubleTap.numberOfTapsRequired = 2
                collectionViewCell.productView?.addGestureRecognizer(collectionViewCell.doubleTap)
                singleTap.require(toFail: collectionViewCell.doubleTap)
            }
            
            if let numberOfCoats = color.numberOfCoats{
                var coatsString = ""
                if numberOfCoats == 1 {
                    coatsString = "\(numberOfCoats) coat"
                }else{
                    coatsString = "\(numberOfCoats) coats"
                }
                
                collectionViewCell.coats.text = String(coatsString)
                collectionViewCell.coats.isHidden = false
                collectionViewCell.coatsIcon.isHidden = false
            }else{
                collectionViewCell.coats.isHidden = true
                collectionViewCell.coatsIcon.isHidden = true
            }
            
            if let timePosted = color.createdAt {
                collectionViewCell.timeAgo.text = timePosted.getTimeAgoAsString(true)
            }
            
            
            if let snapshot = color.mapsnapShot {
                let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.showMap(_:)))
                collectionViewCell.snapshotView.addGestureRecognizer(tap)
                collectionViewCell.snapshotView.isUserInteractionEnabled = true
                collectionViewCell.snapshotView.tag = indexPath.row
                
                if cellStates[indexPath.row] == cellState.flipped {
                    collectionViewCell.snapshotView.isHidden = false
                    collectionViewCell.imgprofile?.isHidden = true
                    collectionViewCell.bottomView.isHidden = true
                    collectionViewCell.commentsView.isHidden = true
                    collectionViewCell.snapshotView.image = snapshot
                }
                // Cell is not flipped
                else {
                    collectionViewCell.snapshotView.isHidden = true
                    collectionViewCell.imgprofile?.isHidden = false
                    collectionViewCell.bottomView.isHidden = false
                }
            }
            // No snapshot available
            else {
                collectionViewCell.snapshotView.isHidden = true
                collectionViewCell.imgprofile?.isHidden = false
                collectionViewCell.bottomView.isHidden = false
            }
            
//            let detailsTap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.detailsTapped(_:)))
            singleTap.numberOfTapsRequired = 1
            //collectionViewCell.detailsView.tag = indexPath.item
            //collectionViewCell.detailsView.userInteractionEnabled = true
            //collectionViewCell.detailsView.addGestureRecognizer(detailsTap)
            
            let flipBack = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.flipBack(_:)))
            singleTap.numberOfTapsRequired = 1
            collectionViewCell.flippedOverlay.tag = indexPath.item
            collectionViewCell.flippedOverlay.isUserInteractionEnabled = true
            collectionViewCell.flippedOverlay.addGestureRecognizer(flipBack)
            
            let likersButtonTapped = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.likersPressed(_:)))
            likersButtonTapped.numberOfTapsRequired = 1
            collectionViewCell.btnLikers.tag = indexPath.item
            collectionViewCell.btnLikers.isUserInteractionEnabled = true
            collectionViewCell.btnLikers.addGestureRecognizer(likersButtonTapped)
            
            collectionViewCell.btnLikeInCommentsView.tag = indexPath.row
            collectionViewCell.btnLikeInCommentsView.addTarget(self, action: #selector(ProfileVC.likePressed(_:)), for: .touchUpInside)
            
            let commentsButtonTapped = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.commentsPressed(_:)))
            commentsButtonTapped.numberOfTapsRequired = 1
            collectionViewCell.btnComments.tag = indexPath.item
            collectionViewCell.btnComments.isUserInteractionEnabled = true
            collectionViewCell.btnComments.addGestureRecognizer(commentsButtonTapped)
            
            collectionViewCell.btnCommentsInCommentsView.tag = indexPath.row
            collectionViewCell.btnCommentsInCommentsView.addTarget(self, action: #selector(ProfileVC.commentButtonPressed(_:)), for: .touchUpInside)
            
            let detailsViewTap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.detailsViewTapped(_:)))
            detailsViewTap.numberOfTapsRequired = 1
            collectionViewCell.btnColorProfile.tag = indexPath.item
            collectionViewCell.btnColorProfile.isUserInteractionEnabled = true
            collectionViewCell.btnColorProfile.addGestureRecognizer(detailsViewTap)
            
            let bottomViewTap = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.bottomViewTapped(_:)))
            bottomViewTap.numberOfTapsRequired = 1
            collectionViewCell.bottomView!.tag = indexPath.row
            collectionViewCell.bottomView!.isUserInteractionEnabled = true
            collectionViewCell.bottomView!.addGestureRecognizer(bottomViewTap)
            
            if cellStates[indexPath.row] == cellState.showComments {
                collectionViewCell.lblComments.text = ""
                if let commentsArray: AnyObject = comments.object(forKey: color.objectId!) as AnyObject? {
                    if let commentsArray = commentsArray as? NSMutableArray {
                        if commentsArray.count > 0 {
                            let commentsString = constructCommentsString(commentsArray)
                            collectionViewCell.lblComments.attributedText = commentsString
                        }
                    }
                }
            }
            
            return collectionViewCell
        }
    }
    
    func showMap(_ tap : UITapGestureRecognizer?){
        
        let row = tap?.view!.tag
        let color = data[row!]
        // Do not allow the bottom view to be shown
        let vc = storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vc.geopoint = color.geopoint
        vc.locationName = color.locationName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
        
    }
    
    func getCommentsHeight(_ comments: NSMutableAttributedString) -> CGFloat {
        
        let attributedText = comments as NSAttributedString;
        let width = self.collectionView!.frame.width - 90.0 // 90 is the sum of leading and trailing space
        
        let rect: CGRect = attributedText.boundingRect(with: CGSize(width: CGFloat(width), height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        return rect.size.height
    }
    
    func getColorTitleLabelHeight(_ title: String, showComments: Bool) -> CGFloat {
        let constraint = CGSize(width: self.collectionView!.frame.width - 90.0, height: CGFloat(MAXFLOAT))
        let titleStr: NSString = title as NSString
        
        let rect: CGRect = titleStr.boundingRect(with: constraint, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 13)!], context: nil)
        
        if rect.size.height < 20.0 {
            return 0
        } else {
            if(showComments) {
                return rect.size.height - 20.0
            }
            else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(isGrid!) {
            if self.view.frame.width == 320.0 {
                if indexPath.item % 3 == 1 {
                    return CGSize(width: 106.0, height: 106.0)
                } else {
                    return CGSize(width: 107.0, height: 106.0)
                }
            }
            return CGSize(width: floor(self.view.frame.width/3), height: floor(self.view.frame.width/3))
        }
        
        var productImgViewWidth = self.collectionView!.frame.width - 50.0
        
        let color = data[indexPath.item]
        
        // and add the approximate height of the bottom view plus the cell's view top and bottom padding
        productImgViewWidth += (101 + 16)
        
        productImgViewWidth += getColorTitleLabelHeight(color.comment, showComments: cellStates[indexPath.row] == cellState.showComments)
        
        //show comments if bottom of the cell was tapped
        if cellStates[indexPath.row] == cellState.showComments {
            productImgViewWidth += 44
            
            if let commentsArray: AnyObject = comments.object(forKey: color.objectId!) as AnyObject? {
                print("comments array found! at \(indexPath.row)")
                if let commentsArray = commentsArray as? NSMutableArray {
                    print("comments array count \(commentsArray.count)")
                    if commentsArray.count > 0 {
                        let commentsString = constructCommentsString(commentsArray)
                        let commentsHeight = getCommentsHeight(commentsString)
                        print("commentsHeight \(commentsHeight)")
                        productImgViewWidth += commentsHeight
                    }
                }
            }
        }
        
        return CGSize(width: self.view.frame.width, height: productImgViewWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (isGrid!) {
            showColorDetailsView(data[indexPath.item])
        }
    }
    
    func constructCommentsString(_ comments: NSMutableArray) -> NSMutableAttributedString {
        let commentsString = NSMutableAttributedString()
        
        for comment in comments {
            if let comment = comment as? SComment {
                let userNameString = NSMutableAttributedString(string: "\(comment.user!.username!) ")
                userNameString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 13)!, range: NSRange(location: 0, length: Int((comment.user!.username!).characters.count)))
                userNameString.addAttribute(NSForegroundColorAttributeName, value: UIColor.purple(), range: NSRange(location: 0, length: Int((comment.user!.username!).characters.count)))
                let commentString = NSMutableAttributedString(string: "\(comment.message!)\n")
                commentString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Book", size: 13)!, range: NSRange(location: 0, length: Int((comment.message!).characters.count)))
                
                commentsString.append(userNameString)
                commentsString.append(commentString)
            }
        }
        
        return commentsString
    }
    
    func updateCoverPhoto() {
        var coverRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: coverHeaderHeight)
        if(collectionView?.contentOffset.y < 0) {
            coverRect.size.height -= collectionView!.contentOffset.y
            coverRect.size.width -= collectionView!.contentOffset.y
        }
        coverPhoto.frame = coverRect
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCoverPhoto()
    }
}
