//
//  TrendingVC.swift
//  Shelf
//
//  Created by Matthew James on 6/24/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import FBSDKShareKit
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


let kParseKeyColorId = "colorId"
let kParseErrorCodeInvalidSessionToken = 209

let kCloudFuncAddLike = "addLike"
let kCloudFuncRemoveLike = "removeLike"

class TrendingVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, TrendingListCellDelegate, FBSDKAppInviteDialogDelegate, TSLabelDelegate {
    
    enum cellState {
        
        case normal
        case detail
        case flipped
        case showComments
        
    }
    
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var snapshot: UIImageView!
    
    //@IBOutlet weak var view: UIView!
    
    var scrollFrameHeight:CGFloat?
    var previousContentOffset:CGFloat = 0.0
    let SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
    let SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
    let STATUS_BAR_HEIGHT: CGFloat = UIApplication.shared.statusBarFrame.height
    var tabBarImageFrame : CGRect!
    var navBarFrame : CGRect!
    var tabBarFrame : CGRect!
    
    @IBOutlet var collectionView:UICollectionView?
    var isGrid : Bool?
    var cellStates : [cellState] = []
    var colors : [SColor] = []
    var comments: NSMutableDictionary = NSMutableDictionary()
    
    var additionalColors : [SColor] = []
    var additionalCellStates : [cellState] = []
    var page : Int = 0
    let pageLimit : Int = 15
    var addMoreData : Bool = false
    var queryForReload : PFQuery<PFObject>?
    var refreshControl: UIRefreshControl!
    var isLoading = false
    var isLikeInProgress = false
    // MARK: - View Life cycle methods
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .default
	}
	
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupNavBar()
        collectionView?.backgroundColor = nil
        collectionView?.backgroundView = nil
        collectionView?.scrollsToTop = true
        collectionView?.scrollIndicatorInsets.top = 20.0
        isGrid = true
        
        
        
        var imageViewObject :UIImageView
        
        imageViewObject = UIImageView(frame:CGRect(x: 0, y: 0,width: self.view.frame.size.width, height: 70))
        
        imageViewObject.image = UIImage(named:"Navigationbar")
        
        self.view.addSubview(imageViewObject)
        
        self.view.sendSubview(toBack: imageViewObject)
        
        
        let inset = UIEdgeInsetsMake(0, 0, 30, 0)
        collectionView?.contentInset = inset
        
        // UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(TrendingVC.reloadData), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl)
        
        //This is needed if the collection is not big enough to have an active scrollbar
        collectionView?.alwaysBounceVertical = true;
        
        NotificationCenter.default.addObserver(self, selector: #selector(TrendingVC.reloadData), name: NSNotification.Name(rawValue: "ColorCreated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TrendingVC.colorDeletedSomewhere(_:)), name: NSNotification.Name(rawValue: "colorDeleted"), object: nil)
        reloadData()
//        bringNavBarToOriginal()
        

//    AnalyticsHelper.sendScreenView(kScreenTrendingKey)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        navBarFrame = self.navigationController!.navigationBar.frame
        tabBarFrame = self.tabBarController!.tabBar.frame
        tabBarImageFrame = appDelegate.imagefooter!.frame

    }
    
    func setupNavBar() {
		
		self.navigationController?.navigationBar.backgroundColor = UIColor.white
//        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
		
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 21))
        label.textAlignment = NSTextAlignment.center
        label.text = "Trending"
        label.textColor=UIColor.black
        //label.font = label.font.fontWithSize(20)
        label.font = UIFont (name: "Avenir-Heavy", size: 18)
        self.navigationItem.titleView=label
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnGridSelected"), style: .plain, target: self, action: #selector(TrendingVC.gridButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnListUnselected"), style: .plain, target: self, action: #selector(TrendingVC.listButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        
    }
    
    func inviteFriendsPressed() {
        if FBSDKAppInviteDialog().canShow() {
            let content = FBSDKAppInviteContent()
            content.appLinkURL = URL(string: "https://fb.me/1640480846199078")
            FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
            AnalyticsHelper.sendCustomEvent(kFIREventInvite)
        } else {
            
            let alert = UIAlertView(title: "Facebook Invites Unavailable", message: "It seems like you do not have the appropriate Facebook app installed in order to invite your friends", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
    }
    
    func settingsPressed() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: kSettingsVCIdentifier) as! SettingsVC
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBarHidden = true
//        updateBarButtonItems(1.0)
        
        
    }
    
    func reloadData () {
        
        AppDelegate.showActivity()
        self.page = 0
        
        let date = Date(timeIntervalSinceNow: -7 * 3600 * 24)
        if queryForReload != nil {
        //    queryForReload!.cancel()
        }
        queryForReload = PFQuery(className: "Color")
        queryForReload!.whereKey("createdAt", greaterThan: date)
        queryForReload!.order(byDescending: "numLikes")
        queryForReload!.limit = pageLimit
        queryForReload!.skip = pageLimit * page
        
        self.colors = []
        queryForReload!.findObjectsInBackground { (array, error) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
                if (error == nil)
                {
                   /// dispatch_async(dispatch_get_main_queue(),{
                    self.cellStates = []
                    for object in array! {
                        
                        let color = SColor(data:object)
                        if color.createdBy != nil {
                            self.colors.append(color)
                            self.createMapSnapshot(color, width:  self.collectionView!.frame.width - 50.0, completion: nil)
                            self.cellStates.append(cellState.normal)
                        }
                    }
 
                    
                    self.page += 1
                    
                    if self.colors.count >= self.pageLimit {
                        self.getMoreData()
                        self.addMoreData = true
                    } else {
                        self.addMoreData = false
                    }
 
                    
                }
        
                DispatchQueue.main.async(execute: {
                    AppDelegate.hideActivity()
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                })
            })
        }
    }
    
    func getMoreData() {
        let date = Date(timeIntervalSinceNow: -7 * 3600 * 24)
        let query = PFQuery(className: "Color")
        query.whereKey("createdAt", greaterThan: date)
        query.order(byDescending: "numLikes")
        query.limit = pageLimit
        query.skip = pageLimit * page
        
        query.findObjectsInBackground { (array, error) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
                self.additionalColors = []
                self.additionalCellStates = []

                if (error == nil)
                {
                    for object in array! {
                        let color = SColor(data:object)
                        if color.createdBy != nil {
                            self.additionalColors.append(color)
                            self.additionalCellStates.append(cellState.normal)
                        }
                    }
                    
                    self.page += 1
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func gridButtonPressed(_ sender: AnyObject) {
        isGrid = true
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "btnGridSelected")
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "btnListUnselected")
        collectionView?.reloadData()
    }
    
    @IBAction func listButtonPressed(_ sender: AnyObject) {
        isGrid = false
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "btnGridUnselected2")
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "btnListSelected2")
        collectionView?.reloadData()
    }
    
    func openCommentsVC(_ index: Int) {
        
        // fetch before opening the VC to make sure the color still exists
        let color = colors[index]
        color.object?.fetchInBackground(block: { (object, error) -> Void in
            if error == nil {
                let vc: CommentsVC = self.storyboard!.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
                vc.color = color
                let navController = NickNavViewController(rootViewController: vc)
                self.present(navController, animated:true, completion: nil)
            } else {
                if error!._code == 101 {
                    // The color does not exist anymore. i.e it was deleted by user
                    self.colors.remove(at: index)
                    self.cellStates.remove(at: index)
                    self.collectionView?.reloadData()
                    
                    let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            }
        })
    }
    
    func commentButtonPressed(_ sender: UIButton) {
        openCommentsVC(sender.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            let headerView: TrendingHeaderCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: "TrendingHeaderCell", for: indexPath) as! TrendingHeaderCell
        
            if isGrid == true {
                
                headerView.btnGrid?.isSelected = true
                headerView.btnList?.isSelected = false
            }
            else{
                
                headerView.btnGrid?.isSelected = false
                headerView.btnList?.isSelected = true
            }
            
            
//            var imageViewObject :UIImageView
//            
//            imageViewObject = UIImageView(frame:CGRectMake(0, 0,self.view.frame.size.width, 60))
//            
//            imageViewObject.image = UIImage(named:"Navigationbar")
//            
//            headerView.addSubview(imageViewObject)
            
            
//            headerView.btnList.imageView?.contentMode = UIViewContentMode.Center
//            headerView.btnGrid.imageView?.contentMode = UIViewContentMode.Center
            
            headerView.btnGrid.addTarget(self, action: #selector(TrendingVC.gridButtonPressed(_:)), for: .touchUpInside)
            headerView.btnList.addTarget(self, action: #selector(TrendingVC.listButtonPressed(_:)), for: .touchUpInside)
            
            return headerView as UICollectionReusableView
            
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
            
            if indexPath.row < colors.count {
                
                let color : SColor = colors[indexPath.row]
                collectionViewCell.color = color
                
            }
//            collectionViewCell.contentImage.alpha = 0
//            collectionViewCell.contentImage?.file = color.imageFile
//            collectionViewCell.contentImage?.loadInBackground({ (image, error) -> Void in
//                collectionViewCell.contentImage!.image = image
//                UIView.animateWithDuration(0.2, animations: { () -> Void in
//                    collectionViewCell.contentImage.alpha = 1
//                })
//            })
//            collectionViewCell.contentImage.alpha = 0
//            collectionViewCell.setSColor(color)
            

            return collectionViewCell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingListCell", for: indexPath) as! TrendingListCell
            cell.delegate = self
            cell.lblTitle?.numberOfLines = 0
            cell.regularCell.layer.masksToBounds = true
            cell.regularCell.layer.cornerRadius = 5
            
            switch cellStates[indexPath.row] {
            case cellState.normal:
                cell.flippedOverlay.isHidden = true
                cell.commentsView.isHidden = true
            case cellState.flipped:
                cell.flippedOverlay.isHidden = false
                cell.commentsView.isHidden = true
            case cellState.showComments:
                cell.flippedOverlay.isHidden = true
                cell.commentsView.isHidden = false
            default:
                cell.flippedOverlay.isHidden = true
                cell.commentsView.isHidden = true
            }
            var color : SColor? = nil
            if indexPath.row < colors.count {
                color = colors[indexPath.row]
                cell.color = color
            }
            
            if let snapshot = color?.mapsnapShot {
                let tap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.showMap(_:)))
                cell.snapshot.addGestureRecognizer(tap)
                cell.snapshot.isUserInteractionEnabled = true
                cell.snapshot.tag = indexPath.row
                
                if cellStates[indexPath.row] == cellState.flipped {
                    cell.snapshot.isHidden = false
                    cell.imgprofile?.isHidden = true
                    cell.bottomView.isHidden = true
                    cell.commentsView.isHidden = true
                    cell.snapshot.image = snapshot
                }
                // Cell is not flipped
                else {
                    cell.snapshot.isHidden = true
                    cell.imgprofile?.isHidden = false
                    cell.bottomView.isHidden = false
                }
            }
            // No snapshot available
            else {
                cell.snapshot.isHidden = true
                cell.imgprofile?.isHidden = false
                cell.bottomView.isHidden = false
            }
            
            if let numberOfCoats = color?.numberOfCoats{
                var coatsString = ""
                if numberOfCoats == 1 {
                    coatsString = "\(numberOfCoats) coat"
                }else{
                    coatsString = "\(numberOfCoats) coats"
                }
                cell.numberOfCoats.text = String(coatsString)
                cell.numberOfCoats.isHidden = false
                cell.coatsIcon.isHidden = false
            }else{
                cell.numberOfCoats.isHidden = true
                cell.coatsIcon.isHidden = true
            }
            
            if let timePosted = color?.createdAt {
                cell.timeAgo.text = timePosted.getTimeAgoAsString(true)
            }
            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.productImageTapped(_:)))
            singleTap.numberOfTapsRequired = 1
            cell.productView.tag = indexPath.item
            cell.productView?.isUserInteractionEnabled = true
            cell.productView?.addGestureRecognizer(singleTap)
            if cell.doubleTap != nil {
                cell.productView.removeGestureRecognizer(cell.doubleTap)
            }
            cell.doubleTap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.productImageTappedTwice(_:)))
            cell.doubleTap.numberOfTapsRequired = 2
            cell.productView?.addGestureRecognizer(cell.doubleTap)
            singleTap.require(toFail: cell.doubleTap)
            
            let detailsTap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.detailsTapped(_:)))
            detailsTap.numberOfTapsRequired = 1
           // cell.detailsView.tag = indexPath.row
           // cell.detailsView.userInteractionEnabled = true
           // cell.detailsView.addGestureRecognizer(detailsTap)
        
            let flipBackTap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.flipBack(_:)))
            flipBackTap.numberOfTapsRequired = 1
            cell.flippedOverlay.tag = indexPath.row
            cell.flippedOverlay.isUserInteractionEnabled = true
            cell.flippedOverlay.addGestureRecognizer(flipBackTap)
            
            let likersButtonTap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.likersPressed(_:)))
            likersButtonTap.numberOfTapsRequired = 1
            cell.btnLikers.tag = indexPath.row
            cell.btnLikers.isUserInteractionEnabled = true
            cell.btnLikers.addGestureRecognizer(likersButtonTap)
            
            cell.btnLikeInCommentsView.tag = indexPath.row
            cell.btnLikeInCommentsView.addTarget(self, action: #selector(TrendingVC.likePressed(_:)), for: .touchUpInside)
            
            cell.backgroundColor = UIColor.clear
            
            
            cell.imgprofile?.layer.shadowColor = UIColor.black.cgColor
            cell.imgprofile?.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.imgprofile?.layer.shadowOpacity = 0.32
            cell.imgprofile?.layer.shadowRadius = 1.0
            cell.imgprofile?.backgroundColor = UIColor.clear
            cell.borderView = UIView()
            cell.borderView.frame = cell.imgprofile!.bounds
            cell.borderView.layer.cornerRadius = 35
            cell.borderView.layer.borderColor = UIColor.white.cgColor
            cell.borderView.layer.borderWidth = 2.0
            cell.borderView.layer.masksToBounds = true
            cell.imgprofile!.addSubview(cell.borderView)
            //cell.imgprofile!.layer.masksToBounds = true
            /*
            cell.imgprofile?.layer.masksToBounds = true
            cell.imgprofile?.layer.cornerRadius = 35
            cell.imgprofile?.layer.borderWidth = 2
            cell.imgprofile?.layer.borderColor = UIColor.whiteColor().CGColor
            */
            
            cell.btnCommentsInCommentsView.tag = indexPath.row
            cell.btnCommentsInCommentsView.addTarget(self, action: #selector(TrendingVC.commentButtonPressed(_:)), for: .touchUpInside)
            
//            let detailsViewTap = UITapGestureRecognizer(target: self, action: Selector("detailsViewTapped:"))
//            detailsViewTap.numberOfTapsRequired = 1
//            cell.btnColorProfile.tag = indexPath.row
//            cell.btnColorProfile.userInteractionEnabled = true
//            cell.btnColorProfile.addGestureRecognizer(detailsViewTap)
            
            let profileTap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.profileTapped(_:)))
            profileTap.numberOfTapsRequired = 1
            cell.imgprofile!.tag = indexPath.row
            cell.imgprofile!.isUserInteractionEnabled = true
            cell.imgprofile!.addGestureRecognizer(profileTap)
            
            let userNameTap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.profileTapped(_:)))
            userNameTap.numberOfTapsRequired = 1
            cell.lblUsername!.tag = indexPath.row
            cell.lblUsername!.isUserInteractionEnabled = true
            cell.lblUsername!.addGestureRecognizer(userNameTap)
            
            let bottomViewTap = UITapGestureRecognizer(target: self, action: #selector(TrendingVC.bottomViewTapped(_:)))
            bottomViewTap.numberOfTapsRequired = 1
            cell.bottomView!.tag = indexPath.row
            cell.bottomView!.isUserInteractionEnabled = true
            cell.bottomView!.addGestureRecognizer(bottomViewTap)
            
            if cellStates[indexPath.row] == cellState.showComments {
                cell.lblComments.text = ""
                if color != nil{
                if let commentsArray: AnyObject = comments.object(forKey: color!.objectId!) as AnyObject? {
                    if let commentsArray = commentsArray as? NSMutableArray {
                        if commentsArray.count > 0 {
                            cell.lblComments.tag = indexPath.row
                            cell.lblComments.delegate = self
                            let commentsString = constructCommentsString(commentsArray)
                            cell.lblComments.attributedText = commentsString
                            cell.lblComments.setLinkAttributes([NSForegroundColorAttributeName: UIColor.purple(), NSFontAttributeName: UIFont(name: "Avenir-Black", size: 13)!], for: UIControlState())
                            cell.lblComments.setLinkAttributes([NSForegroundColorAttributeName: UIColor.purple(), NSFontAttributeName: UIFont(name: "Avenir-Black", size: 13)!], for: .highlighted)
                        }
                    }
                }
            }
        }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.isGrid == true) {
            let cell : SearchCell = collectionView.cellForItem(at: indexPath) as! SearchCell
            self.showColorDetailsForColor(cell.color!)
        }
    }
    
    func bottomViewTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let color = colors[row!]
        let cell: TrendingListCell = collectionView?.cellForItem(at: IndexPath(item: row!, section: 0)) as! TrendingListCell
        
        if self.cellStates[row!] == cellState.flipped && color.mapsnapShot != nil {
            // Do not allow the bottom view to be shown
            let vc = storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
            vc.geopoint = color.geopoint
            vc.locationName = color.locationName
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if self.cellStates[row!] == cellState.flipped{
            return
        }
        
        
        // get first 3 comments
        let commentsQuery = PFQuery(className: "Comment")
        commentsQuery.whereKey("color", equalTo: color.object!)
        commentsQuery.includeKey("user")
        commentsQuery.limit = 3
        commentsQuery.order(byDescending: "createdAt")
        
        commentsQuery.findObjectsInBackground { (results, error) -> Void in
            if error == nil {
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
    
    func productImageTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let cell: TrendingListCell = collectionView?.cellForItem(at: IndexPath(row: row!, section: 0)) as! TrendingListCell
        cell.productView.removeGestureRecognizer(cell.doubleTap)
        if let snapshot = cell.color?.mapsnapShot {
            cellStates[row!] = cellState.normal
            UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                cell.snapshot.image = snapshot
                cell.snapshot.contentMode = .scaleAspectFill
                cell.snapshot.isHidden = false
                cell.imgprofile?.isHidden = true
                cell.flippedOverlay.isHidden = false
                cell.bottomView.isHidden = true
                cell.commentsView.isHidden = true
                //cell.detailsView.hidden = true
                self.cellStates[row!] = cellState.flipped
            }) { (finished) -> Void in
                
            }
        }else {
            UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                cell.flippedOverlay.isHidden = false
                cell.imgprofile?.isHidden = false
                cell.snapshot.isHidden = true
                cell.bottomView.isHidden = false
                //cell.detailsView.hidden = true
                self.cellStates[row!] = cellState.flipped
            }) { (finished) -> Void in
                
            }
        }
    }
    
    func productImageTappedTwice(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let cell: TrendingListCell = collectionView?.cellForItem(at: IndexPath(row: row!, section: 0)) as! TrendingListCell
        likePressed(cell.btnLikeInCommentsView)
    }
    
    func detailsTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let cell: TrendingListCell = collectionView?.cellForItem(at: IndexPath(row: row!, section: 0)) as! TrendingListCell
        
           if let snapshot = cell.color?.mapsnapShot {
            cellStates[row!] = cellState.normal
            UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                cell.snapshot.image = snapshot
                cell.snapshot.contentMode = .scaleAspectFill
                cell.snapshot.isHidden = false
                cell.imgprofile?.isHidden = true
                cell.flippedOverlay.isHidden = false
                //cell.detailsView.hidden = true
                self.cellStates[row!] = cellState.flipped
            }) { (finished) -> Void in
                
            }
           }else {
                UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                    
                    cell.flippedOverlay.isHidden = false
                    //cell.detailsView.hidden = true
                    self.cellStates[row!] = cellState.flipped
                    }) { (finished) -> Void in
                        
                }
        }
    }
    
    func openLikersVC(_ index: Int) {
        // fetch before opening the VC to make sure the color still exists
        let color = colors[index]
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
                    self.colors.remove(at: index)
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
//        let row = gr.view?.tag
//        let cell: TrendingListCell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: row!, inSection: 0)) as! TrendingListCell
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc: LikersVC = storyboard.instantiateViewControllerWithIdentifier("LikersVC") as! LikersVC
//        vc.color = cell.color
//        let navController = UINavigationController(rootViewController: vc)
//        self.presentViewController(navController, animated:true, completion: nil)
    }
    
    func likePressed(_ sender: UIButton) {
        let cell: TrendingListCell = collectionView?.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as! TrendingListCell
        let color = cell.color
        if isLikeInProgress == true {
            return
        }
        isLikeInProgress = true
        
        if cell.isLiked == false  {
            cell.isLiked = true
            cell.btnLikeInCommentsView.setTitle("", for: UIControlState())
            cell.btnLikeInCommentsView.isUserInteractionEnabled = false
            cell.likeActivityIndicator.isHidden = false
            cell.likeActivityIndicator.startAnimating()
            //cell.productView.removeGestureRecognizer(cell.doubleTap)
            
            if let color = color {
                cell.lbllikescount?.text = "\(color.numLikes + 1)"
				
				PFCloud.callFunction(inBackground: kCloudFuncAddLike, withParameters: [kParseKeyColorId: color.objectId!], block: { (result, error) in
                    cell.btnLikeInCommentsView.isUserInteractionEnabled = true
                    cell.likeActivityIndicator.stopAnimating()
                    cell.likeActivityIndicator.isHidden = true
                    
                    guard error == nil, let _ = result else {
                        print("error: \(error)")
                        
                        cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                        
                        if let errorLocalized = error?.localizedDescription {
                            let errorData = errorLocalized.data(using: String.Encoding.utf8)
                            do {
                                let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                                if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                    print("errorCode: \(errorCode)")
                                    if errorCode == 101 {
                                        self.colors.remove(at: sender.tag)
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
                        self.isLikeInProgress = false
                        guard error == nil, let colorObject = colorObject else {
                            cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                            return
                        }

                        let newColor = SColor(data: colorObject)
                        self.colors[sender.tag] = newColor
                        cell.lbllikescount?.text = "\(newColor.numLikes)"
                        cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                    })
                })
            }
        } else {
            cell.isLiked = false
            cell.btnLikeInCommentsView.setTitle("", for: UIControlState())
            cell.btnLikeInCommentsView.isUserInteractionEnabled = false
            cell.likeActivityIndicator.isHidden = false
            cell.likeActivityIndicator.startAnimating()
            
            if let color = color {
                cell.lbllikescount?.text = "\(color.numLikes)"
				
				PFCloud.callFunction(inBackground: kCloudFuncRemoveLike, withParameters: [kParseKeyColorId: color.objectId!], block: { (result, error) in
                    cell.btnLikeInCommentsView.isUserInteractionEnabled = true
                    cell.likeActivityIndicator.stopAnimating()
                    cell.likeActivityIndicator.isHidden = true
                    
                    guard error == nil, let _ = result else {
                        cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                        
                        if let errorLocalized = error?.localizedDescription {
                            let errorData = errorLocalized.data(using: String.Encoding.utf8)
                            do {
                                let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                                if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                    if errorCode == 101 {
                                        self.colors.remove(at: sender.tag)
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
                        self.isLikeInProgress = false
                        guard error == nil, let colorObject = colorObject else {
                            cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                            return
                        }
                        
                        let newColor = SColor(data: colorObject)
                        self.colors[sender.tag] = newColor
                        cell.lbllikescount?.text = "\(newColor.numLikes)"
                        cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                    })
                })
            }
        }
    }
    
    func flipBack(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let cell: TrendingListCell = collectionView?.cellForItem(at: IndexPath(row: row!, section: 0)) as! TrendingListCell
        cell.snapshot.isHidden = true
        cell.imgprofile!.isHidden = false
        cell.bottomView.isHidden = false
        
        UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
            cell.flippedOverlay.isHidden = true
            self.cellStates[row!] = cellState.normal
            }) { (finished) -> Void in
                let path = IndexPath(row: row!, section: 0)
                self.collectionView?.reloadItems(at: [path])
        }
    }
    
    func profileTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let color = colors[row!]
        
        do {
            try color.createdBy!.fetchIfNeeded()
        } catch {
            
        }
        
        transitionToProfile(SUser(dataUser: color.createdBy))
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
            return CGSize(width: self.view.frame.width/3, height: self.view.frame.width/3)
        }
        
        var productImgViewWidth = self.collectionView!.frame.width - 50.0
        
        let color = colors[indexPath.item]
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if (isGrid!) {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
        return UIEdgeInsetsMake(20, 0, 0, 0)
    }
    
    func constructCommentsString(_ comments: NSMutableArray) -> NSMutableAttributedString {
        let commentsString = NSMutableAttributedString()
        
        var index = 0
        for comment in comments {
            if let comment = comment as? SComment {
                let userNameString = NSMutableAttributedString(string: "\(comment.user!.username!) ")
                userNameString.addAttribute(NSLinkAttributeName, value: URL(string: "https://\(index)")!, range: NSRange(location: 0, length: Int((comment.user!.username!).characters.count)))
                userNameString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 13)!, range: NSRange(location: 0, length: Int((comment.user!.username!).characters.count)))
                userNameString.addAttribute(NSForegroundColorAttributeName, value: UIColor.purple(), range: NSRange(location: 0, length: Int((comment.user!.username!).characters.count)))
                let commentString = NSMutableAttributedString(string: "\(comment.message!)\n")
                commentString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Book", size: 13)!, range: NSRange(location: 0, length: Int((comment.message!).characters.count)))
                
                commentsString.append(userNameString)
                commentsString.append(commentString)
                index += 1
            }
        }
        
        return commentsString
    }
    
    // MARK: - Auxiliary
    
    func colorExistsInArray(_ color: SColor) -> Int {
        for i in 0..<colors.count {
            if(colors[i].objectId == color.objectId) {
                return i
            }
        }
        return -1
    }
    
    func showColorDetailsForColor(_ color : SColor) {
        
        //scrolls to top of screen before transitioning

        color.object?.fetchInBackground(block: { (object, error) -> Void in
            if error == nil {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: ColorDetailsVC = storyboard.instantiateViewController(withIdentifier: "ColorDetailsVC") as! ColorDetailsVC
                vc.color = color
                let navController = NickNavViewController(rootViewController: vc)
                self.present(navController, animated: true, completion: { 
                    let path = IndexPath(item: 0, section: 0)
//                    self.bringNavBarToOriginal()
                    self.collectionView?.scrollToItem(at: path, at: .bottom, animated: false)
                })
            } else {
                if error!._code == 101 {
                    // The color does not exist anymore. i.e it was deleted by user
                    let index = self.colorExistsInArray(color)
                    if(index >= 0) {
                        // Deleted color is in array
                        // Remove it from array
                        self.colors.remove(at: index)
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
//        bringNavBarToOriginal()
        let sb = UIStoryboard(name: "ECommerce", bundle: nil)
        let vc: FullColorProfileVC = sb.instantiateViewController(withIdentifier: "FullColorProfileVC") as! FullColorProfileVC
        vc.color = color
        
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated: true, completion: nil)
    }
    
    // MARK: - TrendingListCellDelegate
    
    func trendingListCellBtnCommentPressed(_ cell: TrendingListCell) {
        openCommentsVC(cell.btnCommentsInCommentsView.tag)
    }
    
    func trendingListCellBtnColorDetailsPressed(_ cell: TrendingListCell) {
        self.showFullColorProfileForColor(cell.color!)
    }
    
    // MARK: - Scrolling
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var navBarFrame = self.navigationController!.navigationBar.frame
        var tabBarFrame = self.tabBarController!.tabBar.frame
        var tabBarImageFrame = appDelegate.imagefooter!.frame
        let size = navBarFrame.size.height - 21
        var framePercentageHidden = ((STATUS_BAR_HEIGHT - navBarFrame.origin.y) / (navBarFrame.size.height - 1))
        let scrollOffset = scrollView.contentOffset.y
        let scrollDiff = scrollOffset - self.previousContentOffset
        let scrollHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        if (navBarFrame.origin.y == 20 && scrollView.contentSize.height < (scrollView.frame.size.height + navBarFrame.size.height)) {
            return
        }
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            navBarFrame.origin.y = STATUS_BAR_HEIGHT
            tabBarImageFrame.origin.y = SCREEN_HEIGHT - tabBarImageFrame.height
            tabBarFrame.origin.y = SCREEN_HEIGHT - tabBarFrame.height
            framePercentageHidden = 0
        }
            
        else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            navBarFrame.origin.y = -size
            tabBarImageFrame.origin.y = SCREEN_HEIGHT
            tabBarFrame.origin.y = SCREEN_HEIGHT
            framePercentageHidden = 1
        }
            
        else {
            navBarFrame.origin.y = min(STATUS_BAR_HEIGHT, max(-size, navBarFrame.origin.y - scrollDiff))
            let screenHeightNoFrame = SCREEN_HEIGHT - tabBarImageFrame.height
            let tabBarWithScrollDiff = tabBarImageFrame.origin.y + scrollDiff
            
            tabBarImageFrame.origin.y = max(screenHeightNoFrame, min(SCREEN_HEIGHT, tabBarWithScrollDiff))
            //Place tabbar image directly over the tab bar frame
            //Adding this constant value accounts for the difference between the top of the navbar and the top of the navbar image
            tabBarFrame.origin.y = tabBarImageFrame.origin.y + 13
        }
        
        self.navigationController?.navigationBar.frame = navBarFrame
        self.tabBarController?.tabBar.frame = tabBarFrame
        appDelegate.imagefooter!.frame = tabBarImageFrame
        
        self.backgroundTopConstraint.constant = navBarFrame.origin.y - STATUS_BAR_HEIGHT
        self.collectionViewTopConstraint.constant = navBarFrame.origin.y - STATUS_BAR_HEIGHT
        self.collectionViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
        self.updateBarButtonItems(1 - framePercentageHidden)
        
        self.previousContentOffset = self.collectionView!.contentOffset.y
        
        // pagination
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
            if addMoreData == true && additionalColors.count > 0 {
                colors += additionalColors
                cellStates += additionalCellStates
                self.collectionView?.reloadData()
                if additionalColors.count == pageLimit {
                    self.getMoreData()
                } else {
                    addMoreData = false
                }
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate)
        {
            self.stoppedScrolling()
        }
    }
    
    func stoppedScrolling()
    {
        let frame = self.navigationController?.navigationBar.frame
        if(frame?.origin.y < STATUS_BAR_HEIGHT)
        {
            self.animateNavBarTo(-(frame!.size.height - STATUS_BAR_HEIGHT))
        }
    }
    
    func updateBarButtonItems(_ alpha: CGFloat)
    {
        var items = self.navigationItem.leftBarButtonItems! as NSArray
        
		items.enumerateObjects({ (object, index, stop) -> Void in
			let item = object as! UIBarButtonItem
			item.tintColor = item.tintColor!.withAlphaComponent(alpha)
		})
        
        items = self.navigationItem.rightBarButtonItems! as NSArray
        
		items.enumerateObjects({ (object, index, stop) -> Void in
			let item = object as! UIBarButtonItem
			item.tintColor = item.tintColor!.withAlphaComponent(alpha)
		})
        
        self.navigationItem.titleView?.alpha = alpha
        self.navigationController?.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor.withAlphaComponent(alpha)
    }
    
    func animateNavBarTo(_ y: CGFloat)
    {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            var navBarFrame = self.navigationController!.navigationBar.frame
            var tabBarFrame = self.tabBarController!.tabBar.frame
            var tabBarImageFrame = appDelegate.imagefooter!.frame
            let alpha: CGFloat = navBarFrame.origin.y >= y ? 0 : 1
            navBarFrame.origin.y = y
            tabBarFrame.origin.y = self.SCREEN_HEIGHT
            tabBarImageFrame.origin.y = self.SCREEN_HEIGHT
            self.navigationController?.navigationBar.frame = navBarFrame
            self.tabBarController?.tabBar.frame = tabBarFrame
            appDelegate.imagefooter!.frame = tabBarImageFrame
            
            self.collectionViewBottomConstraint.constant = 0
            self.collectionViewTopConstraint.constant = -navBarFrame.height
            self.backgroundTopConstraint.constant = -navBarFrame.height
            
            self.updateBarButtonItems(alpha)
        })
    }
    
    func bringNavBarToOriginal() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let navBarFrame = self.navigationController!.navigationBar.frame
            var tabBarFrame = self.tabBarController!.tabBar.frame
            var tabBarImageFrame = appDelegate.imagefooter!.frame
            tabBarImageFrame.origin.y = self.SCREEN_HEIGHT - tabBarImageFrame.height
            tabBarFrame.origin.y = self.SCREEN_HEIGHT - tabBarFrame.height
            self.navigationController?.navigationBar.frame = navBarFrame
            self.tabBarController?.tabBar.frame = tabBarFrame
            appDelegate.imagefooter!.frame = tabBarImageFrame
            
            
            self.collectionViewBottomConstraint.constant = 0
            self.collectionViewTopConstraint.constant = navBarFrame.origin.y - self.STATUS_BAR_HEIGHT
            self.backgroundTopConstraint.constant = navBarFrame.origin.y - self.STATUS_BAR_HEIGHT
            
            self.updateBarButtonItems(1.0)
        })
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print("INVITE DIALOG RESULTS: \(results)")
    }
	
	public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("INVITE DIALOG FAILED: \(error)")
    }
    
    // MARK: - TSLabelDelegate
    func label(_ label: TSLabel!, canInteractWith URL: Foundation.URL!, in characterRange: NSRange) -> Bool {
        return true
    }
    
    func label(_ label: TSLabel!, shouldInteractWith URL: Foundation.URL!, in characterRange: NSRange) -> Bool {
        let row = label.tag
        let color = colors[row]
        let index = Int(URL.host!)
        
        if let commentsArray = comments[color.objectId!] as? NSArray {
            if index < commentsArray.count {
                let comment = commentsArray[index!] as! SComment
                let user = comment.user
                
                do {
                    try user!.fetchIfNeeded()
                } catch {
                    
                }
                transitionToProfile(SUser(dataUser: user))
            }
        }
        
        return false
    }
    
    // MARK: - NSNotifications
    func colorDeletedSomewhere(_ notification: Notification) {
        if let color = notification.object as? SColor {
        
            let index = colorExistsInArray(color)
            print("TrendingVC: colorDeletedSomewhere index: \(index)")
            if index >= 0 {
                // Deleted color is in array
                
                // Remove it from array
                colors.remove(at: index)
                cellStates.remove(at: index)
                
                // Reload collectionview
                collectionView?.reloadData()
            }
        }
    }
    
    func showMap(_ tap : UITapGestureRecognizer?){
  
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.navigationController!.navigationBar.frame = navBarFrame
        self.tabBarController!.tabBar.frame = tabBarFrame
        appDelegate.imagefooter!.frame = tabBarImageFrame
        
        let row = tap?.view!.tag
        let color = colors[row!]
        // Do not allow the bottom view to be shown
        let vc = storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vc.geopoint = color.geopoint
        vc.locationName = color.locationName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
