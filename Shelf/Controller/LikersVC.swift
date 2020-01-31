//
//  LikersVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 6/24/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

let kKeyColorId = "colorId"
let kKeyLikeObject = "likeObject"

private let kCloudFuncGetLikersForColor = "getLikersForColor"

class LikersVC: UIViewController {
    
    
    @IBOutlet weak var tbllikers : UITableView!
    fileprivate var likes        : [(like:SLike,following:Bool)] = []
    fileprivate var likesPages : [Int] = []
    fileprivate var shouldLoadNextPage = false

    var color       : SColor!
    //----------------------------------------------------------
    // MARK: - View Life cycle methods
    //----------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        //icon_Add
       // icon_Added
        tbllikers.register(UINib(nibName: kLoadingMoreCellIdentifier, bundle: nil), forCellReuseIdentifier: kLoadingMoreCellIdentifier)
        tbllikers.backgroundColor = UIColor.clear
        tbllikers.backgroundView = nil
        tbllikers.dataSource = self
        tbllikers.delegate = self
        
        // Do any additional setup after loading the view.
        setupNavBar()
        fetchData()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    func setupNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
      //  Registation_logo
        let titleView:UIImageView = UIImageView(image: UIImage(named: ""))
        titleView.contentMode = UIViewContentMode.scaleAspectFit
        titleView.frame = CGRect(x: 0, y: 0, width: 35.0, height: 30.0)
        self.navigationItem.titleView = titleView
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.navigationItem.titleView!.frame.size.width, height: 21))
        label.textAlignment = NSTextAlignment.center
        label.text = "Lovers"
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
        backButton.addTarget(self, action: #selector(LikersVC.backPressed), for:.touchUpInside)
        
        let backBarButton:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
    }
    
    // MARK: - data
    func fetchData() {
        AppDelegate.showActivity()
        likes = []
        
        // First page
        updateLikes { (success: Bool) in
            if success {
                self.tbllikers.reloadData()
            }
        }
    }
    
    func updateLikes(_ page : Int = 0, itemPerPage : Int = kItemsPerPage, completion : @escaping ((Bool) -> ())) {
        guard !likesPages.contains(page) else {
            AppDelegate.hideActivity()
            return
        }
        
        likesPages.append(page)
		PFCloud.callFunction(inBackground: kCloudFuncGetLikersForColor, withParameters: [kKeyColorId: color!.objectId!, kKeyPage: page, kKeyLimit: kItemsPerPage]) { (result, error) in
            AppDelegate.hideActivity()
            
            guard error == nil, let objects = result as? [AnyObject] else {
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
                
                // Errored out, allow user to re-fetch page again
                self.shouldLoadNextPage = true
                self.likesPages.removeObject(page)
                completion(false)
                return
            }
            
            for object in objects {
                var sLike: SLike!
                var following = false
                
                if let likeObject = object.object(forKey: kKeyLikeObject) as? PFObject {
                    sLike = SLike(data: likeObject)
                }
                
                if let fol = object.object(forKey: kKeyFollowing) as? Bool {
                    following = fol
                }
                
                self.likes.append((like: sLike, following: following))
            }
            
            // Should allow paginate if current page count is same as the limit
            self.shouldLoadNextPage = objects.count == kItemsPerPage
            
            completion(true)
        }
    }
    
    //----------------------------------------------------------
    // MARK: - Gestures
    //----------------------------------------------------------
    func profileTapped(_ gr: UITapGestureRecognizer) {
        if let row = gr.view?.tag {
            if row < likes.count {
                let likeTuple = likes[row]
                if let user = likeTuple.like.user {
                    do {
                        try user.fetchIfNeeded()
                    } catch {
                    
                    }
                    let sUser = SUser(dataUser: user)
                    transitionToProfile(sUser)
                }
            }
        }
    }
    
    fileprivate func loadNextPage() {
        let page = likesPages[likesPages.count - 1] + 1
        updateLikes(page, itemPerPage: kItemsPerPage) { (success: Bool) in
            guard success else {
                // Remove Loading More Cell
                self.tbllikers.beginUpdates()
                self.tbllikers.deleteRows(at: [IndexPath(row: self.likes.count, section: 0)], with: .none)
                self.tbllikers.endUpdates()
                return
            }
            
            let start = page * kItemsPerPage
            var end = start + kItemsPerPage
            if end > self.likes.count {
                end = self.likes.count
            }
            
            var insertIndexPaths = [IndexPath]()
            if end > start {
                for index in start..<end {
                    if index == start {
                        if self.shouldLoadNextPage {
                            insertIndexPaths.append(IndexPath(row: index, section: 0))
                        }
                    } else {
                        insertIndexPaths.append(IndexPath(row: index, section: 0))
                    }
                }
            }
            
            self.tbllikers.beginUpdates()
            if !self.shouldLoadNextPage {
                self.tbllikers.reloadRows(at: [IndexPath(row: start, section: 0)], with: .none)
            }
            self.tbllikers.insertRows(at: insertIndexPaths, with: .none)
            self.tbllikers.endUpdates()
        }
    }
    
    //----------------------------------------------------------
    // MARK: - Typealias
    //----------------------------------------------------------
    func followActionAlias(_ success: Bool, followAction: FollowAction) {
        guard success == false else {
            // Network calls were successful, do nothing
            return
        }
        
        let title = followAction == .follow ? "Follow User Error" : "Unfollow User Error"
        let message = followAction == .follow ? "Unable to follow user, please try again." : "Unable to unfollow user, please try again."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}

extension LikersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = likes.count
        if shouldLoadNextPage && likesPages.count > 0 && likesPages[likesPages.count - 1] != 0 {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < likes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: kFollowCellIdentifier, for: indexPath) as! FollowCell
            cell.btnAdd.isSelected = false
            cell.vc = self
            
            let likeTuple = likes[indexPath.row]
            let like = likeTuple.like
            cell.updateCellWithUser(like.user, isFollowing: likeTuple.following)
            cell.followActionAlias = followActionAlias
            
            cell.imgProfile.tag = indexPath.row
            cell.imgProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LikersVC.profileTapped(_:))))
            cell.labelUsername.tag = indexPath.row
            cell.labelUsername.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LikersVC.profileTapped(_:))))
            
            if indexPath.row == likes.count - 1 {
                cell.seperatorView.isHidden = true
            }
            
            cell.backgroundColor = UIColor.clear
            
            return cell
        }
        // Return LoadingMoreCell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kLoadingMoreCellIdentifier, for: indexPath) as! LoadingMoreCell
            
            return cell
        }
    }
}

extension LikersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == likes.count - 1 {
            if shouldLoadNextPage {
                loadNextPage()
            }
        }
    }
}
