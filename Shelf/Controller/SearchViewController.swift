

import UIKit
import ParseFacebookUtilsV4
import FBSDKShareKit
import Firebase
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


class SearchViewController: UIViewController  {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewObject:UIButton?
    //@IBOutlet weak var ghgjgj: UIView!
    
    var headerView: SearchHeaderCell?
    var scrollFrameHeight:CGFloat?
    var previousContentOffset:CGFloat = 0.0
    let SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
    let SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
    let STATUS_BAR_HEIGHT: CGFloat = UIApplication.shared.statusBarFrame.height
    var data : [SColor] = []
    var overlayView : UIImageView!
    var searchString: String = ""
    var mostRecentQuery : PFQuery<PFObject>?
    var additionalData : [SColor] = []
    var page : Int = 0
    let pageLimit : Int = 18
    var addMoreData : Bool = false
   
   // @IBOutlet var backview: [UIView]!
    //@IBOutlet weak var backview: UIView!
   // @IBOutlet weak var bottomView: UIView!
    // search People View
    var searchPeopleVC : SearchPeopleViewController?
    
    var searchPeopleView : UIView {
        
        get {
            if searchPeopleVC == nil {
                
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                searchPeopleVC = storyboard.instantiateViewController(withIdentifier: "SearchPeopleViewController") as? SearchPeopleViewController
                searchPeopleVC?.delegate = self
                addChildViewController(searchPeopleVC!)
            }
            return searchPeopleVC!.view
        }
    }

    // MARK: - View Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.  52536f
        //self.view.backgroundColor=UIColorFromRGB(0x4c4d68)
       // collectionView.backgroundColor=UIColorFromRGB(0x4c4d68)
        
        let headerView=UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width,height: 30))
//        headerView.backgroundColor=UIColorFromRGB(0x43435d)
        headerView.backgroundColor=UIColorFromRGB(0x41405B)
        //headerView.layer.cornerRadius=25
        //headerView.layer.borderWidth=2
        self.view.addSubview(headerView)
        
        
        
       // SearchHeaderCell.backgroundColor=UIColorFromRGB(0x4c4d68)
       // self.view.backgroundColor=UIColor.blueColor()
       // self.view.alpha=2;
        
        setupNavBar()
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        dismissKeyboard.numberOfTapsRequired = 1
        dismissKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboard)
        
        scrollFrameHeight = self.collectionView!.frame.height
        
        searchPeopleView.frame = self.view.bounds
        searchPeopleView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        searchPeopleView.isHidden = false
		view.insertSubview(searchPeopleView, belowSubview: headerView)
//        view.addSubview(searchPeopleView)
		
        
        
        // initialize overlayView
        let screenHeight = UIScreen.main.bounds.height
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var tabBarOffset: CGFloat = 10.5
        if screenHeight == 667 {
            tabBarOffset = 12.5
        } else if screenHeight == 736 {
           // tabBarOffset = 14.0
             tabBarOffset = 20.0
        }
        let tabHeight = appDelegate.imagefooter!.frame.height - tabBarOffset
        let sbHeight = UIApplication.shared.statusBarFrame.size.height
        let nbHeight = self.navigationController?.navigationBar.frame.size.height
        let searchBarHeight : CGFloat = 40 + 26
        overlayView = UIImageView(frame: CGRect(x: 0, y: searchBarHeight+70  , width: self.view.width, height: self.view.height - (searchBarHeight) - tabHeight - sbHeight - nbHeight! ))
        //overlayView.contentMode = .ScaleAspectFit
        var imageName = "SearchPeopleBackground"
        //overlayView.hidden=true;
        getDeviceBackgroundImageName(&imageName)
        overlayView.image = UIImage(named:imageName)
        //view.sendSubviewToBack(overlayView)
        //view.bringSubviewToFront(searchView)
        
        overlayView.isUserInteractionEnabled=true
        
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.handleTap))
        //  tap.delegate = self
        overlayView.addGestureRecognizer(tap)
        
        
        let arrowImgView = UIImageView(image:UIImage(named:"arrow_up"))
        arrowImgView.sizeToFit()
        arrowImgView.top = 30
        arrowImgView.centerX = overlayView!.width / 2
        arrowImgView.autoresizingMask = [UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleBottomMargin]
        //overlayView?.addSubview(arrowImgView)
        
        
       // self.imageViewObject :UIImageView
        
        self.imageViewObject = UIButton(frame:CGRect(x: (self.view.frame.size.width-274)/2,y: self.view.frame.size.height+200,width: 274,height: 148))
        
        let image = UIImage(named: "SearchImage") as UIImage?
        imageViewObject!.setImage(image, for: UIControlState())
        
        //self.imageViewObject!.image = UIImage(named:"SearchImage")
        
        overlayView.addSubview(self.imageViewObject!)

        self.imageViewObject!.isUserInteractionEnabled=true
        
        UIView.animate(withDuration: 1.0, animations: {
            self.imageViewObject?.frame = CGRect(x: (self.view.frame.size.width-274)/2,y: 10,width: 274,height: 148)
        })
        
        
