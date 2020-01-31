

import UIKit
import FBSDKShareKit
import ParseUI
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

class MyProfileVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, FBSDKAppInviteDialogDelegate {
    
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverPhotoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    var scrollFrameHeight:CGFloat?
    var previousContentOffset:CGFloat = 0.0
    let SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
    let SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
    let STATUS_BAR_HEIGHT: CGFloat = UIApplication.shared.statusBarFrame.height
    var tabBarImageFrame : CGRect!
    var navBarFrame : CGRect!
    var tabBarFrame : CGRect!
    //let label:UILabel
    
    var userName: UILabel?
    
    var label: UILabel?
    var followerscountline:UIView?
    var followerscountLbl: UILabel?
    var followersLbl: UILabel?
    
    
    var lovesline:UIView?
    var lovesLbl: UILabel?
    var lovesTextLbl: UILabel?
    

    var followingline:UIView?
    var followingLbl: UILabel?
    var followingtesxtLbl: UILabel?
    
    @IBOutlet weak var coverImageOverlay: UIView!
    
    var headerView : ProfileHeadercell?
    fileprivate let coverHeaderHeight: CGFloat = 139.0
    @IBOutlet var collectionView:UICollectionView?
    @IBOutlet var coverPhoto: PFImageView!
    var cellStates : [cellState] = []
    var data : [SColor] = []
    var isGrid : Bool?
    var overlayView : UIImageView!
    var colorQuery : PFQuery<PFObject>!
    var isLike = false
    fileprivate var isFirstLoad: Bool = false
    
