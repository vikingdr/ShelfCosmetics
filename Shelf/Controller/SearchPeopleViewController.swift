
import UIKit
import MBProgressHUD
import Firebase

private let kCloudFuncSearchUsers = "searchUsers"
private let kKeySearchText = "searchText"

let kKeyUserObject = "userObject"

class SearchPeopleViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedTabView: UIView!
    @IBOutlet weak var colorsButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    
    @IBOutlet  var buttonview: [UIView]!
    
    @IBOutlet weak var bottomview: UIView!
    @IBOutlet weak var headerTabTopConst: NSLayoutConstraint!
    @IBOutlet weak var tableviewTopConst: NSLayoutConstraint!
    
    fileprivate var searchUsers : [(sUser:SUser,isFollowing:Bool)] = []
    fileprivate var searchUsersPages : [Int] = []
    fileprivate var shouldLoadNextPage = false
    
    var delegate : SearchPeopleProtocol?
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.view.backgroundColor=UIColor.blueColor()
        //selectedTabView.backgroundColor=UIColor.blueColor()
        
        
        //bottomview.backgroundColor=UIColorFromRGB(0x5f5f79)
        //bottomview.textColor = UIColorFromRGB(0xee748d)
        bottomview.layer.cornerRadius = 5;
        bottomview.layer.masksToBounds = true;
