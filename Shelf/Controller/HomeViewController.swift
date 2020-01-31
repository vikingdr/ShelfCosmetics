//
//  HomeViewController.swift
//  Shelf
//
//  Created by Nathan Konrad on 03/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import FBSDKShareKit
import MapKit
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


let kCloudFuncGetFeed = "getFeed"
let kCommentAdd = "CommentAdd"
let kParseKeyColors = "colors"

class HomeViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableview:UITableView?
  //  @IBOutlet var likeImage:UIImageView?
    
   //  @IBOutlet weak var likeImage:UIImageView!
    
    var imageViewObject :UIImageView!
    
    var likeImage: UIImageView?
    var likeImageOrigRect: CGRect!
    
    var tabBarImageFrame : CGRect!
    var navBarFrame : CGRect!
    var tabBarFrame : CGRect!
    
    //var likeImage:UIImageView?
    
    var scrollFrameHeight:CGFloat?
    var previousContentOffset:CGFloat = 0.0
    let SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
    let SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
    let STATUS_BAR_HEIGHT: CGFloat = UIApplication.shared.statusBarFrame.height
    var cellStates : [cellState] = []
    var singleTap : UITapGestureRecognizer!
    var colors : [SColor] = []
    
    var additionalColors : [SColor] = []
    var additionalCellStates : [cellState] = []
    var page : Int = 0
    let pageLimit : Int = 5
    var addMoreData : Bool = false
    var isLoadingFeed : Bool = false
    var overlayView : UIImageView!
    var refreshControl: UIRefreshControl!
    var isLike = false
    var comments: NSMutableDictionary = NSMutableDictionary()
    
    fileprivate var scrollOffset: CGFloat = 0
    
    enum cellState {
        
        case normal
        case detail
        case flipped
        case showComments
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCommentAdd), object: nil)
    }
    
    // MARK: - View Life cycle methods
    override func viewDidLoad() {
        
        
        //Buildwithnewprofile
        super.viewDidLoad()
        let kBarHeight5OrLess = CGFloat(54)
        let kBarHeight6OrGreater = CGFloat(72)

        setupNavBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.addedComment(_:)), name: NSNotification.Name(rawValue: kCommentAdd), object: nil)
        
        let inset = UIEdgeInsetsMake(15, 0, 15, 0)
        tableview!.contentInset = inset
        
      //  self.tabBarController?.selectedIndex = 1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if constant.DeviceType.IS_IPHONE_4_OR_LESS{
            appDelegate.imagefooter?.frame = CGRect(x: 0, y: self.view.frame.size.height - kBarHeight5OrLess, width: self.view.frame.size.width, height: kBarHeight5OrLess)
            appDelegate.footerSelectionView = UIView(frame: CGRect(x: 0, y: 10.5, width: self.view.width / 5, height: 58))
        }
        else if constant.DeviceType.IS_IPHONE_5{
            appDelegate.imagefooter?.frame = CGRect(x: 0, y: self.view.frame.size.height - kBarHeight5OrLess, width: self.view.frame.size.width, height: kBarHeight5OrLess)
            appDelegate.footerSelectionView = UIView(frame: CGRect(x: 0, y: 10.5, width: self.view.width / 5, height: 58))
        }
        else if constant.DeviceType.IS_IPHONE_6{
            appDelegate.imagefooter?.frame = CGRect(x: 0, y: self.view.frame.size.height - 65, width: self.view.frame.size.width, height: 65)
            appDelegate.footerSelectionView = UIView(frame: CGRect(x: 0, y: 12.5, width: self.view.width / 5, height: 67.5))
        }
        else{
            appDelegate.imagefooter?.frame = CGRect(x: 0, y: self.view.frame.size.height - kBarHeight6OrGreater, width: self.view.frame.size.width, height: kBarHeight6OrGreater)
            appDelegate.footerSelectionView = UIView(frame: CGRect(x: 0, y: 12.3, width: self.view.width / 5, height: 67.7))
        }
        
        //imagefooter?.backgroundColor = UIColor.redColor()
        if constant.DeviceType.IS_IPHONE_4_OR_LESS{
            appDelegate.imagefooter?.image = UIImage(named:"Tab_strip_3.png")
        }
        else if constant.DeviceType.IS_IPHONE_5{
            
            appDelegate.imagefooter?.image = UIImage(named:"Tab_strip_3_iPhone5.png")
        }
        else if constant.DeviceType.IS_IPHONE_6{
            
            appDelegate.imagefooter?.image = UIImage(named:"Tab_strip_3_iPhone6@2x.png")
        }
        else{
            // Tab_strip_1_iPhone6plus@3x.png
            appDelegate.imagefooter?.image = UIImage(named:"Tab_strip_3_iPhone6plus@3x.png")
        }
        
        self.tabBarController?.view.addSubview(appDelegate.imagefooter!)
        
        for subview: UIView in appDelegate.imagefooter!.subviews {
            subview.removeFromSuperview()
        }
        
        //Toolbar is setup using single image... so we need to do this unfortunately...
        let index = 1
        if constant.DeviceType.IS_IPHONE_6P  {
            appDelegate.imagefooter?.image = UIImage(named: "Tab_strip_\(index)_iPhone6plus@3x")
        }
        else if constant.DeviceType.IS_IPHONE_6 {
            appDelegate.imagefooter?.image = UIImage(named: "Tab_strip_\(index)_iPhone6@2x")
        }
        else if constant.DeviceType.IS_IPHONE_5 {
            appDelegate.imagefooter?.image = UIImage(named: "Tab_strip_\(index)_iPhone5@2x")
        }
        else if constant.DeviceType.IS_IPHONE_4_OR_LESS {
            appDelegate.imagefooter?.image = UIImage(named: "Tab_strip_\(index)@2x")
        }
        
        appDelegate.imagefooter?.addSubview(appDelegate.footerSelectionView!)
        
        tableview?.backgroundColor = UIColor.clear
        tableview?.backgroundView = nil
        
        tableViewBottomConstraint.constant = 0
        
        // Do any additional setup after loading the view.
        
        scrollFrameHeight = self.tableview!.frame.height
        
        // initialize overlayView
        let screenHeight = UIScreen.main.bounds.height
        var tabBarOffset: CGFloat = 10.5
        if screenHeight == 667 {
            tabBarOffset = 12.5
        } else if screenHeight == 736 {
            tabBarOffset = 14.0
        }
        
        let tabHeight = appDelegate.imagefooter!.frame.height - tabBarOffset
        var frame = tableview!.bounds
        frame.size.height = tableview!.frame.height - tabHeight
        overlayView = UIImageView(frame: frame)
        overlayView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