    var comments: NSMutableDictionary = NSMutableDictionary()
    
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
        super.viewDidLoad()
        setupNavBar()
        isGrid = true
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileVC.addedComment(_:)), name: NSNotification.Name(rawValue: kCommentAdd), object: nil)
        
        // initialize overlayView  360
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabHeight = appDelegate.imagefooter!.frame.height - 5
        overlayView = UIImageView(frame: CGRect(x: 0, y: 360, width: self.view.width, height: self.view.height - 84 - tabHeight))
        
        collectionView?.register(UINib(nibName: "ProfileListCell", bundle: nil), forCellWithReuseIdentifier: "ProfileListCell")
        //overlayView.image = UIImage(named: "searchColorsBackground")
        //print("image: \(overlayView.image)")
        
        let overlayLabel = UILabel()
        overlayLabel.font = UIFont(name: "Avenir-Black", size: 14)
        overlayLabel.textColor = UIColor.white
        overlayLabel.textAlignment = NSTextAlignment.center
        overlayLabel.text = "To start adding colors please tap\nthe big circle below!"
        overlayLabel.numberOfLines = 2
        overlayLabel.sizeToFit()
        overlayLabel.top = 10
        overlayLabel.centerX = overlayView.width / 2
        
        overlayView.addSubview(overlayLabel)
        
        let arrowImgView = UIImageView(image:UIImage(named:"arrow_down"))
        arrowImgView.frame = CGRect(x: 0, y: 0, width: 22.5, height: 26.5)
        arrowImgView.top = overlayLabel.bottom
        arrowImgView.centerX = overlayView.width / 2
        arrowImgView.contentMode = UIViewContentMode.scaleAspectFit
        overlayView.addSubview(arrowImgView)

        collectionView?.addSubview(overlayView)
        collectionView?.backgroundColor = nil
        collectionView?.backgroundView = nil
        collectionView?.scrollsToTop = true
        collectionView?.scrollIndicatorInsets.top = 20.0
        isGrid = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileVC.reloadData), name: NSNotification.Name(rawValue: "ColorCreated"), object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MyProfileVC.resetNotificationsCount(_:)), name: "ResetNotificationsCount", object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MyProfileVC.colorDeletedSomewhere(_:)), name: NSNotification.Name(rawValue: "colorDeleted"), object: nil)
        isFirstLoad = true
        
        //Add insets so all content is shown
        if collectionView != nil{
            let tabBarInsets = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height + 100, 0)
            self.collectionView!.contentInset = tabBarInsets
            self.collectionView!.scrollIndicatorInsets = tabBarInsets
        }
        reloadData()
        
        navBarFrame = self.navigationController!.navigationBar.frame
        tabBarFrame = self.tabBarController!.tabBar.frame
        tabBarImageFrame = appDelegate.imagefooter!.frame
        
        [self .StrechView()];
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    func StrechView(){
        
        
        
        var str:NSString
        str="anbvcf"
        //str=(headerView?.nickLabel.text)!
        
        userName = UILabel(frame: CGRect(x: 0,y: 40,width: self.view.frame.size.width,height: 20))
        //label.center = CGPointMake(160, 284)
        userName!.text=str as String
        userName!.textColor=UIColor.white
        userName!.backgroundColor=UIColor.clear
        userName!.textAlignment=NSTextAlignment.center
        userName!.font = UIFont(name:"Helvetica-Bold",size:18.0)
        self.view!.addSubview(userName!)
        
        
        followerscountline = UIView(frame: CGRect(x: 0,y: userName!.frame.origin.y+userName!.frame.size.height+5,width: self.view.frame.size.width/3,height: 50))
        // label.center = CGPointMake(160, 284)
        followerscountline!.backgroundColor=UIColor.clear
        self.view!.addSubview(followerscountline!)
        
        
        
        let followinglinebottomBorder = CALayer()
        followinglinebottomBorder.frame = CGRect(x: followerscountline!.frame.size.width-2, y: 0,width: 1,height: followerscountline!.frame.size.height)
        followinglinebottomBorder.backgroundColor = UIColor.white.cgColor
        followerscountline!.layer.addSublayer(followinglinebottomBorder)
        
        
        followerscountLbl = UILabel(frame: CGRect(x: 0,y: 0,width: followerscountline!.frame.size.width,height: 20))
        //label.center = CGPointMake(160, 284)
        followerscountLbl!.text="1.4k"
        followerscountLbl!.textColor=UIColor.white
        followerscountLbl!.backgroundColor=UIColor.clear
        followerscountLbl!.textAlignment=NSTextAlignment.center
        followerscountLbl!.font = UIFont(name:"Helvetica-Bold",size:18.0)
        followerscountline!.addSubview(followerscountLbl!)
        
        followersLbl = UILabel(frame: CGRect(x: 0,y: followerscountLbl!.frame.origin.y+followerscountLbl!.frame.size.height,width: followerscountline!.frame.size.width,height: 20))
        //label.center = CGPointMake(160, 284)  lovesTextLbl
        followersLbl!.text="FOLLOWERS"
        followersLbl!.textColor=UIColor.white
        followersLbl!.backgroundColor=UIColor.clear
        followersLbl!.textAlignment=NSTextAlignment.center
        followersLbl!.font = UIFont(name:"Helvetica-Bold",size:16.0)
        followerscountline!.addSubview(followersLbl!)
        
        
        
        
        
        lovesline = UIView(frame: CGRect(x: followerscountline!.frame.origin.x+followerscountline!.frame.size.width,y: userName!.frame.origin.y+userName!.frame.size.height+5,width: self.view.frame.size.width/3,height: 50))
        // label.center = CGPointMake(160, 284)
        lovesline!.backgroundColor=UIColor.clear
        self.view!.addSubview(lovesline!)
        
        
        let loveslinebottomBorder = CALayer()
        loveslinebottomBorder.frame = CGRect(x: lovesline!.frame.size.width-2, y: 0,width: 1,height: lovesline!.frame.size.height)
        loveslinebottomBorder.backgroundColor = UIColor.white.cgColor
        lovesline!.layer.addSublayer(loveslinebottomBorder)
        
        
        
        
        
        lovesLbl = UILabel(frame: CGRect(x: 0,y: 0,width: lovesline!.frame.size.width,height: 20))
        //label.center = CGPointMake(160, 284)
        lovesLbl!.text="1.1k"
        lovesLbl!.textColor=UIColor.white
        lovesLbl!.backgroundColor=UIColor.clear
        lovesLbl!.textAlignment=NSTextAlignment.center
        lovesLbl!.font = UIFont(name:"Helvetica-Bold",size:18.0)
        lovesline!.addSubview(lovesLbl!)
        
        lovesTextLbl = UILabel(frame: CGRect(x: 0,y: lovesLbl!.frame.origin.y+lovesLbl!.frame.size.height,width: lovesline!.frame.size.width,height: 20))
        //label.center = CGPointMake(160, 284)  lovesTextLbl
        lovesTextLbl!.text="LOVES"
        lovesTextLbl!.textColor=UIColor.white
        lovesTextLbl!.backgroundColor=UIColor.clear
        lovesTextLbl!.textAlignment=NSTextAlignment.center
        lovesTextLbl!.font = UIFont(name:"Helvetica-Bold",size:16.0)
        lovesline!.addSubview(lovesTextLbl!)
        
        
        
        // var followingLbl: UILabel?
        // var followingtesxtLbl: UILabel?
        
        
        followingline = UIView(frame: CGRect(x: lovesline!.frame.origin.x+lovesline!.frame.size.width,y: userName!.frame.origin.y+userName!.frame.size.height+5,width: self.view.frame.size.width/3,height: 50))
        //label.center = CGPointMake(160, 284)
        followingline!.backgroundColor=UIColor.clear
        self.view!.addSubview(followingline!)
        
        
        
        
        followingLbl = UILabel(frame: CGRect(x: 0,y: 0,width: followingline!.frame.size.width,height: 20))
        //label.center = CGPointMake(160, 284)
        followingLbl!.text="1.2k"
        followingLbl!.textColor=UIColor.white
        followingLbl!.backgroundColor=UIColor.clear
        followingLbl!.textAlignment=NSTextAlignment.center
        followingLbl!.font = UIFont(name:"Helvetica-Bold",size:18.0)
        followingline!.addSubview(followingLbl!)
        
        followingtesxtLbl = UILabel(frame: CGRect(x: 0,y: followingLbl!.frame.origin.y+followingLbl!.frame.size.height,width: followingline!.frame.size.width,height: 20))
        //label.center = CGPointMake(160, 284)  lovesTextLbl
        followingtesxtLbl!.text="FOLLOWING"
        followingtesxtLbl!.textColor=UIColor.white
        followingtesxtLbl!.backgroundColor=UIColor.clear
        followingtesxtLbl!.textAlignment=NSTextAlignment.center
        followingtesxtLbl!.font = UIFont(name:"Helvetica-Bold",size:16.0)
        followingline!.addSubview(followingtesxtLbl!)
        
        
        
        
        followerscountLbl = UILabel(frame: CGRect(x: 0,y: 50,width: self.view.frame.size.width,height: 70))
        // label.center = CGPointMake(160, 284)
        followerscountLbl!.textAlignment = NSTextAlignment.center
        followerscountLbl!.text = "I'am a test label"
        followerscountLbl!.textColor=UIColor.red
        // followerscountLbl!.addSubview(label!)
        
        
        
        
        label = UILabel(frame: CGRect(x: 0,y: followingline!.frame.origin.y+followingline!.frame.size.height+4,width: self.view.frame.size.width,height: 70))
        // label.center = CGPointMake(160, 284)
        label!.textAlignment = NSTextAlignment.center
        label!.text = "I'am a test label dfsdghj kdhsgjkhsdjkghdsjkghs dkjghdjksghjdkshgjkdghj kdhgjkdhgjkdhgkjdhgjdh"
        label!.numberOfLines=7;
        followingtesxtLbl!.font = UIFont(name:"Helvetica-Bold",size:18.0)
        label!.textColor=UIColor.white
        self.view!.addSubview(label!)
        
 
        
        
        
    }
    
    func setupNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let titleView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 55.0, height: 30.0)
        self.navigationItem.titleView = titleView
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnInviteFriends"), style: .plain, target: self, action: #selector(MyProfileVC.inviteFriendsPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: #selector(MyProfileVC.settingsPressed))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.stoppedScrolling()
        
        label?.isHidden=true;
        followingline?.isHidden=true;
        lovesline?.isHidden=true;
        followerscountline?.isHidden=true;
        userName?.isHidden=true;
        
        headerView?.btnFollow.isHidden=false;
        headerView?.btngrid.isHidden=false;
        headerView?.nickLabel.isHidden=false;

        
        
     
        bringNavBarToOriginal()
        
         self.navigationController?.isNavigationBarHidden = true
        if headerView != nil {

//            self.headerView?.lblFollowers.text = "\(SFollow.currentFollowersCount())"
//            self.headerView?.lblFollowing.text = "\(SFollow.currentFollowingCount())"

            let notificationsQuery = PFQuery(className: "Notification")
            notificationsQuery.whereKey("toUser", equalTo: PFUser.current()!)
            notificationsQuery.whereKeyExists("fromUser")
            notificationsQuery.whereKey("fromUser", notEqualTo: NSNull())
            notificationsQuery.whereKey("seen", notEqualTo: NSNumber(value: true as Bool))
            notificationsQuery.countObjectsInBackground(block: { (count, error) -> Void in
                var countText = "\(count)"
                if count >= 99 {
                    countText = "99+"
                }
                self.headerView?.lblBadge.text = countText
                self.headerView?.lblBadge.isHidden = count <= 0
            })
            
            // Update current user cover image
            if let file = SUser.currentUser.coverImage {
                coverPhoto.file = file
				coverPhoto.load(inBackground: { (image, error) in
					self.coverPhoto.image = image
				})
            }
            
            // Update current user profile image
            headerView!.imgProfile?.image = UIImage(named: "default-post-user-photo")
            headerView!.imgProfile?.file = SUser.currentUser.imageFile
            headerView!.imgProfile?.load(inBackground: { (image, error) -> Void in
//                headerView!.imgProfile?.image = image
            })
            headerView!.imgProfile?.layer.masksToBounds = true
            headerView!.imgProfile?.layer.cornerRadius = (headerView!.imgProfile?.frame.width)! / 2
            
            //
            headerView!.nameLabel.text = SUser.currentUser.firstName + " " + SUser.currentUser.lastName
            headerView!.nickLabel.text = "@" + SUser.currentUser.username
            
            collectionView?.bringSubview(toFront: headerView!)

        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter!.isHidden = false
        tabBarController?.tabBar.isHidden = false
        
        
    }

    func reloadData() {
        if isFirstLoad {
            
            AppDelegate.showActivity()
        }
        
        let query = PFQuery(className: "Color")
        query.whereKey("createdBy", equalTo: PFUser.current()!)
        query.order(byDescending: "createdAt")
        
        self.data = []
        cellStates = []
        
        if colorQuery != nil {
            colorQuery.cancel()
        }
        
        colorQuery = query
        colorQuery.findObjectsInBackground { (array, error) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
                if (error == nil)
                {
                    for object in array! {
                        let color = SColor(data:object)
                        self.data.append(color)
                        self.createMapSnapshot(color, width: self.collectionView!.frame.width - 50.0, completion: nil)

                        self.cellStates.append(cellState.normal)
                    }
                    
                }
                
                DispatchQueue.main.async(execute: {
                    if self.data.count > 0 {
                        
                        self.overlayView.isHidden = true
                        
                    } else {
                        
                        self.overlayView.isHidden = false
                    }
                    AppDelegate.hideActivity()
                    self.collectionView?.reloadData()
                    self.isFirstLoad = false
                })
            })
        }
    }
    
    // MARK:- Actions
    
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
    
    @IBAction func gridButtonPressed(_ sender: AnyObject) {
//        print("gridButtonPressed")
//        isGrid = true
//        let inset = UIEdgeInsetsMake(0, 0, 0, 0)
//        collectionView?.contentInset = inset
//        collectionView?.reloadData()
        
        if(isGrid == true){
            
            print("gridButtonPressed")
            isGrid = false
            let inset = UIEdgeInsetsMake(0, 0, 0, 0)
            collectionView?.contentInset = inset
            collectionView?.reloadData()
            
        }
        else{
            
            print("listButtonPressed")
            isGrid = true
            let inset = UIEdgeInsetsMake(0, 0, 30, 0)
            collectionView?.contentInset = inset
            collectionView?.reloadData()
            
        }
        
    }
    
    
    @IBAction func listButtonPressed(_ sender: AnyObject) {
        print("listButtonPressed")
        isGrid = false
        let inset = UIEdgeInsetsMake(0, 0, 30, 0)
        collectionView?.contentInset = inset
        collectionView?.reloadData()
    }
    
    @IBAction func notificationButtonPressed(_ sender: UIButton){
        //animateNavBarTo(STATUS_BAR_HEIGHT)
        
        bringNavBarToOriginal()
        self.collectionView!.contentOffset.y = 0
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: kNotificationVCIdentifier) as! NotificationsVC
        vc.notificationsSeen = notificationsSeen
        
        let transition: CATransition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        
        let containerView:UIView = self.view.window!
        containerView.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func followersPressed(_ sender: AnyObject) {
        print("Saved Call")
        
        headerView?.followerBlueUnder.isHidden = false
        headerView?.followingRedUnder.isHidden = true
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
        
    }
    @IBAction func followingPressed(_ sender: AnyObject) {
        
        print("Loved Call")
        
        headerView?.followerBlueUnder.isHidden = true
        headerView?.followingRedUnder.isHidden = false
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "FollowingVC") as! FollowingVC
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
        
    }
    
    func productImageTapped(_ gr: UITapGestureRecognizer) {
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        if let snapshot = cell.color?.mapsnapShot {
            cellStates[item!] = cellState.normal
            self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadData()
                }, completion: { (completed) in

                    UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.showMap(_:)))
                        cell.snapshotView.addGestureRecognizer(tap)
                        cell.snapshotView.image = snapshot
                        cell.snapshotView.contentMode = .scaleAspectFill
                        cell.snapshotView.isHidden = false
                        cell.snapshotView.isUserInteractionEnabled = true
                        
                        cell.imgprofile?.isHidden = true
                        cell.flippedOverlay.isHidden = false
                        cell.bottomView.isHidden = true
                        cell.commentsView.isHidden = true
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
        likePressed(cell.btnLikeInCommentsView)
    }
    
    func detailsTapped(_ gr: UITapGestureRecognizer) {
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        if let snapshot = cell.color?.mapsnapShot {
            cellStates[item!] = cellState.normal
            self.collectionView?.performBatchUpdates({
                self.collectionView?.reloadData()
                }, completion: { (completed) in
                    
                    UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.showMap(_:)))
                        cell.snapshotView.addGestureRecognizer(tap)
                        cell.snapshotView.image = snapshot
                        cell.snapshotView.contentMode = .scaleAspectFill
                        cell.snapshotView.isHidden = false
                        cell.imgprofile?.isHidden = true
                        cell.flippedOverlay.isHidden = false
                        //cell.detailsView.hidden = true
                        self.cellStates[item!] = cellState.flipped
                    }) { (finished) -> Void in
                        
                    }
            })
            
        }else{
            UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
                cell.flippedOverlay.isHidden = false
                //cell.detailsView.hidden = true
                self.cellStates[item!] = cellState.flipped
                }) { (finished) -> Void in
                    
            }
        }
    }

    func likersPressed(_ gr: UITapGestureRecognizer) {
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: LikersVC = storyboard.instantiateViewController(withIdentifier: "LikersVC") as! LikersVC
        vc.color = cell.color
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    func likePressed(_ sender: UIButton) {
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as! ProfileListCell
        guard let color = cell.color else {
            return
        }
        
        //cell.productView.removeGestureRecognizer(cell.doubleTap)
        if isLike == true {
            return
        }
        isLike = true
        
        if cell.isLiked == false {
            
            let newLikesCount = NSInteger(cell.lbllikescount!.text!)! + 1
            cell.lbllikescount?.text = String(newLikesCount)
            
            cell.btnLikeInCommentsView.setTitle("", for: UIControlState())
            cell.btnLikeInCommentsView.isUserInteractionEnabled = false
            cell.likeActivityIndicator.isHidden = false
            cell.likeActivityIndicator.startAnimating()
            
            PFCloud.callFunction(inBackground: kCloudFuncAddLike, withParameters: [kParseKeyColorId: color.objectId!]) { (result, error) in
                guard error == nil, let _ = result else {
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
                    
                    cell.isLiked = false
                    cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                    //cell.productView.addGestureRecognizer(cell.doubleTap)
                    cell.btnLikeInCommentsView.isUserInteractionEnabled = true
                    cell.likeActivityIndicator.stopAnimating()
                    cell.likeActivityIndicator.isHidden = true
                    self.isLike = false
                    return
                }
                
                color.object?.fetchInBackground(block: { (colorObject, error) -> Void in
                    cell.btnLikeInCommentsView.isUserInteractionEnabled = true
                    cell.likeActivityIndicator.stopAnimating()
                    cell.likeActivityIndicator.isHidden = true
                    self.isLike = false
                    
                    guard error == nil, let colorObject = colorObject else {
                        cell.isLiked = false
                        cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                        return
                    }
                    
                    let newColor = SColor(data: colorObject)
                    self.data[sender.tag] = newColor
                    cell.lbllikescount?.text = "\(newColor.numLikes)"
                    cell.isLiked = true
                    cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                })
            }
        } else {
            let newLikesCount = NSInteger(cell.lbllikescount!.text!)! - 1
            cell.lbllikescount?.text = String(newLikesCount)
            
            cell.btnLikeInCommentsView.setTitle("", for: UIControlState())
            cell.btnLikeInCommentsView.isUserInteractionEnabled = false
            cell.likeActivityIndicator.isHidden = false
            cell.likeActivityIndicator.startAnimating()
            
            PFCloud.callFunction(inBackground: kCloudFuncRemoveLike, withParameters: [kParseKeyColorId: color.objectId!]) { (result, error) in
                guard error == nil, let _ = result else {
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
                    
                    cell.isLiked = true
                    cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                    // cell.productView.addGestureRecognizer(cell.doubleTap)
                    cell.btnLikeInCommentsView.isUserInteractionEnabled = true
                    cell.likeActivityIndicator.stopAnimating()
                    cell.likeActivityIndicator.isHidden = true
                    self.isLike = false
                    return
                }
                
                color.object?.fetchInBackground(block: { (colorObject, error) -> Void in
                    cell.btnLikeInCommentsView.isUserInteractionEnabled = true
                    cell.likeActivityIndicator.stopAnimating()
                    cell.likeActivityIndicator.isHidden = true
                    self.isLike = false
                    
                    guard error == nil, let colorObject = colorObject else {
                        cell.isLiked = true
                        cell.btnLikeInCommentsView.setTitle("UNLIKE", for: UIControlState())
                        return
                    }
                    
                    let newColor = SColor(data: colorObject)
                    self.data[sender.tag] = newColor
                    cell.lbllikescount?.text = "\(newColor.numLikes)"
                    cell.isLiked = false
                    cell.btnLikeInCommentsView.setTitle("LIKE", for: UIControlState())
                })
            }
        }
    }
    
    func commentsPressed(_ gr: UITapGestureRecognizer) {
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: CommentsVC = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        vc.color = cell.color
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    func commentButtonPressed(_ sender: UIButton) {
        let vc: CommentsVC = storyboard!.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        vc.color = data[sender.tag]
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    func addedComment(_ notification: Notification) {
        if let color = notification.object as? SColor {
            let row = colorExistsInArray(color)
            print("MyProfileVC addedComment(): colorExistsInArray: \(row) count: \(color.numComments)")
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
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        cell.snapshotView.isHidden = true
        cell.imgprofile!.isHidden = false
        
        UIView.transition(with: cell.contentView, duration: 0.6, options: UIViewAnimationOptions.transitionFlipFromRight, animations: { () -> Void in
            cell.flippedOverlay.isHidden = true
            //cell.commentsView.hidden = false
            self.cellStates[item!] = cellState.normal
            }) { (finished) -> Void in
                
        }
    }
    
    func detailsViewTapped(_ gr: UITapGestureRecognizer) {
        
        let item = gr.view?.tag
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: item!, section: 0)) as! ProfileListCell
        
        showFullColorProfileForColor(cell.color!)
    }
    
    func showColorDetailsView(_ color: SColor) {
        // move nav bar to it's original position
        bringNavBarToOriginal()
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ColorDetailsVC = storyboard.instantiateViewController(withIdentifier: "ColorDetailsVC") as! ColorDetailsVC
        vc.color = color
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    func showFullColorProfileForColor(_ color: SColor) {
//        bringNavBarToOriginal()
        animateNavBarTo(STATUS_BAR_HEIGHT)
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
        
        if self.cellStates[row!] == cellState.flipped && color.mapsnapShot != nil {
            // Do not allow the bottom view to be shown
            presentMap(row!)
            return
        }
        
        let cell: ProfileListCell = collectionView?.cellForItem(at: IndexPath(item: row!, section: 0)) as! ProfileListCell
        
        // get first 3 comments
        let commentsQuery = PFQuery(className: "Comment")
        commentsQuery.whereKey("color", equalTo: color.object!)
        commentsQuery.includeKey("user")
        commentsQuery.limit = 3
        commentsQuery.order(byAscending: "createdAt")
        
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
    
    // MARK:- UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: "ProfileHeadercell", for: indexPath)
                as? ProfileHeadercell
            
            if let file = SUser.currentUser.coverImage {
                coverPhoto.file = file
                coverPhoto.load(inBackground: { (image, error) in
//                    self.coverPhoto.image = image
                })
            }
            
            let header = headerView!
            header.imgProfile?.image = UIImage(named: "default-profile")
            header.imgProfile?.file = SUser.currentUser.imageFile
            header.imgProfile?.load(inBackground: { (image, error) -> Void in
//                header.imgProfile?.image = image
            })
            
//                header.lblFollowers.text = "\(SFollow.currentFollowersCount())"
//                header.lblFollowing.text = "\(SFollow.currentFollowingCount())"
            
            let notificationsQuery = PFQuery(className: "Notification")
            notificationsQuery.whereKey("toUser", equalTo: PFUser.current()!)
            notificationsQuery.whereKeyExists("fromUser")
            notificationsQuery.whereKey("fromUser", notEqualTo: NSNull())
            notificationsQuery.whereKey("seen", notEqualTo: NSNumber(value: true as Bool))
            notificationsQuery.countObjectsInBackground(block: { (count, error) -> Void in
                var countText = "\(count)"
                if count >= 99 {
                    countText = "99+"
                }
                header.lblBadge.text = countText
                header.lblBadge.isHidden = count <= 0
            })
            
            header.imgProfile?.layer.masksToBounds = true
            header.imgProfile?.layer.cornerRadius = (header.imgProfile?.frame.width)! / 2
            header.imgProfile?.layer.borderWidth = 2.5
            header.imgProfile?.layer.borderColor = UIColor.white.cgColor
            header.nameLabel.text = SUser.currentUser.firstName + " " + SUser.currentUser.lastName
            header.nickLabel.text = "@" + SUser.currentUser.username
//            header.lblFollowing.text = "\(SFollow.currentFollowing().count)"
            
            
            
            
            if isGrid == true {
                headerView?.btngrid?.isSelected = true
                headerView?.btnlist?.isSelected = false
            }
            else{
                headerView?.btngrid?.isSelected = false
                headerView?.btnlist?.isSelected = true
            }
            
//            headerView!.btnlist.imageView?.contentMode = UIViewContentMode.Center  NOTIFICATIONS
//            headerView!.btngrid.imageView?.contentMode = UIViewContentMode.Center
            
            headerView!.btngrid.addTarget(self, action: #selector(MyProfileVC.gridButtonPressed(_:)), for: .touchUpInside)
            headerView!.btnlist.addTarget(self, action: #selector(MyProfileVC.listButtonPressed(_:)), for: .touchUpInside)
            
            let followTitle = NSMutableAttributedString(string: "")
            followTitle.addAttribute(NSKernAttributeName, value: 3, range: NSMakeRange(0, followTitle.length))
            followTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, followTitle.length))
            headerView?.btnFollow.setAttributedTitle(followTitle, for: UIControlState())
            
//            headerView?.btngrid.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
//            headerView?.btnlist.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            
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
            if indexPath.row < data.count{
                let color : SColor = data[indexPath.item]
                collectionViewCell.color = color
            }
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
            if indexPath.item > cellStates.count {
                //collectionViewCell.detailsView.hidden = true
                collectionViewCell.flippedOverlay.isHidden = true
                collectionViewCell.commentsView.isHidden = true
            }else{
                switch cellStates[indexPath.item] {
                case cellState.normal:
                    //collectionViewCell.detailsView.hidden = true
                    collectionViewCell.flippedOverlay.isHidden = true
                    collectionViewCell.commentsView.isHidden = true
                case cellState.flipped:
                    collectionViewCell.flippedOverlay.isHidden = false
                    //collectionViewCell.detailsView.hidden = true
                    collectionViewCell.commentsView.isHidden = true
                case cellState.showComments:
                    //collectionViewCell.detailsView.hidden = false
                    collectionViewCell.flippedOverlay.isHidden = true
                    collectionViewCell.commentsView.isHidden = false
                default:
                    //collectionViewCell.detailsView.hidden = false
                    collectionViewCell.flippedOverlay.isHidden = true
                    collectionViewCell.commentsView.isHidden = true
                }
            }
            
            let color : SColor = data[indexPath.item]
            collectionViewCell.color = color
            
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
                let tap = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.showMap(_:)))
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
            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.productImageTapped(_:)))
            singleTap.numberOfTapsRequired = 1
            collectionViewCell.productView.tag = indexPath.item
            collectionViewCell.productView?.isUserInteractionEnabled = true
            collectionViewCell.productView?.addGestureRecognizer(singleTap)
            if collectionViewCell.doubleTap != nil {
                collectionViewCell.productView.removeGestureRecognizer(collectionViewCell.doubleTap)
            }
            
                collectionViewCell.doubleTap = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.productImageTappedTwice(_:)))
                collectionViewCell.doubleTap.numberOfTapsRequired = 2
                collectionViewCell.productView?.addGestureRecognizer(collectionViewCell.doubleTap)
                singleTap.require(toFail: collectionViewCell.doubleTap)
            