//        let soundGoodbutton = UIButton(frame: CGRect(x: imageViewObject!.frame.size.width/2-50, y: imageViewObject!.frame.size.height-60, width: 100, height: 50))
//        soundGoodbutton.backgroundColor = .greenColor()
//        soundGoodbutton.setTitle("", forState: .Normal)
//        soundGoodbutton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
//        imageViewObject!.addSubview(soundGoodbutton)
        
        
        
        
        let soundGoodbutton = UIButton(frame: CGRect(x: imageViewObject!.frame.size.width/2-70, y: imageViewObject!.frame.size.height-60, width: 140, height: 50))
        //soundGoodbutton.backgroundColor = .clearcolor()
        soundGoodbutton.setTitle("", for: UIControlState())
        soundGoodbutton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        imageViewObject!.addSubview(soundGoodbutton)
        
        
        
        
        let alertbackView=UIView(frame: CGRect(x: 30,y: 50, width: self.view.frame.size.width-60,height: 140))
        alertbackView.backgroundColor=UIColorFromRGB(0x43435d)
        //headerView.layer.cornerRadius=25
        //headerView.layer.borderWidth=2  To discover colors and other members to follow search here!
       // overlayView.addSubview(alertbackView)
        
        
        let overlayLabel = UILabel()
        overlayLabel.font = UIFont(name: "Avenir-Black", size: 13)
        overlayLabel.textColor = UIColor.white
        overlayLabel.textAlignment = NSTextAlignment.center
       // overlayLabel.text = "Search for either colors or people\nusing search field above!"
        
        if screenHeight == 667 {
            
           overlayLabel.numberOfLines = 2
           overlayLabel.text = "To discover colors and other members\n to follow search here!"
            
        } else if screenHeight == 736 {
            
            overlayLabel.numberOfLines = 2
           overlayLabel.text = "To discover colors and other members\n to follow search here!"
            
        }
        else{
            
           overlayLabel.numberOfLines = 3
           overlayLabel.text = "To discover colors\n and other members to \n follow search here!"
        }
        
        overlayLabel.sizeToFit()
        overlayLabel.top = alertbackView.top-25
        overlayLabel.centerX = alertbackView.width / 2

       // alertbackView.addSubview(overlayLabel)
        
        let myFirstButton = UIButton()
        myFirstButton.setTitle("SOUNDS GOOD", for: UIControlState())
        myFirstButton.setTitleColor(UIColor.white, for: UIControlState())
        myFirstButton.frame = CGRect(x: alertbackView.frame.size.width/2-80,y: alertbackView.frame.size.height-55, width: 160, height: 40)
        myFirstButton.backgroundColor=UIColorFromRGB(0xfbbc6f)
        myFirstButton.layer.cornerRadius=3;
      //  myFirstButton.addTarget(self, action: "pressed", forControlEvents: .TouchUpInside)
       /// alertbackView.addSubview(myFirstButton)
        
        
        
        self.view.addSubview(overlayView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.colorDeletedSomewhere(_:)), name: NSNotification.Name(rawValue: "colorDeleted"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        updateBarButtonItems(1.0)
        
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
    func handleTap() {
        
        print("tap working")
        
        UIView.animate(withDuration: 1.0, animations: {
            self.imageViewObject?.frame = CGRect(x: self.view.frame.size.width+200,y: 10,width: 274,height: 148)
        })
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(moveRightImage), userInfo: nil, repeats: false)
        
        // view1.alpha = 0.1
        headerView?.searchField.resignFirstResponder()
        searchPeopleVC?.searchBar.resignFirstResponder()
        
    }

    
    func buttonAction(_ sender: UIButton!) {
        print("Button tapped")
        UIView.animate(withDuration: 1.0, animations: {
            self.imageViewObject?.frame = CGRect(x: self.view.frame.size.width+200,y: 10,width: 274,height: 148)
        })
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(moveRightImage), userInfo: nil, repeats: false)
    }
    
    func moveRightImage() {
        self.imageViewObject?.removeFromSuperview()
        
    }
    
    // MARK: - Setup helper functions
    func setupNavBar() {
        
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        let titleView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 55.0, height: 30.0)
        self.navigationItem.titleView = titleView
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnInviteFriends"), style: .plain, target: self, action: #selector(SearchViewController.inviteFriendsPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: #selector(SearchViewController.settingsPressed))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
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
    
    // Network API
    func reloadData() {
        page = 0
        // show/hide overlay, perform query to parse.com and fetch data
        overlayView.isHidden =  headerView != nil && headerView!.searchField.text!.characters.count > 0
        if headerView != nil && headerView!.searchField.text!.characters.count > 0 {
            AppDelegate.showActivity()
            AnalyticsHelper.sendCustomEvent(kFIREventSearch)
            
            let query1 = PFQuery(className: "Color")
            query1.whereKey("searchText", contains: headerView?.searchField.text!.lowercased())

            let query2 = PFQuery(className: "Color")
            query2.whereKey("comment", contains: headerView?.searchField.text!.lowercased())
            
            let query = PFQuery.orQuery(withSubqueries: [query1, query2])
            query.limit = pageLimit
            query.skip = pageLimit * page
            
            if mostRecentQuery != nil {
                mostRecentQuery?.cancel()
                mostRecentQuery = nil
            }
            
            mostRecentQuery = query
            query.findObjectsInBackground{ (array, error) -> Void in
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.data = []
                    if (error == nil)
                    {
                        for object in array! {
                            self.data.append(SColor(data: object))
                        }
                        self.page += 1
                        if self.data.count >= self.pageLimit {
                            self.getMoreData()
                            self.addMoreData = true
                        } else {
                            self.addMoreData = false
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        AppDelegate.hideActivity()
                        self.collectionView.reloadData()
//                        self.collectionView.reloadSections(NSIndexSet(index: 0))
                        self.headerView?.searchField.becomeFirstResponder()
                        AnalyticsHelper.sendCustomEvent(kFIREventViewSearchResults)
                    })
                    
                })
            }
        } else {
            data = []
            additionalData = []
            self.collectionView.collectionViewLayout.invalidateLayout()
        }

    }
    
    func getMoreData() {
        print("getMoreData: \(page)")
        let query1 = PFQuery(className: "Color")
        query1.whereKey("searchText", contains: headerView?.searchField.text!.lowercased())
        
        let query2 = PFQuery(className: "Color")
        query2.whereKey("comment", contains: headerView?.searchField.text!.lowercased())
        
        let query = PFQuery.orQuery(withSubqueries: [query1, query2])
        query.limit = pageLimit
        query.skip = pageLimit * page
        
        if mostRecentQuery != nil {
            mostRecentQuery?.cancel()
            mostRecentQuery = nil
        }
        
        mostRecentQuery = query
        query.findObjectsInBackground{ (array, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.additionalData = []
                if (error == nil) {
                    for object in array! {
                        self.additionalData.append(SColor(data: object))
                    }
                    self.page += 1
                }
                
            })
        }
    }
    
    //MARK: - GUI Callbacks
    @IBAction func onShowPeopleSearch(_ sender: AnyObject) {
        
        var imageName = "SearchPeopleBackground"
       // var imageName = ""

        //imageName.hidden=true
        getDeviceBackgroundImageName(&imageName)
        overlayView.image = UIImage(named: imageName)
        //overlayView.hidden=true;
        
        overlayView.isHidden = searchPeopleVC!.searchBar.text!.characters.count > 0
        scrollViewDidScroll(searchPeopleVC!.tableView)
        searchPeopleView.isHidden = false
        collectionView.isHidden = true
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
       self.view.endEditing(true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
        
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
        
//        navigationController?.navigationBar.frame = navBarFrame
        tabBarController?.tabBar.frame = tabBarFrame
        appDelegate.imagefooter!.frame = tabBarImageFrame
        
        updateBarButtonItems(1 - framePercentageHidden)
        
        if scrollView == collectionView {
            backgroundTopConstraint.constant = navBarFrame.origin.y - STATUS_BAR_HEIGHT
            collectionViewTopConstraint.constant = navBarFrame.origin.y - STATUS_BAR_HEIGHT
            collectionViewBottomConstraint.constant = 0
            
            view.layoutIfNeeded()
            previousContentOffset = collectionView!.contentOffset.y
            
            // pagination
            if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
                if addMoreData == true && additionalData.count > 0 {
                    data += additionalData
                    collectionView.reloadData()
                    if additionalData.count == pageLimit {
                        getMoreData()
                    } else {
                        addMoreData = false
                    }
                }
            }
            
        } else {
            let top = navBarFrame.origin.y - STATUS_BAR_HEIGHT
            searchPeopleView.height = SCREEN_HEIGHT - top
            searchPeopleView.top = top

//            self.view.layoutIfNeeded()
            
            previousContentOffset = searchPeopleVC!.tableView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging: \(decelerate)")
        if(!decelerate) {
            stoppedScrolling()
        }
    }
    
    func stoppedScrolling() {
        print("stoppedScrolling")
//        let frame = self.navigationController?.navigationBar.frame
//        if(frame?.origin.y < STATUS_BAR_HEIGHT) {
//			print("need to animate nav bar & tool bar")
//            self.animateNavBarTo(-(frame!.size.height - STATUS_BAR_HEIGHT))
//        }
    }
    
    func updateBarButtonItems(_ alpha: CGFloat) {
        print("updateBarButtonItems: \(alpha)")
        var items = self.navigationItem.leftBarButtonItems! as NSArray
         //var items = self.navigationItem.left! as NSArray
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
    
    func animateNavBarTo(_ y: CGFloat) {
        print("animateNavBarTo: \(y)")
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            var navBarFrame = self.navigationController!.navigationBar.frame
            var tabBarFrame = self.tabBarController!.tabBar.frame
            var tabBarImageFrame = appDelegate.imagefooter!.frame
            let alpha: CGFloat = navBarFrame.origin.y >= y ? 0 : 1
            navBarFrame.origin.y = y
            tabBarFrame.origin.y = self.SCREEN_HEIGHT
            tabBarImageFrame.origin.y = self.SCREEN_HEIGHT
//            self.navigationController?.navigationBar.frame = navBarFrame
            self.tabBarController?.tabBar.frame = tabBarFrame
            appDelegate.imagefooter!.frame = tabBarImageFrame
			
            self.collectionViewBottomConstraint.constant = 0
            self.collectionViewTopConstraint.constant = -navBarFrame.height
            self.backgroundTopConstraint.constant = -navBarFrame.height
            
//            if alpha == 1.0 {
//                self.searchPeopleVC?.tableviewTopConst.constant = -50
//                self.searchPeopleVC?.headerTabTopConst.constant = -50
//
//            } else {
//                self.searchPeopleVC?.tableviewTopConst.constant = 50
//                self.searchPeopleVC?.headerTabTopConst.constant = 50
//
//            }
            
            self.updateBarButtonItems(alpha)
        })
    }
    
    // MARK: - Auxiliary
    func colorExistsInArray(_ color: SColor) -> Int {
        for i in 0..<data.count {
            if(data[i].objectId == color.objectId) {
                return i
            }
        }
        return -1
    }
    
    // MARK: - NSNotifications
    func colorDeletedSomewhere(_ notification: Notification) {
        let color = notification.object as? SColor
        
        let index = colorExistsInArray(color!)
        if(index >= 0) {
            // Deleted color is in array
            
            // Remove it from array
            data.remove(at: index)
            
            // Reload collectionview
            collectionView?.reloadData()
        }
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width/3) , height: (self.view.frame.size.width/3));
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            if headerView == nil {
                headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,withReuseIdentifier: "SearchHeaderCell", for: indexPath)
                    as? SearchHeaderCell
               // headerView?.selectedTabView.transform = CGAffineTransformMakeRotation(CGFloat(((45.0) / 180.0 * M_PI)))  HelveticaNeue-Bold
                
                    if let textField = headerView?.searchField.value(forKey: "_searchField") as? UITextField {
                    let searchBarPlaceholder = NSMutableAttributedString(string: "Tap To Search")
                    print("frame search:: \(headerView?.searchField.frame)")
                    searchBarPlaceholder.addAttribute(NSKernAttributeName, value: 1.5, range: NSMakeRange(0, searchBarPlaceholder.length))
                    searchBarPlaceholder.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 241/255.0, green: 188/255.0, blue: 199/255.0, alpha: 1.0), range: NSMakeRange(0, searchBarPlaceholder.length))
                    searchBarPlaceholder.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 13)!, range: NSMakeRange(0, searchBarPlaceholder.length))
                    textField.attributedPlaceholder = searchBarPlaceholder
                    textField.textColor = UIColor.white
                    textField.font = UIFont(name: "Avenir-Black", size: 13)
                    //textField.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
                    textField.text = searchString
                    textField.backgroundColor = UIColor.clear
                   //textField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
                    textField.textAlignment=NSTextAlignment.center
                    //textField.backgroundColor = UIColorFromRGB(0xee748d)
                    