//        overlayView.backgroundColor = UIColor(r: 82, g: 83, b: 110, a: 200)
        overlayView.backgroundColor = UIColor.white

        var imageName = "HomeBackground"
        getDeviceBackgroundImageName(&imageName)
        overlayView.image = UIImage(named: imageName)
        overlayView.contentMode = .scaleAspectFit
        
        
        
        
        
        
//        let overlayLabel = UILabel()
//        overlayLabel.autoresizingMask = .FlexibleBottomMargin
//        overlayLabel.font = UIFont(name: "Avenir-Black", size: 16)
//        overlayLabel.textColor = UIColor.whiteColor()
//        overlayLabel.textAlignment = NSTextAlignment.Center
//        overlayLabel.text = "This will soon be your Feed!\nExplore Search and Trending below\nto start following people."
//        overlayLabel.numberOfLines = 3
//        overlayLabel.sizeToFit()
//        overlayLabel.bottom = overlayView.height / 2
//        overlayLabel.centerX = overlayView.width / 2
//        overlayLabel.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
//        
//        overlayView.addSubview(overlayLabel)
//        
//        let arrowImgView = UIImageView(image:UIImage(named:"arrow_down"))
//        arrowImgView.autoresizingMask = .FlexibleBottomMargin
//        arrowImgView.sizeToFit()
//        arrowImgView.top = overlayLabel.bottom + 10;
//        arrowImgView.centerX = overlayView.width / 2
//        arrowImgView.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin]
//        overlayView.addSubview(arrowImgView)
        
        
        
        imageViewObject = UIImageView(frame:CGRect(x: (self.view.frame.size.width - 277)/2,y: self.view.frame.size.height-300,width: 277, height: 151))
        
        imageViewObject.image = UIImage(named:"homealertImg")
        
        overlayView.addSubview(imageViewObject)
        
        tableview?.addSubview(overlayView)
        
        // UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(HomeViewController.reloadData), for: UIControlEvents.valueChanged)
        tableview?.addSubview(refreshControl)
        
        reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.bringNavBarToOriginal), name: NSNotification.Name(rawValue: "BringNavigationBarToOriginal"), object: nil)
    
        navBarFrame = navigationController!.navigationBar.frame
        tabBarFrame = tabBarController!.tabBar.frame
        tabBarImageFrame = appDelegate.imagefooter!.frame
        
        //live
       // if error == nil{
        
        
        let image: UIImage = UIImage(named: "LikeImage")!
        likeImage = UIImageView(image: image)
        
