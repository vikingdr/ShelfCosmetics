//
//  SFollow.swift
//  Shelf
//
//  Created by Matthew James on 20.07.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import MBProgressHUD

private var myFollowingCountQuery: PFQuery<PFObject>?
private var myFollowersCountQuery: PFQuery<PFObject>?
private var myFollowing : [SFollow?] = []
private var myFollowers : [(follow:SFollow?,following:Bool)] = []
private var myFollowingCount : Int = 0
private var myFollowersCount : Int = 0
private var myFollowingPages : [Int] = []
private var myFollowersPages : [Int] = []

let kItemsPerPage : Int = 10

let kClassNameFollow = "Follow"
let kKeyUserId = "userId"
let kKeyFrom = "from"
let kKeyTo = "to"
let kKeyPage = "page"
let kKeyLimit = "limit"
let kKeyFollowObject = "followObject"
let kKeyFollowing = "following"

let kFollowUpdatedNotification = "FollowUpdatedNotification"

private let kCloudFuncFollowUser = "followUser"
private let kCloudFuncUnfollowUser = "unFollowUser"
private let kCloudFuncGetFollowers = "getFollowers"
private let kCloudFuncGetFollowing = "getFollowing"

class SFollow: SObject {
   
    var fromUser : PFUser?
    var toUser : PFUser?
    
    class func currentFollowersCount() -> Int {
        return myFollowersCount
    }
    
    class func currentFollowingCount() -> Int {
        return myFollowingCount
    }
    class func currentFollowing() -> [SFollow?]{
        return myFollowing
    }
    
    class func currentFollowers() -> [(follow:SFollow?,following:Bool)]{
        return myFollowers
    }
    
    class func currentFollowingPages() -> [Int] {
        return myFollowingPages
    }
    
    class func currentFollowersPages() -> [Int] {
        return myFollowersPages
    }
    
    class func followTo(_ user : PFUser, view : UIView, completionClosure: (( _ success : Bool) -> ())?) {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.labelText = "Following user"
		
		PFCloud.callFunction(inBackground: kCloudFuncFollowUser, withParameters: [kKeyUserId:user.objectId!]) { (result, error) in
            MBProgressHUD.hide(for: view, animated: true)
            guard error == nil, let _ = result else {
                if let errorLocalized = error?.localizedDescription {
                    let errorData = errorLocalized.data(using: String.Encoding.utf8)
                    do {
                        let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                        if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                            // INVALID_SESSION_TOKEN
                            if errorCode == kParseErrorCodeInvalidSessionToken {
                                if let message = (errorJson as AnyObject).object(forKey: "message") as? String, message == "INVALID_SESSION_TOKEN" {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kInvalidSessionTokenNotification), object: nil)
                                }
                            }
                        }
                    } catch {
                        
                    }
                }
                