//
//        view.layer.borderColor = UIColor.grayColor().CGColor;
//        view.layer.borderWidth = 0.5;
        if let searchField: UITextField = searchBar.value(forKey: "_searchField") as? UITextField {
            //searchField.backgroundColor = UIColorFromRGB(0xee748d)
            searchField.backgroundColor = UIColor.clear
            searchField.textColor = UIColor.white
            searchField.font = UIFont(name: "Avenir-Black", size: 13)
            let searchBarPlaceholder = NSMutableAttributedString(string: "Tap To Search")
//            print("frame search:: \(headerView?.searchField.frame)")
            searchBarPlaceholder.addAttribute(NSKernAttributeName, value: 1.5, range: NSMakeRange(0, searchBarPlaceholder.length))
            searchBarPlaceholder.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 241/255.0, green: 188/255.0, blue: 199/255.0, alpha: 1.0), range: NSMakeRange(0, searchBarPlaceholder.length))
            searchBarPlaceholder.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 13)!, range: NSMakeRange(0, searchBarPlaceholder.length))
            searchField.attributedPlaceholder = searchBarPlaceholder
            
           //            searchField.attributedPlaceholder = NSAttributedString(string: "Tap To Search", attributes: [NSKernAttributeName : 3, NSForegroundColorAttributeName : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)])
            searchField.textColor=UIColor.white;
            
            
            searchField.textAlignment = NSTextAlignment.center
        }
        searchBar.barTintColor = UIColorFromRGB(0xff748d)
       //searchBar.layer.borderWidth = 1
         searchBar.backgroundImage = UIImage(named: "Navigationbar@3x")
        //  selectedTabView.transform = CGAffineTransformMakeRotation(CGFloat(((45.0) / 180.0 * M_PI)))
        
        searchBar.layer.shadowColor = UIColor.lightGray.cgColor
        searchBar.layer.shadowOffset = CGSize(width: 1, height: 3)
        searchBar.layer.shadowOpacity = 0.7
        searchBar.layer.shadowRadius = 3.0
    
        searchBar.setImage(UIImage(named: "searchIcon"), for: .search, state: UIControlState())
		searchBar.setImage(UIImage(named: "clearIcon"), for: .clear, state: UIControlState())
        
        //Offset the table view by the height of the tab bar
        //We do this so content doesn't hide behind the tabbar
        let tabBarInsets = UIEdgeInsetsMake(0, 0, self.tabBarController!.tabBar.frame.height + 80, 0)
        tableView.contentInset = tabBarInsets
      //  tableView.scrollIndicatorInsets = tabBarInsets
        tableView.register(UINib(nibName: kLoadingMoreCellIdentifier, bundle: nil), forCellReuseIdentifier: kLoadingMoreCellIdentifier)
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = UIColor.clear
        
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchPeopleViewController.updateSearchResult(_:)), name: kFollowUpdatedNotification , object: nil)
        
    }

    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    
    
    func updateSearchResult(_ notification : Notification) {
        if let userInfo = notification.userInfo {
            let objectId = userInfo["objectId"] as! String
            let following = userInfo["following"] as! Bool
            
            for index in 0..<searchUsers.count {
                if searchUsers[index].sUser.objectId == objectId {
                    print("row: \(index)")
                    searchUsers[index].isFollowing = following
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .none)
                    tableView.endUpdates()
                    break
                }
        
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("SearchPeopleViewController viewWillDisappear")
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(kFollowUpdatedNotification)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //imageViewObject!.hidden=false
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        fetchData()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    func fetchData() {
        tableView.isScrollEnabled = searchBar.text!.characters.count >= 3
        delegate?.searchPeopleOverlayNeedShow(searchBar.text!.characters.count > 0)
        
        if searchBar.text!.characters.count == 0 {
            searchUsers = []
            searchUsersPages = []
            tableView.reloadData()
        } else {
            AppDelegate.showActivity()
			updateSearchUsers(searchBar.text!.lowercased(), completion: { (success: Bool, searchText: String, page: Int) in
                guard success && self.searchBar.text!.lowercased() == searchText && 0 == page else {
                    return
                }
                DispatchQueue.main.async(execute: {
                    let section = IndexSet(integer: 0)
                    self.tableView.reloadSections(section, with: .automatic)
                })
                
            })
        }
    }
    
    fileprivate func updateSearchUsers(_ searchText : String, page : Int = 0, itemPerPage : Int = kItemsPerPage, completion : @escaping ((_ success: Bool, _ searchText: String, _ page: Int) -> ())) {
        guard !searchUsersPages.contains(page) else {
            AppDelegate.hideActivity()
            return
        }
        
        searchUsersPages.append(page)
        AnalyticsHelper.sendCustomEvent(kFIREventSearch)
        PFCloud.callFunction(inBackground: kCloudFuncSearchUsers, withParameters: [kKeySearchText: searchText, kKeyPage: page, kKeyLimit: kItemsPerPage]) { (result: Any?, error: Error?) in
            //Fixes issue data not reloading correctly
            //https://forums.developer.apple.com/thread/14547
            DispatchQueue.main.async(execute: {
                AppDelegate.hideActivity()
                AnalyticsHelper.sendCustomEvent(kFIREventViewSearchResults)
                // Check if the searchText is the current UISearchBar text
                guard searchText == self.searchBar.text!.lowercased() && error == nil, let objects = result as? [AnyObject] else {
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
                    
                    completion(false, searchText, page)
                    return
                }
                
                    for object in objects {
                        var sUser: SUser!
                        var following = false
                        if let userObject = object.object(forKey: kKeyUserObject) as? PFUser {
                            sUser = SUser(dataUser: userObject)
                        }
                        
                        if let fol = object.object(forKey: kKeyFollowing) as? Bool {
                            following = fol
                        }
                        if sUser != nil {
                           
                                self.searchUsers.append((sUser:sUser,isFollowing:following))
                        
                            
                        }
                    }
                
                self.shouldLoadNextPage = objects.count == kItemsPerPage
                completion(true, searchText, page)
            })
        }
    }

    // MARK: - GUI callbacks
    @IBAction func onShowColorsView(_ sender: AnyObject) {
        delegate?.searchPeopleShowColors()
    }
    
    // MARK: - Helper functions
    fileprivate func getUserSelected(_ row: Int) -> SUser {
        let usersTuple = searchUsers[row]
        return usersTuple.sUser
    }
    
    fileprivate func loadNextPage() {
        let queryText = searchBar.text!.lowercased()
        let queryPage = searchUsersPages[searchUsersPages.count - 1] + 1
        updateSearchUsers(queryText, page: queryPage, itemPerPage: kItemsPerPage) { (success: Bool, searchText: String, page: Int) in
            DispatchQueue.main.async(execute: {
                guard success && queryText == searchText && queryPage == page else {
                    return
                }
                
                self.tableView.reloadData()
            })
        }
    }
    
    //----------------------------------------------------------
    // MARK: - Gestures
    //----------------------------------------------------------
    func followTapped(_ gr: UITapGestureRecognizer) {
        guard let row = gr.view?.tag else {
            return
        }
        
        if row > searchUsers.count {
            return
        }
        
        let user = getUserSelected(row)
        print(user.firstName)
        let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! PeopleCell
        cell.btnFollow.isHidden = true
        cell.btnFollowing.isHidden = false
        searchUsers[row].isFollowing = true
        
        SFollow.followTo(user.object!, view: self.view) { (success) in
            // If false, change back to previous state
            guard success == false else {
                return
            }
            
            cell.btnFollow.isHidden = false
            cell.btnFollowing.isHidden = true
            self.searchUsers[row].isFollowing = false
            
            let title = "Follow User Error"
            let message = "Unable to follow user, please try again."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func followingTapped(_ sender: UIButton) {
        let row = sender.tag
        
        if row > searchUsers.count {
            return
        }
        let user = getUserSelected(row)
        guard let userObj = user.object else {
            return
        }
        let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! PeopleCell
        cell.btnFollow.isHidden = false
        cell.btnFollowing.isHidden = true
        searchUsers[row].isFollowing = false

        SFollow.unFollowTo(userObj, view: view) { (success) in
            // If false, change back to previous state
            guard success == false else {
                return
            }
            
            cell.btnFollow.isHidden = true
            cell.btnFollowing.isHidden = false
            self.searchUsers[row].isFollowing = true
            let title = "Unfollow User Error"
            let message = "Unable to unfollow user, please try again."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func profileTapped(_ gr: UITapGestureRecognizer) {
        guard let view = gr.view else {
            return
        }

        let row = view.tag
        if row > searchUsers.count {
            return
        }
        let user = getUserSelected(row)
        
        guard let currUser = PFUser.current(), user.objectId != currUser.objectId else {
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ProfileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.user = user
        vc.row = row
//        vc.updateFollowing = updateFollowing
        let navController = NickNavViewController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
//    func updateFollowing(isFollowing: Bool, row: Int ) {
//        searchUsers[row].isFollowing = isFollowing
//        
//        tableView.beginUpdates()
//        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: .None)
//        tableView.endUpdates()
//    }
    
    //MARK: - scrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.searchPeopleScrollDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.searchPeopleScrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        delegate?.searchPeopleScrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}

// MARK: - UITableViewDataSource
extension SearchPeopleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = searchUsers.count
        if shouldLoadNextPage && searchUsersPages.count > 0 && searchUsersPages[searchUsersPages.count - 1] != 0 {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath)  as! PeopleCell
        cell.backgroundColor = UIColor.clear
        if indexPath.row < searchUsers.count {
            
            let userTuple = searchUsers[indexPath.row]
            let user = userTuple.sUser
            cell.setSUser(user)
            
            cell.contentImage.tag = indexPath.row
            cell.contentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchPeopleViewController.profileTapped(_:))))
            cell.label.tag = indexPath.row
            cell.label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchPeopleViewController.profileTapped(_:))))
            
            let followTap = UITapGestureRecognizer(target: self, action: #selector(SearchPeopleViewController.followTapped(_:)))
            followTap.numberOfTapsRequired = 1
            
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.isUserInteractionEnabled = true
            cell.btnFollow.addGestureRecognizer(followTap)
            
            cell.btnFollowing.tag = indexPath.row
            cell.btnFollowing.addTarget(self, action: #selector(SearchPeopleViewController.followingTapped(_:)), for: UIControlEvents.touchUpInside)
            
            let isFollowing = userTuple.isFollowing
            cell.btnFollow.isHidden = isFollowing
            cell.btnFollowing.isHidden = !isFollowing
            
            let profileTap = UITapGestureRecognizer(target: self, action: #selector(SearchPeopleViewController.profileTapped(_:)))
            profileTap.numberOfTapsRequired = 1
            cell.contentImage!.tag = indexPath.row
            cell.contentImage!.isUserInteractionEnabled = true
            cell.contentImage!.addGestureRecognizer(profileTap)
            
            let userNameTap = UITapGestureRecognizer(target: self, action: #selector(SearchPeopleViewController.profileTapped(_:)))
            userNameTap.numberOfTapsRequired = 1
            cell.label!.tag = indexPath.row
            cell.label!.isUserInteractionEnabled = true
            cell.label!.addGestureRecognizer(userNameTap)
            
        }
        // Return LoadingMoreCell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kLoadingMoreCellIdentifier, for: indexPath) as! LoadingMoreCell
            
            return cell
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchPeopleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        if indexPath.row > searchUsers.count {
            return
        }
        
        delegate.searchPeopleOnChooseUser(getUserSelected(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == searchUsers.count - 1 {
            if shouldLoadNextPage {
                loadNextPage()
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchPeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Clear the arrays for new searchText query
//        let textField = searchBar?.searchField.valueForKey("_searchField") as? UITextField
//        textField?.textAlignment = NSTextAlignment.Center
       // searchText.text.textAlignment = NSTextAlignment.Center
        
        let textField = searchBar.value(forKey: "_searchField") as? UITextField
        textField?.textAlignment = NSTextAlignment.center
        print("editing")

        
        
        searchUsers = []
        searchUsersPages = []
        //tableView.reloadData()
        if(searchText.characters.count >= 3) {
            fetchData()
        } else {
            
            AppDelegate.hideActivity()
            tableView.reloadData()
            tableView.isScrollEnabled = searchBar.text!.characters.count >= 3
            delegate?.searchPeopleOverlayNeedShow(false)
            
            
            
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("begin editing");
        let textField = searchBar.value(forKey: "_searchField") as? UITextField
        textField?.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        textField?.textAlignment = NSTextAlignment.center
        print("icon:: \(textField?.leftView?.frame)")
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let textField = searchBar.value(forKey: "_searchField") as? UITextField
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

protocol SearchPeopleProtocol {
    
    func searchPeopleOverlayNeedShow(_ isNeed:Bool)
    func searchPeopleScrollDidScroll(_ scrollView: UIScrollView);
    func searchPeopleScrollViewDidEndDecelerating(_ scrollView: UIScrollView);
    func searchPeopleScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool);
    func searchPeopleShowColors();
    func searchPeopleOnChooseUser(_ user : SUser);
    
}