//        let image: UIImage = UIImage(named: "LikeImage")!
//        likeImage = UIImageView(image: image)
//        likeImage!.frame = CGRectMake(self.view.frame.size.width/2-75,40,150,150)
//        self.view.addSubview(likeImage!)
//        likeImage?.hidden=true;
        
        
      //  }
        
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter!.isHidden = false

    }
    
    func setupNavBar() {
        
        navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        
        navigationController?.navigationBar.layer.shadowRadius = 4.0
        navigationController?.navigationBar.layer.shadowOpacity = 0.26
        //Registation_logo
        
        let titleView:UIImageView = UIImageView(image: UIImage(named: "HomeSilfImage"))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 70.0, height: 30.0)
        self.navigationItem.titleView = titleView
        
        //btnInviteFriends  HomeSilfImage  //feb661
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "homeimage")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(HomeViewController.inviteFriendsPressed))
//        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
//        navigationItem.leftBarButtonItem?.tintColor = UIColorFromRGB(0xfeb661)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: #selector(HomeViewController.settingsPressed))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
              // let logo = UIImage(named: "favorites-home-icon@1.png")
       /// let imageView = UIImageView(image:logo)
      //  self.navigationItem.leftBarButtonItem?.image=imageView
        
    }

    func setupTabBar() {
        
    }
    
    func inviteFriendsPressed() {
//        bringNavBarToOriginal()
        if FBSDKAppInviteDialog().canShow() {
            
            let content = FBSDKAppInviteContent()
            content.appLinkURL = NSURL(string: "https://fb.me/1640480846199078") as URL!
            FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
            AnalyticsHelper.sendCustomEvent(kFIREventInvite)
        } else {
            
            let alert = UIAlertView(title: "Facebook Invites Unavailable", message: "It seems like you do not have the appropriate Facebook app installed in order to invite your friends", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
        }
//        let storyboard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
//        let vc: SettingsVC = storyboard.instantiateViewController(withIdentifier: kSettingsVCIdentifier) as! SettingsVC
//        vc.isAddFriend = true
//        
//        let transition = CATransition()
//        transition.duration = 0.3
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromLeft
//        view.window!.layer.add(transition, forKey: kCATransition)
//        
//        let navController = UINavigationController(rootViewController: vc)
//        self.present(navController, animated:false, completion: nil)
		
    }
    
    func settingsPressed() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: kSettingsVCIdentifier) as! SettingsVC
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    func reloadData() {
        guard isLoadingFeed == false else {
            return
        }
        
        isLoadingFeed = true
        self.page = 0
        //Load colors and comments
        AppDelegate.showActivity()
        colors = []
        cellStates = []
        
        PFCloud.callFunction(inBackground: kCloudFuncGetFeed, withParameters: [kKeyPage: self.page, kKeyLimit: self.pageLimit]) { (result, error) -> Void in
            self.refreshControl.endRefreshing()
            self.isLoadingFeed = false
            
            guard error == nil, let dict = result as? [String:[PFObject]] else {
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
            
            let colorsObjects = dict[kParseKeyColors]
            var i = 0
            for object in colorsObjects! {
                    let color = SColor(data: object)
                if color.createdBy != nil {
                    self.colors.append(color)
                    self.createMapSnapshot(color, width: self.tableview!.frame.width - 50.0, completion: nil )

                    self.cellStates.append(cellState.normal)
                    i = i + 1
                }
            }
            
            self.page += 1
            
            if self.colors.count >= self.pageLimit {
                self.getMoreData()
                self.addMoreData = true
            } else {
                self.addMoreData = false
            }

            if self.colors.count == 0 {
                self.overlayView.isHidden = false
            } else {
                self.overlayView.isHidden = true
                self.imageViewObject.removeFromSuperview()
            }
            
            AppDelegate.hideActivity()
            self.tableview?.reloadData()
            self.checkForDisableScrolling(self.tableview!)
        }
    }
    
    func getMoreData() {
        //Load additional colors and comments
        additionalColors = []
        additionalCellStates = []
        
        PFCloud.callFunction(inBackground: kCloudFuncGetFeed, withParameters: [kKeyPage: self.page, kKeyLimit: self.pageLimit]) { (result, error) -> Void in
            guard error == nil, let dict = result as? [String:[PFObject]] else {
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
            
            let colorsObjects = dict[kParseKeyColors]
            for object in colorsObjects! {
                let color = SColor(data: object)
                if let _ = color.createdBy {
                    self.additionalColors.append(color)
                    self.additionalCellStates.append(cellState.normal)
                }
            }
            
            self.page += 1
        }
    }
    
     // MARK: - UItableView methods
    
    func constructCommentsString(_ comments: NSMutableArray) -> NSMutableAttributedString {
//    func constructCommentsString(comment: SComment) -> NSMutableAttributedString {
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
    
    func getColorTitleLabelHeight(_ title: String, showComments: Bool) -> CGFloat {
        let constraint = CGSize(width: self.tableview!.frame.width - 90.0, height: CGFloat(MAXFLOAT))
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
    
    func getCommentsHeight(_ comments: NSMutableAttributedString) -> CGFloat {
        
        let attributedText = comments as NSAttributedString;
        let width = self.tableview!.frame.width - 90.0 // 90 is the sum of leading and trailing space
        
        let rect: CGRect = attributedText.boundingRect(with: CGSize(width: CGFloat(width), height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        return rect.size.height
    }
    
    func showMap(_ tap : UITapGestureRecognizer?){
        let row = tap?.view!.tag
        presentMap(row!)
    }
    
    func presentMap(_ row : Int){
       // dispatch_async(dispatch_get_main_queue()) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            self.navigationController?.navigationBar.frame = self.navBarFrame
            self.tabBarController?.tabBar.frame = self.tabBarFrame
            appDelegate.imagefooter!.frame = self.tabBarImageFrame
            
            self.backgroundTopConstraint.constant = self.navBarFrame.origin.y - self.STATUS_BAR_HEIGHT
            self.tableViewTopConstraint.constant = self.navBarFrame.origin.y - self.STATUS_BAR_HEIGHT
            self.tableViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.updateBarButtonItems(1)
            
            self.previousContentOffset = self.tableview!.contentOffset.y
        
            if row < colors.count {
                let color = self.colors[row]
                // Do not allow the bottom view to be shown
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
                vc.geopoint = color.geopoint
                vc.locationName = color.locationName
                self.navigationController?.pushViewController(vc, animated: true)
            }
        //}
    }
    
    func checkForDisableScrolling( _ scrollView : UIScrollView){
        if colors.count == 0 {
            if scrollView.contentOffset.y > scrollOffset {
                scrollView.contentOffset.y = scrollOffset
                return
            }
            else {
                scrollView.isScrollEnabled = true
                return
            }
        }
        else {
            scrollView.isScrollEnabled = true
        }
    }
    
    // MARK: - Gestures
    func productImageTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        switch cellStates[row!] {
        case cellState.normal:
            cellStates[row!] = cellState.detail
            let row = gr.view?.tag
            let cell: HomeCell = tableview?.cellForRow(at: IndexPath(row: row!, section: 0)) as! HomeCell
            let color = colors[row!]
            if let snapshot = color.mapsnapShot {
                cellStates[row!] = cellState.normal

                UIView.animate(withDuration: 0.1, animations: {
                    
                    }, completion: { (completed) in
                        DispatchQueue.main.async(execute: {
                            UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                                let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.showMap(_:)))
                                cell.snapshot.addGestureRecognizer(tap)
                                cell.snapshot.image = snapshot
                                cell.snapshot.contentMode = .scaleAspectFill
                                cell.snapshot.isHidden = false
                                cell.snapshot.isUserInteractionEnabled = true
                                cell.snapshot.tag = row!
                                cell.bringSubview(toFront: cell.snapshot)
                                cell.imgprofile?.isHidden = true
                                cell.bottomView.isHidden = true
                                cell.commentsView.isHidden = true
                                cell.flippedOverlay.isHidden = false
                                
                                
                                self.cellStates[row!] = cellState.flipped
                            }) { (finished) -> Void in
                                
                            }
                        })
                })
            }else{
                UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                    cell.flippedOverlay.isHidden = false
                    cell.imgprofile?.isHidden = false
                    cell.snapshot.isHidden = true
                    cell.bottomView.isHidden = false
                    
                    self.cellStates[row!] = cellState.flipped
                }) { (finished) -> Void in
                    
                }
            }
        default:
            
            cellStates[row!] = cellState.normal

        }
    }
    
    func productImageTappedTwice(_ gr: UITapGestureRecognizer) {
        
        let row = gr.view?.tag
        let cell: HomeCell = tableview?.cellForRow(at: IndexPath(row: row!, section: 0)) as! HomeCell
        likePressed(cell.btnLikers)
        
        likeImageOrigRect = CGRect(x: ((gr.view?.frame.size.width)! - 1)/2, y: ((gr.view?.frame.size.height)! - 1)/2, width: 1, height: 1)
        likeImage?.frame = likeImageOrigRect
        gr.view?.addSubview(likeImage!)
        
        let heartViewRect = CGRect(x: ((gr.view?.frame.size.width)! - 150)/2, y: ((gr.view?.frame.size.height)! - 150)/2, width: 150, height: 150)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.likeImage?.frame = heartViewRect
        })
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(hideLikeImageView), userInfo: nil, repeats: false)
        
        
    }
    
    func hideLikeImageView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.likeImage?.frame = self.likeImageOrigRect
        })
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(removeLikeImageView), userInfo: nil, repeats: false)
        
    }
    
    func removeLikeImageView() {
        self.likeImage?.removeFromSuperview()
    }
    
    
    func detailsTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let cell: HomeCell = tableview?.cellForRow(at: IndexPath(row: row!, section: 0)) as! HomeCell
        let color = colors[row!]
        if let snapshot = color.mapsnapShot {
            cellStates[row!] = cellState.normal
            DispatchQueue.main.async(execute: {
                self.tableview?.reloadData()
            })

        UIView.animate(withDuration: 0.1, animations: {
        
            }, completion: { (completed) in
           DispatchQueue.main.async(execute: {
                UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                    let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.showMap(_:)))
                    cell.snapshot.addGestureRecognizer(tap)
                    cell.snapshot.image = snapshot
                    cell.snapshot.contentMode = .scaleAspectFill
                    cell.snapshot.isHidden = false
                    cell.snapshot.isUserInteractionEnabled = true
                    cell.imgprofile?.isHidden = true
                    cell.bottomView.isHidden = true
                    cell.commentsView.isHidden = true
                    cell.flippedOverlay.isHidden = false
    
                    self.cellStates[row!] = cellState.flipped
                }) { (finished) -> Void in
                    
                }
            })
        })
        }else{
            UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                cell.flippedOverlay.isHidden = false
                
                self.cellStates[row!] = cellState.flipped
            }) { (finished) -> Void in
                
            }
        }
        

    }
    
    func openLikersVC(_ index: Int) {
        // fetch before opening the VC to make sure the color still exists
        let color = colors[index]
        // Check if navigation bar is hidden
        if navigationBarHidden() {
            updateBarButtonItems(0)
        }
        color.object?.fetchInBackground(block: { (object, error) -> Void in
            if error == nil {
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: LikersVC = storyboard.instantiateViewController(withIdentifier: "LikersVC") as! LikersVC
                vc.color = color
                let navController = NickNavViewController(rootViewController: vc)
                self.present(navController, animated: true, completion: { 
                    self.updateBarButtonItems(1)
                })
            } else {
                if error!._code == 101 {
                    // The color does not exist anymore. i.e it was deleted by user
                    self.colors.remove(at: index)
                    self.cellStates.remove(at: index)
                    
                    if self.colors.count > 0 {
                        self.overlayView.isHidden = true
                        self.imageViewObject.removeFromSuperview()
                    }
                    else {
                        self.overlayView.isHidden = false
                    }
                    
                    self.tableview?.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.fade)
                    
                    let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            }
        })
    }
    
    func likersPressed(_ gr: UITapGestureRecognizer) {
        bringNavBarToOriginal()
        
        openLikersVC(gr.view!.tag)
    }
    
    func likePressed(_ sender: UIButton) {
        let cell: HomeCell = tableview?.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! HomeCell
        guard let color = cell.color else {
            return
        }
        
        if isLike == true {
            return
        }
        isLike = true
        
        if cell.likeButton != nil && cell.likeButton.titleLabel != nil && cell.isLiked == false {
            cell.isLiked = true
            let newLikesCount = NSInteger(cell.lbllikescount!.text!)! + 1
            cell.lbllikescount?.text = String(newLikesCount)
            
            cell.likeButton.setTitle("", for: UIControlState())
            cell.likeButton.isUserInteractionEnabled = false
            cell.likeActivityIndicator.isHidden = false
            cell.likeActivityIndicator.startAnimating()
            
            PFCloud.callFunction(inBackground: kCloudFuncAddLike, withParameters: [kParseKeyColorId: color.objectId!]) { (result, error) in
                cell.likeButton.isUserInteractionEnabled = true
                cell.likeActivityIndicator.stopAnimating()
                cell.likeActivityIndicator.isHidden = true
                
                guard error == nil, let _ = result else {
                    cell.likeButton.setTitle("LIKE", for: UIControlState())
                    self.isLike = false
                    
                    if let errorLocalized = error?.localizedDescription {
                        let errorData = errorLocalized.data(using: String.Encoding.utf8)
                        do {
                            let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                            if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                if errorCode == 101 {
                                    self.colors.remove(at: sender.tag)
                                    self.cellStates.remove(at: sender.tag)
                                    
                                    if self.colors.count > 0 {
                                        self.overlayView.isHidden = true
                                        self.imageViewObject.removeFromSuperview()
                                    }
                                    else {
                                        self.overlayView.isHidden = false
                                    }
                                    
                                    self.tableview?.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: UITableViewRowAnimation.fade)
                                    
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
                    self.isLike = false
                    
                    guard error == nil, let colorObject = colorObject else {
                        cell.likeButton.setTitle("LIKE", for: UIControlState())
                        cell.productView.addGestureRecognizer(cell.doubleTap)
                        return
                    }
                    
                    let newColor = SColor(data: colorObject)
                    self.colors[sender.tag] = newColor
                    cell.lbllikescount?.text = "\(newColor.numLikes)"
                    cell.likeButton.setTitle("UNLIKE", for: UIControlState())
                    cell.productView.addGestureRecognizer(cell.doubleTap)
                })
            }
        } else {
            let newLikesCount = NSInteger(cell.lbllikescount!.text!)! - 1
            cell.lbllikescount?.text = String(newLikesCount)
            cell.isLiked = false
            cell.likeButton.setTitle("", for: UIControlState())
            cell.likeButton.isUserInteractionEnabled = false
            cell.likeActivityIndicator.isHidden = false
            cell.likeActivityIndicator.startAnimating()

            PFCloud.callFunction(inBackground: kCloudFuncRemoveLike, withParameters: [kParseKeyColorId: color.objectId!]) { (result, error) in
                cell.likeButton.isUserInteractionEnabled = true
                cell.likeActivityIndicator.stopAnimating()
                cell.likeActivityIndicator.isHidden = true
                
                guard error == nil, let _ = result else {
                    cell.likeButton.setTitle("LIKE", for: UIControlState())
                    self.isLike = false
                    
                    if let errorLocalized = error?.localizedDescription {
                        let errorData = errorLocalized.data(using: String.Encoding.utf8)
                        do {
                            let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                            if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                if errorCode == 101 {
                                    self.colors.remove(at: sender.tag)
                                    self.cellStates.remove(at: sender.tag)
                                    
                                    if self.colors.count > 0 {
                                        self.overlayView.isHidden = true
                                        self.imageViewObject.removeFromSuperview()
                                    }
                                    else {
                                        self.overlayView.isHidden = false
                                    }
                                    
                                    self.tableview?.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: UITableViewRowAnimation.fade)
                                    
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
                    self.isLike = false
                    
                    guard error == nil, let colorObject = colorObject else {
                        cell.likeButton.setTitle("UNLIKE", for: UIControlState())
                        
                        return
                    }
                    
                    let newColor = SColor(data: colorObject)
                    self.colors[sender.tag] = newColor
                    cell.lbllikescount?.text = "\(newColor.numLikes)"
                    cell.likeButton.setTitle("LIKE", for: UIControlState())
                })
            }
        }
    }
    
    func commentsPressed(_ gr: UITapGestureRecognizer) {
        bringNavBarToOriginal()
        let row = gr.view?.tag
        openCommentsVC(row!)
    }
    
    func addedComment(_ notification: Notification) {
        if let color = notification.object as? SColor {
            let row = colorExistsInArray(color)
            print("HomeViewController: addedComment(): colorExistsInArray: \(row) count: \(color.numComments)")
            if(row >= 0) {
                colors[row] = color
                tableview?.beginUpdates()
                tableview?.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                tableview?.endUpdates()
            }
        }
    }
    
    func colorExistsInArray(_ color: SColor) -> Int {
        for i in 0..<colors.count {
            if(colors[i].objectId == color.objectId) {
                return i
            }
        }
        return -1
    }
    
    func commentButtonPressed(_ button: UIButton) {
//        bringNavBarToOriginal()
        openCommentsVC(button.tag)
    }
    
    func openCommentsVC(_ index: Int) {
        // fetch before opening the VC to make sure the color still exists
        let color = colors[index]
        // Check if is navigation bar is hidden
        if navigationBarHidden() {
            updateBarButtonItems(0)
        }
        color.object?.fetchInBackground(block: { (object, error) -> Void in
            if error == nil {
                let vc: CommentsVC = self.storyboard!.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
                vc.color = color
                let navController = NickNavViewController(rootViewController: vc)
                self.present(navController, animated: true, completion: { 
                    self.updateBarButtonItems(1)
                })
            } else {
                if error!._code == 101 {
                    // The color does not exist anymore. i.e it was deleted by user
                    self.colors.remove(at: index)
                    self.cellStates.remove(at: index)
                    
                    if self.colors.count > 0 {
                        self.overlayView.isHidden = true
                        self.imageViewObject.removeFromSuperview()
                    }
                    else {
                        self.overlayView.isHidden = false
                    }
                    
                    self.tableview?.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.fade)
                    
                    let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                    alertView.show()
                }
            }
        })
    }
    
    func flipBack(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let cell: HomeCell = tableview?.cellForRow(at: IndexPath(row: row!, section: 0)) as! HomeCell
        cell.snapshot.isHidden = true
        cell.imgprofile!.isHidden = false
        cell.bottomView.isHidden = false
        UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in

            cell.flippedOverlay.isHidden = true
            self.cellStates[row!] = cellState.normal
            }) { (finished) -> Void in
                
        }
    }
    
    func detailsViewTapped(_ gr: UITapGestureRecognizer) {
        // move nav bar to it's original position
        animateNavBarTo(STATUS_BAR_HEIGHT)
        
        let row = gr.view?.tag
        let cell: HomeCell = tableview?.cellForRow(at: IndexPath(row: row!, section: 0)) as! HomeCell
        
        let sb = UIStoryboard(name: "ECommerce", bundle: nil)
        let vc: FullColorProfileVC = sb.instantiateViewController(withIdentifier: "FullColorProfileVC") as! FullColorProfileVC
        vc.color = cell.color
        
        
        
//        let transition: CATransition = CATransition()
//        transition.duration = 0.35
//        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        transition.type = kCATransitionMoveIn
//        transition.subtype = kCATransitionFromRight
        
//        let containerView:UIView = self.view.window!
//        containerView.layer.addAnimation(transition, forKey: nil)
//        self.presentViewController(vc, animated: false) { () -> Void in }
        navigationController?.pushViewController(vc, animated: true)
        
        updateBarButtonItems(1)
    }
    
    func profileTapped(_ gr: UITapGestureRecognizer) {
        bringNavBarToOriginal()
        let row = gr.view?.tag

        let color = colors[row!]
        
        do {
            if let createdBy = color.createdBy {
                try createdBy.fetchIfNeeded()
            }
        } catch {
            
        }
        
        let user = SUser(dataUser: color.createdBy)
        
        if navigationBarHidden() {
            updateBarButtonItems(0)
        }
        transitionToProfile(user, isFollowing: nil) { 
            self.updateBarButtonItems(1)
        }
    }
    
    func bottomViewTapped(_ gr: UITapGestureRecognizer) {
        let row = gr.view?.tag
        let cell: HomeCell = tableview?.cellForRow(at: IndexPath(row: row!, section: 0)) as! HomeCell
        let color = colors[row!]
        
        if self.cellStates[row!] == cellState.flipped && color.mapsnapShot != nil {
            // Do not allow the bottom view to be shown
            presentMap(row!)
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
//                self.tableview?.beginUpdates()
//                cell.detailsView.hidden = true
//                cell.flippedOverlay.hidden = true
//                cell.commentsView.hidden = true
//                self.tableview?.reloadRowsAtIndexPaths([NSIndexPath(forRow: row!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
//                self.tableview?.endUpdates()
            default:
                self.cellStates[row!] = cellState.showComments
//                self.tableview?.beginUpdates()
//                cell.commentsView.hidden = false
//                cell.detailsView.hidden = false
//                cell.flippedOverlay.hidden = true
//                self.tableview?.reloadRowsAtIndexPaths([NSIndexPath(forRow: row!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
//                self.tableview?.endUpdates()
            }
            
//            self.tableview?.beginUpdates()
            UIView.transition(with: cell.commentsView, duration: 0.2, options: UIViewAnimationOptions(), animations: { () -> Void in
                cell.commentsView.isHidden = self.cellStates[row!] == cellState.showComments ? false : true
                self.tableview?.reloadRows(at: [IndexPath(row: row!, section: 0)], with: UITableViewRowAnimation.none)
                }) { (finished) -> Void in

            }
//            cell.commentsView.hidden = false
//            cell.detailsView.hidden = false
//            cell.flippedOverlay.hidden = true
//            self.tableview?.endUpdates()
        }
    }
    
    // MARK: - Scrolling
    func stoppedScrolling() {
        let frame = navigationController?.navigationBar.frame
        if(frame?.origin.y < STATUS_BAR_HEIGHT) {
            self.animateNavBarTo(-(frame!.size.height - STATUS_BAR_HEIGHT))
        }
        else {
            updateBarButtonItems(1)
        }
    }
    
    func navigationBarHidden() -> Bool {
        if let frame = navigationController?.navigationBar.frame {
            return frame.origin.y < STATUS_BAR_HEIGHT
        }
        
        return false
    }
    
    func updateBarButtonItems(_ alpha: CGFloat) {
        var items = self.navigationItem.leftBarButtonItems! as NSArray
        
//		items.enumerateObjects(using: { (object, index, stop) -> Void in
//			let item = object as! UIBarButtonItem
//			item.tintColor = item.tintColor!.withAlphaComponent(alpha)
//		})
		
        items = self.navigationItem.rightBarButtonItems! as NSArray
        
		items.enumerateObjects({ (object, index, stop) -> Void in
			let item = object as! UIBarButtonItem
			item.tintColor = item.tintColor!.withAlphaComponent(alpha)
		})
        
        self.navigationItem.titleView?.alpha = alpha
        self.navigationController?.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor.withAlphaComponent(alpha)
    }
    
    func animateNavBarTo(_ y: CGFloat) {
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
            
            self.tableViewBottomConstraint.constant = 0
            self.tableViewTopConstraint.constant = -navBarFrame.height
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
            
            
            self.tableViewBottomConstraint.constant = 0
            self.tableViewTopConstraint.constant = -navBarFrame.height
            self.backgroundTopConstraint.constant = -navBarFrame.height
            
            self.updateBarButtonItems(1.0)
        })
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // product image view on cell has 25px padding. since the image view has 1:1, we need to calculate the cell's height from the image view
        var productImgViewWidth = self.tableview!.frame.width - 50.0
        if indexPath.row < colors.count {
            let color = colors[indexPath.row]
            
            // and add the approximate height of the bottom view plus the cell's view top and bottom padding
            productImgViewWidth += (101 + 16)
            
            productImgViewWidth += getColorTitleLabelHeight(color.comment, showComments: cellStates[indexPath.row] == cellState.showComments)
            
            //show comments if bottom of the cell was tapped
            if cellStates[indexPath.row] == cellState.showComments {
                productImgViewWidth += 44
                
                if let commentsArray: AnyObject = comments.object(forKey: color.objectId!) as AnyObject? {
                    if let commentsArray = commentsArray as? NSMutableArray {
                        if commentsArray.count > 0 {
                            let commentsString = constructCommentsString(commentsArray)
                            let commentsHeight = getCommentsHeight(commentsString)
                            productImgViewWidth += commentsHeight
                        }
                    }
                }
            }
        }
        return productImgViewWidth
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
        
        cell.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowRadius = 1
        cell.layer.shadowOpacity = 0.14
        
        cell.regularCell.layer.masksToBounds = true
        cell.regularCell.layer.cornerRadius = 5
        cell.lblUsername?.text = ""
        if indexPath.row < cellStates.count{
            switch cellStates[indexPath.row] {
            case cellState.normal:
                cell.flippedOverlay.isHidden = true
                cell.commentsView.isHidden = true
            case cellState.flipped:
                cell.flippedOverlay.isHidden = false
                cell.commentsView.isHidden = true
            case cellState.showComments:
                cell.commentsView.isHidden = false
                cell.flippedOverlay.isHidden = true
            default:
                cell.flippedOverlay.isHidden = true
                cell.commentsView.isHidden = true
            }
        }

        var color : SColor?
        if indexPath.row < colors.count {
            color = colors[indexPath.row]
            cell.color = color
        }
        
        if let snapshot = color?.mapsnapShot {
            let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.showMap(_:)))
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
            cell.coatsImage.isHidden = false
        }else{
            cell.numberOfCoats.isHidden = true
            cell.coatsImage.isHidden = true
        }
        
        
        if let timePosted = color?.createdAt {
            cell.timePosted.text = timePosted.getTimeAgoAsString(true)
        }
        
        singleTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.productImageTapped(_:)))
        singleTap.numberOfTapsRequired = 1
        cell.productView.tag = indexPath.row
        cell.productView?.isUserInteractionEnabled = true
        cell.productView?.addGestureRecognizer(singleTap)
        
        if cell.doubleTap != nil {
            cell.productView.removeGestureRecognizer(cell.doubleTap)
        }

        cell.doubleTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.productImageTappedTwice(_:)))
        cell.doubleTap.numberOfTapsRequired = 2
        cell.productView?.addGestureRecognizer(cell.doubleTap)
        singleTap.require(toFail: cell.doubleTap)
        
        
        

        cell.likeButton.addTarget(self, action: #selector(HomeViewController.likePressed(_:)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        
        let flipBack = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.flipBack(_:)))
        singleTap.numberOfTapsRequired = 1
        cell.flippedOverlay.tag = indexPath.row
        cell.flippedOverlay.isUserInteractionEnabled = true
        cell.flippedOverlay.addGestureRecognizer(flipBack)
        
        
        let likersButtonTapped = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.likersPressed(_:)))
        likersButtonTapped.numberOfTapsRequired = 1
        cell.btnLikers.tag = indexPath.row
        cell.btnLikers.isUserInteractionEnabled = true
        cell.btnLikers.addGestureRecognizer(likersButtonTapped)
        
        
        
        
        
        
        
        
        let commentsButtonTapped = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.commentsPressed(_:)))
        commentsButtonTapped.numberOfTapsRequired = 1
        cell.btnComments.tag = indexPath.row
        cell.btnComments.isUserInteractionEnabled = true
        cell.btnComments.addGestureRecognizer(commentsButtonTapped)
        
        cell.commentButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: #selector(HomeViewController.commentButtonPressed(_:)), for: .touchUpInside)
        
        cell.backgroundColor = UIColor.clear
        
        let detailsViewTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.detailsViewTapped(_:)))
        detailsViewTap.numberOfTapsRequired = 1
        cell.btnColorProfile.tag = indexPath.row
        cell.btnColorProfile.isUserInteractionEnabled = true
        cell.btnColorProfile.addGestureRecognizer(detailsViewTap)
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.profileTapped(_:)))
        profileTap.numberOfTapsRequired = 1
        cell.imgprofile!.tag = indexPath.row
        cell.imgprofile!.isUserInteractionEnabled = true
        cell.imgprofile!.addGestureRecognizer(profileTap)
        
        let userNameTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.profileTapped(_:)))
        userNameTap.numberOfTapsRequired = 1
        cell.lblUsername!.tag = indexPath.row
        cell.lblUsername!.isUserInteractionEnabled = true
        cell.lblUsername!.addGestureRecognizer(userNameTap)
        
        let bottomViewTap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.bottomViewTapped(_:)))
        bottomViewTap.numberOfTapsRequired = 1
        cell.bottomView!.tag = indexPath.row
        cell.bottomView!.isUserInteractionEnabled = true
        cell.bottomView!.addGestureRecognizer(bottomViewTap)
        
        //        cell.lblTitle!.addGestureRecognizer(bottomViewTap)
        if indexPath.row < cellStates.count {
            if cellStates[indexPath.row] == cellState.showComments {
                cell.lblComments.text = ""
                if color != nil {
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
        }
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollOffset = scrollView.contentOffset.y
        if scrollOffset < -15.0 {
            scrollOffset = -15.0 // -15.0 seems to be the contentOffset y at rest
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkForDisableScrolling(scrollView)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var navBarFrame = self.navigationController!.navigationBar.frame
        var tabBarFrame = self.tabBarController!.tabBar.frame
        var tabBarImageFrame = appDelegate.imagefooter!.frame
        let size = navBarFrame.size.height - 21
        var framePercentageHidden = ((STATUS_BAR_HEIGHT - navBarFrame.origin.y) / (navBarFrame.size.height - 1))
        let scrollOffset = scrollView.contentOffset.y
        let scrollDiff = scrollOffset - previousContentOffset
        let scrollHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        
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
        
        navigationController?.navigationBar.frame = navBarFrame
        tabBarController?.tabBar.frame = tabBarFrame
        appDelegate.imagefooter!.frame = tabBarImageFrame
        
        backgroundTopConstraint.constant = navBarFrame.origin.y - STATUS_BAR_HEIGHT
        tableViewTopConstraint.constant = navBarFrame.origin.y - STATUS_BAR_HEIGHT
        tableViewBottomConstraint.constant = 0
        view.layoutIfNeeded()
        
        // TODO: Hacky fix, need to redo
        if colors.count > 1 {
            updateBarButtonItems(1 - framePercentageHidden)
        }
        
        previousContentOffset = tableview!.contentOffset.y
        
        // pagination
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
            if self.addMoreData == true && self.additionalColors.count > 0 {
                self.colors += self.additionalColors
                self.cellStates += self.additionalCellStates
                self.tableview?.reloadData()
                if self.additionalColors.count == self.pageLimit {
                    self.getMoreData()
                } else {
                    self.addMoreData = false
                }
            }
        }
        //  }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate) {
            self.stoppedScrolling()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension HomeViewController: UIGestureRecognizerDelegate {
    
}

// MARK: - FBSDKAppInviteDialogDelegate
extension HomeViewController: FBSDKAppInviteDialogDelegate {
	/*!
	@abstract Sent to the delegate when the app invite encounters an error.
	@param appInviteDialog The FBSDKAppInviteDialog that completed.
	@param error The error.
	*/
	public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
		print("INVITE DIALOG FAILED: \(error)")
	}

    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print("INVITE DIALOG RESULTS: \(results)")
    }
}

// MARK: - TSLabelDelegate
extension HomeViewController: TSLabelDelegate {
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
}