//            let detailsTap = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.detailsTapped(_:)))
            singleTap.numberOfTapsRequired = 1
            //collectionViewCell.detailsView.tag = indexPath.item
            //collectionViewCell.detailsView.userInteractionEnabled = true
            //collectionViewCell.detailsView.addGestureRecognizer(detailsTap)
            
            let flipBack = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.flipBack(_:)))
            singleTap.numberOfTapsRequired = 1
            collectionViewCell.flippedOverlay.tag = indexPath.item
            collectionViewCell.flippedOverlay.isUserInteractionEnabled = true
            collectionViewCell.flippedOverlay.addGestureRecognizer(flipBack)
            
            let likersButtonTapped = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.likersPressed(_:)))
            likersButtonTapped.numberOfTapsRequired = 1
            collectionViewCell.btnLikers.tag = indexPath.item
            collectionViewCell.btnLikers.isUserInteractionEnabled = true
            collectionViewCell.btnLikers.addGestureRecognizer(likersButtonTapped)
            
            collectionViewCell.btnLikeInCommentsView.tag = indexPath.row
            collectionViewCell.btnLikeInCommentsView.addTarget(self, action: #selector(MyProfileVC.likePressed(_:)), for: .touchUpInside)
            
            let commentsButtonTapped = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.commentsPressed(_:)))
            commentsButtonTapped.numberOfTapsRequired = 1
            collectionViewCell.btnComments.tag = indexPath.item
            collectionViewCell.btnComments.isUserInteractionEnabled = true
            collectionViewCell.btnComments.addGestureRecognizer(commentsButtonTapped)
            
            collectionViewCell.btnCommentsInCommentsView.tag = indexPath.row
            collectionViewCell.btnCommentsInCommentsView.addTarget(self, action: #selector(MyProfileVC.commentButtonPressed(_:)), for: .touchUpInside)
            
            let detailsViewTap = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.detailsViewTapped(_:)))
            detailsViewTap.numberOfTapsRequired = 1
            collectionViewCell.btnColorProfile.tag = indexPath.item
            collectionViewCell.btnColorProfile.isUserInteractionEnabled = true
            collectionViewCell.btnColorProfile.addGestureRecognizer(detailsViewTap)
            //if collectionViewCell.color?.mapsnapShot == nil {
                let bottomViewTap = UITapGestureRecognizer(target: self, action: #selector(MyProfileVC.bottomViewTapped(_:)))
                bottomViewTap.numberOfTapsRequired = 1
                collectionViewCell.bottomView!.tag = indexPath.row
                collectionViewCell.bottomView!.isUserInteractionEnabled = true
                collectionViewCell.bottomView!.addGestureRecognizer(bottomViewTap)
            //}
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
        bringNavBarToOriginal()

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
        self.view.layoutIfNeeded()
        self.updateBarButtonItems(1)
        
        let color = self.data[row]
        // Do not allow the bottom view to be shown
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vc.geopoint = color.geopoint
        vc.locationName = color.locationName
        self.navigationController?.pushViewController(vc, animated: true)
        //}
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
    
    // MARK: - memory management methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCoverPhoto(_ y: CGFloat) {
        var coverRect = CGRect(x: 0, y: y, width: self.view.bounds.width, height: coverHeaderHeight)
        coverImageOverlay.isHidden = true
        if(collectionView?.contentOffset.y < 0) {
            coverRect.size.height -= collectionView!.contentOffset.y
            coverRect.size.width -= collectionView!.contentOffset.y
            coverImageOverlay.isHidden = false
        }
        coverPhoto.frame = coverRect
        
        let statusbarHeight = UIApplication.shared.statusBarFrame.size.height

        coverImageOverlay.frame = CGRect(x: 0, y: 0, width: coverRect.width, height: coverRect.height+statusbarHeight+10)
        
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
        
        //userName
        
       
        followingline?.isHidden=false;
        lovesline?.isHidden=false;
        followerscountline?.isHidden=false;
        label?.isHidden=false;
         userName?.isHidden=false;
        
        headerView?.btnFollow.isHidden=true;
        headerView?.btngrid.isHidden=true;
        //headerView?.nameLabel.hidden=true;
        headerView?.nickLabel.isHidden=true;
        
        
        
        
        if (navBarFrame.origin.y == 20 && scrollView.contentSize.height < (scrollView.frame.size.height + navBarFrame.size.height)) {
            updateCoverPhoto(navBarFrame.origin.y - STATUS_BAR_HEIGHT)
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
        self.coverPhotoTopConstraint.constant = navBarFrame.origin.y - STATUS_BAR_HEIGHT
        self.view.layoutIfNeeded()
        self.updateBarButtonItems(1 - framePercentageHidden)
        self.previousContentOffset = self.collectionView!.contentOffset.y
        updateCoverPhoto(navBarFrame.origin.y - STATUS_BAR_HEIGHT)
        
        
        
//        var str:NSString
//        
//        str=(headerView?.nickLabel.text)!
//        
//        userName = UILabel(frame: CGRectMake(0,40,self.view.frame.size.width,20))
//        //label.center = CGPointMake(160, 284)
//        userName!.text=str as String
//        userName!.textColor=UIColor.whiteColor()
//        userName!.backgroundColor=UIColor.clearColor()
//        userName!.textAlignment=NSTextAlignment.Center
//        userName!.font = UIFont(name:"Helvetica-Bold",size:18.0)
//        self.view!.addSubview(userName!)
//
//        
//        followerscountline = UIView(frame: CGRectMake(0,userName!.frame.origin.y+userName!.frame.size.height+5,self.view.frame.size.width/3,50))
//        // label.center = CGPointMake(160, 284)
//        followerscountline!.backgroundColor=UIColor.clearColor()
//        self.view!.addSubview(followerscountline!)
//        
//
//        
//        let followinglinebottomBorder = CALayer()
//        followinglinebottomBorder.frame = CGRectMake(followerscountline!.frame.size.width-2, 0,1,followerscountline!.frame.size.height)
//        followinglinebottomBorder.backgroundColor = UIColor.whiteColor().CGColor
//        followerscountline!.layer.addSublayer(followinglinebottomBorder)
//        
//        
//        followerscountLbl = UILabel(frame: CGRectMake(0,0,followerscountline!.frame.size.width,20))
//        //label.center = CGPointMake(160, 284)
//        followerscountLbl!.text="1.4k"
//        followerscountLbl!.textColor=UIColor.whiteColor()
//        followerscountLbl!.backgroundColor=UIColor.clearColor()
//        followerscountLbl!.textAlignment=NSTextAlignment.Center
//        followerscountLbl!.font = UIFont(name:"Helvetica-Bold",size:18.0)
//        followerscountline!.addSubview(followerscountLbl!)
//        
//        followersLbl = UILabel(frame: CGRectMake(0,followerscountLbl!.frame.origin.y+followerscountLbl!.frame.size.height,followerscountline!.frame.size.width,20))
//        //label.center = CGPointMake(160, 284)  lovesTextLbl
//        followersLbl!.text="FOLLOWERS"
//        followersLbl!.textColor=UIColor.whiteColor()
//        followersLbl!.backgroundColor=UIColor.clearColor()
//        followersLbl!.textAlignment=NSTextAlignment.Center
//        followersLbl!.font = UIFont(name:"Helvetica-Bold",size:16.0)
//        followerscountline!.addSubview(followersLbl!)
//        
//        
//        
//        
//        
//        lovesline = UIView(frame: CGRectMake(followerscountline!.frame.origin.x+followerscountline!.frame.size.width,userName!.frame.origin.y+userName!.frame.size.height+5,self.view.frame.size.width/3,50))
//        // label.center = CGPointMake(160, 284)
//        lovesline!.backgroundColor=UIColor.clearColor()
//        self.view!.addSubview(lovesline!)
//        
//        
//        let loveslinebottomBorder = CALayer()
//        loveslinebottomBorder.frame = CGRectMake(lovesline!.frame.size.width-2, 0,1,lovesline!.frame.size.height)
//        loveslinebottomBorder.backgroundColor = UIColor.whiteColor().CGColor
//        lovesline!.layer.addSublayer(loveslinebottomBorder)
//        
//       
//        
//        
//        
//        lovesLbl = UILabel(frame: CGRectMake(0,0,lovesline!.frame.size.width,20))
//        //label.center = CGPointMake(160, 284)
//        lovesLbl!.text="1.1k"
//        lovesLbl!.textColor=UIColor.whiteColor()
//        lovesLbl!.backgroundColor=UIColor.clearColor()
//        lovesLbl!.textAlignment=NSTextAlignment.Center
//        lovesLbl!.font = UIFont(name:"Helvetica-Bold",size:18.0)
//        lovesline!.addSubview(lovesLbl!)
//        
//        lovesTextLbl = UILabel(frame: CGRectMake(0,lovesLbl!.frame.origin.y+lovesLbl!.frame.size.height,lovesline!.frame.size.width,20))
//        //label.center = CGPointMake(160, 284)  lovesTextLbl
//        lovesTextLbl!.text="LOVES"
//        lovesTextLbl!.textColor=UIColor.whiteColor()
//        lovesTextLbl!.backgroundColor=UIColor.clearColor()
//        lovesTextLbl!.textAlignment=NSTextAlignment.Center
//        lovesTextLbl!.font = UIFont(name:"Helvetica-Bold",size:16.0)
//        lovesline!.addSubview(lovesTextLbl!)
//        
//        
//        
//        // var followingLbl: UILabel?
//        // var followingtesxtLbl: UILabel?
//        
//        
//       followingline = UIView(frame: CGRectMake(lovesline!.frame.origin.x+lovesline!.frame.size.width,userName!.frame.origin.y+userName!.frame.size.height+5,self.view.frame.size.width/3,50))
//        //label.center = CGPointMake(160, 284)
//        followingline!.backgroundColor=UIColor.clearColor()
//        self.view!.addSubview(followingline!)
//        
//        
//        
//        
//        followingLbl = UILabel(frame: CGRectMake(0,0,followingline!.frame.size.width,20))
//        //label.center = CGPointMake(160, 284)
//        followingLbl!.text="1.2k"
//        followingLbl!.textColor=UIColor.whiteColor()
//        followingLbl!.backgroundColor=UIColor.clearColor()
//        followingLbl!.textAlignment=NSTextAlignment.Center
//        followingLbl!.font = UIFont(name:"Helvetica-Bold",size:18.0)
//        followingline!.addSubview(followingLbl!)
//        
//        followingtesxtLbl = UILabel(frame: CGRectMake(0,followingLbl!.frame.origin.y+followingLbl!.frame.size.height,followingline!.frame.size.width,20))
//        //label.center = CGPointMake(160, 284)  lovesTextLbl
//        followingtesxtLbl!.text="FOLLOWING"
//        followingtesxtLbl!.textColor=UIColor.whiteColor()
//        followingtesxtLbl!.backgroundColor=UIColor.clearColor()
//        followingtesxtLbl!.textAlignment=NSTextAlignment.Center
//        followingtesxtLbl!.font = UIFont(name:"Helvetica-Bold",size:16.0)
//        followingline!.addSubview(followingtesxtLbl!)
//      
//        
//        
//        
//        followerscountLbl = UILabel(frame: CGRectMake(0,50,self.view.frame.size.width,70))
//        // label.center = CGPointMake(160, 284)
//        followerscountLbl!.textAlignment = NSTextAlignment.Center
//        followerscountLbl!.text = "I'am a test label"
//        followerscountLbl!.textColor=UIColor.redColor()
//       // followerscountLbl!.addSubview(label!)
//        
//        
//        
//    
//        label = UILabel(frame: CGRectMake(0,followingline!.frame.origin.y+followingline!.frame.size.height+4,self.view.frame.size.width,70))
//       // label.center = CGPointMake(160, 284)
//        label!.textAlignment = NSTextAlignment.Center
//        label!.text = "I'am a test label dfsdghj kdhsgjkhsdjkghdsjkghs dkjghdjksghjdkshgjkdghj kdhgjkdhgjkdhgkjdhgjdh"
//        label!.numberOfLines=7;
//        followingtesxtLbl!.font = UIFont(name:"Helvetica-Bold",size:18.0)
//        label!.textColor=UIColor.whiteColor()
//        self.view!.addSubview(label!)
//        
        
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.stoppedScrolling()
        label?.isHidden=true;
        followingline?.isHidden=true;
        lovesline?.isHidden=true;
        followerscountline?.isHidden=true;
        userName?.isHidden=true;
        
        headerView?.btnFollow.isHidden=false;
        headerView?.btngrid.isHidden=false;
        headerView?.nickLabel.isHidden=false;
        
        
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
        
        
        label?.isHidden=true;
        followingline?.isHidden=true;
        lovesline?.isHidden=true;
        followerscountline?.isHidden=true;
        userName?.isHidden=true;
        
        headerView?.btnFollow.isHidden=false;
        headerView?.btngrid.isHidden=false;
        headerView?.nickLabel.isHidden=false;

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
            self.coverPhotoTopConstraint.constant = -navBarFrame.height
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
            self.coverPhotoTopConstraint.constant = navBarFrame.origin.y - self.STATUS_BAR_HEIGHT
            
            self.updateBarButtonItems(1.0)
        })
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print("INVITE DIALOG RESULTS: \(results)")
    }
	
	public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("INVITE DIALOG FAILED: \(error)")
    }
    
    // MARK: - Notifications
//    func resetNotificationsCount(notification: NSNotification) {
//        headerView?.lblBadge.text = "0"
//        headerView?.lblBadge.hidden = true
//    }
    
    func colorDeletedSomewhere(_ notification: Notification) {
        let color = notification.object as? SColor
        
        print(colorExistsInArray(color!))
        let index = colorExistsInArray(color!)
        if(index >= 0) {
            // Deleted color is in array
            
            // Remove it from array
            self.data.remove(at: index)
            self.cellStates.remove(at: index)
            
            if self.data.count > 0 {
                self.overlayView.isHidden = true
            } else {
                self.overlayView.isHidden = false
            }
            // Reload collectionview
            collectionView?.reloadData()
        }
    }
    
    // MARK: - Callback functions
    func notificationsSeen(_ count: Int) {
        if let badgeCount = headerView?.lblBadge.text {
            if var badgeCount = Int(badgeCount) {
                badgeCount -= count
                if badgeCount < 0 {
                    badgeCount = 0
                }
                
                var countText = "\(badgeCount)"
                if badgeCount >= 99 {
                    countText = "99+"
                }
                self.headerView?.lblBadge.text = countText
                self.headerView?.lblBadge.isHidden = badgeCount <= 0
            }
        }
    }
}