                if let completionClosure = completionClosure {
                    completionClosure(false)
                }
                return
            }
            
            // Follow successful, update current user's Followers and Following arrays
            // Check if user not in following array
            let following = myFollowing.filter { $0!.toUser!.objectId == user.objectId }
            // Prepend myFollowing array if user does not exists
            if following.count <= 0 {
                let followObject = PFObject(className: kClassNameFollow)
                followObject[kKeyFrom] = PFUser.current()
                followObject[kKeyTo] = user
                myFollowing.insert(SFollow(data: followObject), at: 0)
                // Increment following count and avoid duplicates
                myFollowingCount += 1
            }
            
            // Update follower following to true
            for index in 0..<myFollowers.count {
                if myFollowers[index].follow?.fromUser?.objectId == user.objectId {
                    myFollowers[index] = (follow:myFollowers[index].follow,following:true)
                    break
                }
            }
            notifyFollowing(true, objectId: user.objectId!)
            if let completionClosure = completionClosure {
                completionClosure(true)
            }
        }
    }
    
    class func notifyFollowing(_ value : Bool, objectId : String){
        let dict : [String : AnyObject] = ["objectId" : objectId as AnyObject, "following" : value as AnyObject]
        NotificationCenter.default.post(name: Notification.Name(rawValue: kFollowUpdatedNotification), object: self, userInfo: dict)
        
    }
    
    class func unFollowTo(_ user : PFUser, view : UIView, completionClosure: (( _ success : Bool) -> ())?) {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.labelText = "Unfollowing user"
        
        PFCloud.callFunction(inBackground: kCloudFuncUnfollowUser, withParameters: [kKeyUserId:user.objectId!]) { (result, error) -> Void in
            MBProgressHUD.hide(for: view, animated: true)
            guard error == nil, let _ = result else {
                if let errorLocalized = error?.localizedDescription {
                    let errorData = errorLocalized.data(using: String.Encoding.utf8)
                    do {
                        let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                        if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                            // INVALID_SESSION_TOKEN
                            if errorCode == kParseErrorCodeInvalidSessionToken {
                                if let message = (errorJson as AnyObject).object(forKey: "message") as? String, message == "INVALID_SESSION_TOKEN" {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kInvalidSessionTokenNotification), object: nil)
                                }
                            }
                        }
                    } catch {
                        
                    }
                }
                
                if let completionClosure = completionClosure {
                    completionClosure(false)
                }
                return
            }

            // Unfollow successful, update current user's Followers and Following arrays
            // Check if user in following array
            let following = myFollowing.filter { $0!.toUser!.objectId == user.objectId }
            // Update myFollowing array if user does exists
            for fol in following {
                myFollowing.removeObject(fol!)
            }
            // Decrement following count
            myFollowingCount -= 1
            
            // Update follower following to false
            for index in 0..<myFollowers.count {
                if myFollowers[index].follow?.fromUser?.objectId == user.objectId {
                    myFollowers[index] = (follow:myFollowers[index].follow,following:false)
                    break
                }
            }
             notifyFollowing(false, objectId: user.objectId!)
            
            if let completionClosure = completionClosure {
                completionClosure(true)
            }
        }
    }
    
    class func refreshFollowing () {
        if let currentUser = PFUser.current(), myFollowingCountQuery == nil {
            myFollowingCountQuery = PFQuery(className: kClassNameFollow)
            myFollowingCountQuery?.whereKey(kKeyFrom, equalTo: currentUser)
            myFollowingCountQuery?.whereKeyExists(kKeyTo)
            myFollowingCountQuery?.whereKey(kKeyTo, notEqualTo: NSNull())
			
			myFollowingCountQuery?.countObjectsInBackground(block: { (count, error) in
                myFollowingCountQuery = nil
                guard error == nil else {
                    return
                }
                
                myFollowingCount = Int(count)
                myFollowing = []
                myFollowingPages = []
                updateFollowing(completion: nil)
            })
        }
    }
    
    //Used for pagination
    class func updateFollowing(_ page : Int = 0, itemsPerpage : Int = kItemsPerPage, completion : ((_ success: Bool, _ shouldLoadNextPage: Bool) -> ())? ) {
        if myFollowingPages.contains(page) {
            // Special case: if array count < followingCount, continue
            if myFollowing.count < myFollowingCount {
                
            } else {
                return
            }
        } else {
            myFollowingPages.append(page)
        }
        
        PFCloud.callFunction(inBackground: kCloudFuncGetFollowing, withParameters: [kKeyPage:page, kKeyLimit:kItemsPerPage]) { (result, error) -> Void in
            guard error == nil, let objects = result as? [PFObject] else {
                if let errorLocalized = error?.localizedDescription {
                    let errorData = errorLocalized.data(using: String.Encoding.utf8)
                    do {
                        let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                        if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                            // INVALID_SESSION_TOKEN
                            if errorCode == kParseErrorCodeInvalidSessionToken {
                                if let message = (errorJson as AnyObject).object(forKey: "message") as? String, message == "INVALID_SESSION_TOKEN" {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kInvalidSessionTokenNotification), object: nil)
                                }
                            }
                        }
                    } catch {
                        
                    }
                }
                
                if let completion = completion {
                    completion(false, false)
                }
                return
            }
            
            var shouldLoadNextPage = false
            print("objects count: \(objects.count)")
            for followObject in objects {
                // Check if to user exists
                if let _ = followObject[kKeyTo] {
                    let follow = SFollow(data: followObject)
                    let containsFollow = myFollowing.filter { $0!.objectId == follow.objectId }
                    // myFollowing does not contain new item, append
                    if containsFollow.count <= 0 {
                        myFollowing.append(follow)
                    }
                }
            }
            
            shouldLoadNextPage = objects.count == kItemsPerPage
            print("objects: \(shouldLoadNextPage)")
                
            if let completion = completion {
                print("completion: \(shouldLoadNextPage)")
                completion(true, shouldLoadNextPage)
            }
        }
    }
    
    class func refreshFollowers () {
        if let currentUser = PFUser.current(), myFollowersCountQuery == nil {
            myFollowersCountQuery = PFQuery(className: kClassNameFollow)
            myFollowersCountQuery?.whereKey(kKeyTo, equalTo: currentUser)
            myFollowersCountQuery?.whereKeyExists(kKeyFrom)
            myFollowersCountQuery?.whereKey(kKeyFrom, notEqualTo: NSNull())
			myFollowersCountQuery?.countObjectsInBackground(block: { (count, error) in
                myFollowersCountQuery = nil
                guard error == nil else {
                    return
                }
                
                myFollowersCount = Int(count)
                myFollowers = []
                myFollowersPages = []
                updateFollowers(completion: nil)
            })
        }
    }
    
    //Used for pagination
    class func updateFollowers(_ page : Int = 0, itemsPerPage : Int = kItemsPerPage , completion: ((_ success: Bool, _ shouldLoadNextPage: Bool) -> ())?) {
        guard !myFollowersPages.contains(page) else {
            return
        }
        myFollowersPages.append(page)
        
        PFCloud.callFunction(inBackground: kCloudFuncGetFollowers, withParameters: [kKeyPage:page, kKeyLimit:itemsPerPage]) { (result, error) -> Void in            
            guard error == nil, let objects = result as? [AnyObject] else {
                if let errorLocalized = error?.localizedDescription {
                    let errorData = errorLocalized.data(using: String.Encoding.utf8)
                    do {
                        let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                        if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                            // INVALID_SESSION_TOKEN
                            if errorCode == kParseErrorCodeInvalidSessionToken {
                                if let message = (errorJson as AnyObject).object(forKey: "message") as? String, message == "INVALID_SESSION_TOKEN" {
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kInvalidSessionTokenNotification), object: nil)
                                }
                            }
                        }
                    } catch {
                        
                    }
                }
                
                if let completion = completion {
                    completion(false, false)
                }
                return
            }
            
            var shouldLoadNextPage = false
            for object in objects {
                var sFollow: SFollow?
                var following = false
                
                if let followObject = object.object(forKey: kKeyFollowObject) as? PFObject {
                    sFollow = SFollow(data: followObject)
                }
                
                if let fol = object.object(forKey: kKeyFollowing) as? Bool {
                    following = fol
                }
                
                let containsFollow = myFollowers.filter { $0.follow!.objectId == sFollow!.objectId }
                // Check if myFollowers does not contain new item, append
                if containsFollow.count <= 0 {
                    myFollowers.append((follow: sFollow, following: following))
                }
            }
            
            if let completion = completion {
                shouldLoadNextPage = objects.count == kItemsPerPage
                completion(true, shouldLoadNextPage)
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    override init(data :PFObject) {
        super.init(data: data)
        
        // ObjectId
        objectId = data.objectId
        
        
        // fromUser
        if let parseFromUser = data[kKeyFrom] as? PFUser {
            fromUser = parseFromUser
        }
        
        // toUser
        if let parseToUser = data[kKeyTo] as? PFUser {
            toUser = parseToUser
        }
    }
}