//                  textField.backgroundColor = UIColorFromRGB(0xee748d)
//                  textField.layer.borderWidth = 1
//                  textField.layer.borderColor = UIColorFromRGB(0xee748d).CGColor
                    
                    
                }
                
    
//                headerView?.searchField.barTintColor = UIColor.purple()
//                // Remove the single pixel black line
//                headerView?.searchField.layer.borderWidth = 1
//                headerView?.searchField.layer.borderColor = UIColor.purple().CGColor
                
                
//                    headerView?.searchField.barTintColor = UIColorFromRGB(0xee748d)
                    // Remove the single pixel black line
                   // headerView?.searchField.layer.borderWidth = 1
                   // headerView?.searchField.layer.borderColor = UIColorFromRGB(0xee748d).CGColor
                
//                let gradient = CAGradientLayer()
//                gradient.frame = view.bounds
//                gradient.colors = [UIColorFromRGB(0xf07093), UIColorFromRGB(0xf07b74)]
//                
//                headerView?.searchField.layer.insertSublayer(gradient, atIndex: 0)
//                
                
                
                
             //   headerView?.searchField.leftViewMode = UITextFieldViewMode.Always
//                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//                let image = UIImage(named: "searchColorsBackground")
//                imageView.image = image
//                headerView?.searchField.backgroundImage = UIImage(named: "Navigationbar@3x")
                headerView?.searchField.barTintColor = UIColorFromRGB(0xff748d)
                //searchBar.layer.borderWidth = 1
                headerView?.searchField.backgroundImage = UIImage(named: "Navigationbar@3x")
                //  selectedTabView.transform = CGAffineTransformMakeRotation(CGFloat(((45.0) / 180.0 * M_PI)))
                
                headerView?.searchField.setImage(UIImage(named: "searchIcon"), for: .search, state: UIControlState())
				headerView?.searchField.setImage(UIImage(named: "clearIcon"), for: .clear, state: UIControlState())

                headerView?.searchField.layer.shadowColor = UIColor.lightGray.cgColor
                headerView?.searchField.layer.shadowOffset = CGSize(width: 1, height: 3)
                headerView?.searchField.layer.shadowOpacity = 0.7
                headerView?.searchField.layer.shadowRadius = 3.0
                
           
            }
            return headerView!
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        
        collectionViewCell.color = data[indexPath.row]
        //        collectionViewCell.setSColor(data[indexPath.row])
        
        return collectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < data.count {
            let color = data[indexPath.item]
            
            // fetch first to see if this color still exists
            color.object?.fetchInBackground(block: { (object, error) -> Void in
                if error == nil {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc: ColorDetailsVC = storyboard.instantiateViewController(withIdentifier: "ColorDetailsVC") as! ColorDetailsVC
                    vc.color = color
                    let navController = NickNavViewController(rootViewController: vc)
                    self.present(navController, animated: true, completion: nil)
                } else {
                    if error!._code == 101 {
                        // The color does not exist anymore. i.e it was deleted by user
                        let alertView = UIAlertView(title: "Color does not exist", message: "This color was deleted", delegate: nil, cancelButtonTitle: "Ok")
                        alertView.show()
                    }
                }
            })
        }
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let textField = headerView?.searchField.value(forKey: "_searchField") as? UITextField
        textField?.textAlignment = NSTextAlignment.center
        print("editing")
        searchString = searchText
        if(searchText.characters.count >= 3) {
            reloadData()
        }
        //
        else {
            if let mostRecentQuery = mostRecentQuery {
                mostRecentQuery.cancel()
                self.mostRecentQuery = nil
            }
            
            AppDelegate.hideActivity()
            
//            if data.count > 0 && additionalData.count > 0 {
                data = []
                additionalData = []
               // collectionView.reloadData()
                collectionView.collectionViewLayout.invalidateLayout()
//                collectionView.reloadSections(NSIndexSet(index: 0))
                headerView?.searchField.becomeFirstResponder()
                overlayView.isHidden = false
//            }
 
        }
 
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("begin editing");
        let textField = headerView?.searchField.value(forKey: "_searchField") as? UITextField
        textField?.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        textField?.textAlignment = NSTextAlignment.center
        print("icon:: \(textField?.leftView?.frame)")
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let textField = headerView?.searchField.value(forKey: "_searchField") as? UITextField
        textField?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        if textField?.text == ""{
            textField?.textAlignment = NSTextAlignment.left

        }
        else{
            textField?.textAlignment = NSTextAlignment.center

        }
        print("end editing")
    }

    
}




