//
//  NotificationsVC.swift
//  Shelf
//
//  Created by Matthew James on 07/05/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

let kNotificationVCIdentifier = "NotificationsVC"
let kCloudFuncGetUsersNotificationsWithFollow = "getUsersNotificationsWithFollow"
let kCloudFuncSetUserNotificationsSeen = "setUserNotificationsSeen"
let kParseKeyNotificationObject = "notificationObject"
let kParseKeySeen = "seen"
let kParseKeyNotificationIds = "notificationIds"

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var tblNotifications: UITableView!
    @IBOutlet weak var lblViewTitle: UILabel!
    
    fileprivate var notifications: [(notification:SNotification,following:Bool)] = []
    fileprivate var notificationsPages: [Int] = []
    fileprivate var shouldLoadNextPage = false
    
    var refreshControl: UIRefreshControl!
    var notificationsSeen: ((Int) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblNotifications.backgroundView = nil
        
        setupNavBar()
        
        // UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(NotificationsVC.fetchData), for: .valueChanged)
        tblNotifications.addSubview(refreshControl)
        tblNotifications.register(UINib(nibName: kLoadingMoreCellIdentifier, bundle: nil), forCellReuseIdentifier: kLoadingMoreCellIdentifier)
        
        //        let captureString: NSMutableAttributedString = NSMutableAttributedString(string: "NOTIFICATIONtttt")
        //        captureString.addAttribute(NSKernAttributeName, value: 5.0, range: NSMakeRange(0, captureString.length))
        //        lblViewTitle.attributedText = captureString
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationsVC.updateNotificationsFollow(_:)), name: NSNotification.Name(rawValue: kFollowUpdatedNotification) , object: nil)
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false;
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter!.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    // MARK: - NSNotification
    func updateNotificationsFollow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let objectId = userInfo["objectId"] as! String
            let following = userInfo["following"] as! Bool
            
            for index in 0..<notifications.count {
                let notification = notifications[index].notification
                // If fromUser exists and type is follow
                if let fromUser = notification.fromUser, notification.type == "follow" {
                    // Found follow
                    if fromUser.objectId == objectId {
                        notifications[index].following = following
                        tblNotifications.beginUpdates()
                        tblNotifications.reloadRows(at: [IndexPath(item: index, section: 0)], with: .none)
                        tblNotifications.endUpdates()
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - data
    func fetchData() {
        if !self.refreshControl.isRefreshing {
            AppDelegate.showActivity()
        }
        
        notifications = []
        notificationsPages = []
        
        // First page
        updateNotifications { (success: Bool) in
            if success {
                self.tblNotifications.reloadData()
            }
        }
    }
    
    func updateNotifications(_ page : Int = 0, itemPerPage : Int = kItemsPerPage, completion : @escaping ((Bool) -> ())) {
        guard !notificationsPages.contains(page) else {
            AppDelegate.hideActivity()
            return
        }
        
        notificationsPages.append(page)
        print("kItemsPerPage: \(kItemsPerPage)")
        PFCloud.callFunction(inBackground: kCloudFuncGetUsersNotificationsWithFollow, withParameters: [kKeyPage: page, kKeyLimit: kItemsPerPage]) { (result: Any?, error: Error?) in
            AppDelegate.hideActivity()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
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
                self.notificationsPages.removeObject(page)
                completion(false)
                return
            }
            
            print("notifications: \(objects)")
            
            var unseenIds = [String]()
            //            print("objectsCount: \(objects.count)")
            for object in objects {
                var sNotification: SNotification!
                var following = false
                
                if let notificationObject = object.object(forKey: kParseKeyNotificationObject) as? PFObject {
                    if let type = notificationObject["type"] as? String {
                        if type == "like" {
                            // Check if color exists for like
                            if let _ = notificationObject["color"] {
                                sNotification = SNotification(data: notificationObject)
                            }
                        }
                        else {
                            sNotification = SNotification(data: notificationObject)
                        }
                    }
                    else {
                        sNotification = SNotification(data: notificationObject)
                    }
                    if let seen = notificationObject[kParseKeySeen] as? NSNumber, seen == NSNumber(value: false as Bool) {
                        notificationObject[kParseKeySeen] = true
                        unseenIds.append(notificationObject.objectId!)
                    }
                }
                
                if let fol = object.object(forKey: kKeyFollowing) as? Bool {
                    following = fol
                }
                
                if sNotification != nil {
                    self.notifications.append((notification: sNotification, following: following))
                }
            }
            self.updateNotificationsSeen(unseenIds)
            
            // Should allow paginate if current page count is same as the limit
            print("objects count: \(objects.count)")
            self.shouldLoadNextPage = objects.count == kItemsPerPage
            print("shouldLoadNextPage: \(self.shouldLoadNextPage)")
            completion(true)
        }
    }
    
    func updateNotificationsSeen(_ unseenIds: [String]) {
        if unseenIds.count > 0 {
            print("updateNotificationsSeen: \(unseenIds.count)")
            PFCloud.callFunction(inBackground: kCloudFuncSetUserNotificationsSeen, withParameters: [kParseKeyNotificationIds: unseenIds], block: { (result: Any?, error: Error?) in
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
                    
                    return
                }
            })
            
            // Invoke callback function to update notifications count to MyProfileVC
            if let notificationsSeen = notificationsSeen {
                notificationsSeen(unseenIds.count)
            }
        }
    }
    
    
    func setupNavBar() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        ////        let titleView:UIImageView = UIImageView(image: UIImage(named: "Registation_logo"))
        ////        titleView.contentMode = UIViewContentMode.ScaleAspectFit
        ////        titleView.frame = CGRectMake(0, 0, 35.0, 30.0)
        //
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 45, height: 30))
        label.textAlignment = NSTextAlignment.center
        label.text = "Notifications"
        label.textColor=UIColor.white;
        //label.font = label.font.fontWithSize(20)
        label.font = UIFont (name: "Avenir-Heavy", size: 18)
        self.navigationItem.titleView=label
        
        self.navigationItem.hidesBackButton = true
        let backButton = UIButton(type: UIButtonType.system)
        backButton.frame = CGRect(x: 0, y: 0, width: 10, height: 18)
        backButton.tintColor = UIColor.white
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(NotificationsVC.backPressed), for:.touchUpInside)
        let backBarButton:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        
        
        ////        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "btnSettings"), style: .Plain, target: self, action: nil)
        ////        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clearColor()
    }
    
    override func backPressed() {
        let transition: CATransition = CATransition()
        transition.duration = 0.35
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        
        let containerView:UIView = self.view.window!
        containerView.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    //----------------------------------------------------------
    // MARK: - Gestures
    //----------------------------------------------------------
    func profileTapped(_ gr: UITapGestureRecognizer) {
        transitionToProfileVC(gr.view!)
    }
    
    func postTapped(_ gr: UITapGestureRecognizer) {
        if let row = gr.view?.tag {
            if row < notifications.count {
                let notificationTuple = notifications[row]
                if let color = notificationTuple.notification.color {
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ColorDetailsVC") as! ColorDetailsVC
                    vc.color = SColor(data: color)
                    let navController = NickNavViewController(rootViewController: vc)
                    self.present(navController, animated:true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Helper functions
    fileprivate func loadNextPage() {
        let prevCount = notifications.count
        let page = notificationsPages[notificationsPages.count - 1] + 1
        updateNotifications(page, itemPerPage: kItemsPerPage) { (success: Bool) in
            guard success else {
                // Remove Loading More Cell
                self.tblNotifications.beginUpdates()
                self.tblNotifications.deleteRows(at: [IndexPath(row: self.notifications.count - 1, section: 0)], with: .none)
                self.tblNotifications.endUpdates()
                return
            }
            
            let start = prevCount
            var end = start + kItemsPerPage
            if end > self.notifications.count {
                end = self.notifications.count
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
            
            self.tblNotifications.beginUpdates()
            if !self.shouldLoadNextPage {
                self.tblNotifications.reloadRows(at: [IndexPath(row: start, section: 0)], with: .none)
            }
            self.tblNotifications.insertRows(at: insertIndexPaths, with: .none)
            self.tblNotifications.endUpdates()
        }
    }
    
    fileprivate func transitionToProfileVC(_ view: UIView) {
        let row = view.tag
        if row < notifications.count {
            let notificationTuple = notifications[row]
            if let user = notificationTuple.notification.fromUser {
                guard let currUser = PFUser.current(), user.objectId != currUser.objectId else {
                    // Same user as current user, don't do anything
                    return
                }
                
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: ProfileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.user = SUser(dataUser: user)
                vc.row = row
                //                vc.updateFollowing = updateFollowing
                let navController = NickNavViewController(rootViewController: vc)
                self.present(navController, animated:true, completion: nil)
                transitionToProfile(vc.user)
            }
        }
    }
    
    func updateFollowing(_ following: Bool, row: Int) {
        notifications[row].following = following
        
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = notifications.count
        if shouldLoadNextPage {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < notifications.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
            cell.backgroundColor = UIColor.clear
            
            let notificationTuple = notifications[indexPath.row]
            let notification = notificationTuple.notification
            cell.notification = notification
            
            // Profile ImageView
            cell.profileImageView.tag = indexPath.row
            let profileTap = UITapGestureRecognizer(target: self, action: #selector(NotificationsVC.profileTapped(_:)))
            profileTap.numberOfTapsRequired = 1
            if let gestureRecognizers = cell.profileImageView.gestureRecognizers {
                for recognizer: UIGestureRecognizer in gestureRecognizers {
                    cell.profileImageView.removeGestureRecognizer(recognizer)
                }
            }
            cell.profileImageView.addGestureRecognizer(profileTap)
            
            cell.lblNotification.tag = indexPath.row
            cell.lblNotification.delegate = self
            
            // Post ImageView
            cell.postImageView.tag = indexPath.row
            let postTap = UITapGestureRecognizer(target: self, action: #selector(NotificationsVC.postTapped(_:)))
            postTap.numberOfTapsRequired = 1
            
            if let gestureRecognizers = cell.postImageView.gestureRecognizers {
                for recognizer: UIGestureRecognizer in gestureRecognizers {
                    cell.postImageView.removeGestureRecognizer(recognizer)
                }
            }
            
            if(cell.notification?.color != nil) {
                cell.postImageView.addGestureRecognizer(postTap)
            }
            
            cell.btnAdd.isSelected = notificationTuple.following
            cell.btnAdd.tag = indexPath.row
            cell.updateFollowing = updateFollowing
            
            return cell
        }
            // Return LoadingMoreCell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kLoadingMoreCellIdentifier, for: indexPath) as! LoadingMoreCell
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == notifications.count - 1 {
            if shouldLoadNextPage {
                loadNextPage()
            }
        }
    }
}

// MARK: - TSLabelDelegate
extension NotificationsVC: TSLabelDelegate {
    func label(_ label: TSLabel!, canInteractWith URL: Foundation.URL!, in characterRange: NSRange) -> Bool {
        return true
    }
    
    func label(_ label: TSLabel!, shouldInteractWith URL: Foundation.URL!, in characterRange: NSRange) -> Bool {
        transitionToProfileVC(label)
        return false
    }
}