// MARK: - SearchPeopleProtocol
extension SearchViewController: SearchPeopleProtocol {
    func searchPeopleScrollDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
    }
    
    
    func searchPeopleScrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func searchPeopleScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    func searchPeopleShowColors() {
        let imageName = "searchColorsBackground"
        overlayView.image = UIImage(named: imageName)
        searchPeopleView.isHidden = true
        collectionView.isHidden = false
        scrollViewDidScroll(collectionView)
        
        overlayView.isHidden =  headerView != nil && headerView!.searchField.text!.characters.count > 0
        dismissKeyboard()
    }
    
    func searchPeopleOnChooseUser(_ user : SUser) {
        
    }
    
    func searchPeopleOverlayNeedShow(_ isNeed:Bool) {
        overlayView.isHidden = isNeed
    }
}

// MARK: - FBSDKAppInviteDialogDelegate
extension SearchViewController: FBSDKAppInviteDialogDelegate {
	/*!
	@abstract Sent to the delegate when the app invite completes without error.
	@param appInviteDialog The FBSDKAppInviteDialog that completed.
	@param results The results from the dialog.  This may be nil or empty.
	*/
	public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
		print("INVITE DIALOG RESULTS")
	}

	/*!
	@abstract Sent to the delegate when the app invite encounters an error.
	@param appInviteDialog The FBSDKAppInviteDialog that completed.
	@param error The error.
	*/
	public func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
		print("INVITE DIALOG RESULTS: \(error)")
	}
}

