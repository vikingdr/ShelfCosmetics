//
//  SUser.swift
//  Shelf
//
//  Created by Nathan Konrad on 03.07.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class SUser: NSObject {
   
    var objectId : String?
    var imageFile : PFFile?
    var coverImage : PFFile?
    var email = ""
    var username = ""
    var firstName = ""
    var lastName = ""
    var searchText = ""
    var bio = ""
//    var following : [PFObject]?
//    var followers : [PFObject]?
    
    var object : PFUser?
    class var currentUser: SUser {
        get { return SUser(dataUser: PFUser.current()) }
    }
    
    override init() {
        super.init()
    }
    
    init(dataUser :PFObject?) {
        super.init()
        if let data = dataUser {
            // ObjectId
            objectId = data.objectId
            
            object = data as? PFUser

            // firstName
            if let parseFirstName = data["firstName"] as? String {
                firstName = parseFirstName
            }
            
            // lastName
            if let parseLastName = data["lastName"] as? String {
                lastName = parseLastName
            }
            
            // username
            if let parseUsername = data["username"] as? String {
                username = parseUsername
            }
            
            // email
            if let parseEmail = data["email"] as? String {
                email = parseEmail
            }
            
            // searchText
            if let parseSearchText = data["searchText"] as? String {
                searchText = parseSearchText
            }
            
            // imageFile
            if let parseImageFile = data["image"] as? PFFile {
                imageFile = parseImageFile
            }
            
            // coverImageFile
            if let parseCoverImage = data["coverImage"] as? PFFile {
                coverImage = parseCoverImage
            }
            
            // bio
            if let parseBio = data["bio"] as? String {
                bio = parseBio
            }
            
            // following
//            if let parseFollowing = data["following"] as? [PFObject] {
//                following = parseFollowing
//            }
//            
            // follower
//            if let parseFollowers = data["followers"] as? [PFObject] {
//                followers = parseFollowers
//            }else{
//                //It was an array of object IDs
//                var userPointers = [PFUser]()
//                if let followers = data["followers"] as? [AnyObject]{
//                    for dict in followers {
//                        if let dictionary = dict as? NSDictionary {
//                            if let objectId = dictionary["objectId"]{
//                                if let userObjectId = objectId as? String{
//                                    let user = PFUser.objectWithoutDataWithObjectId(userObjectId)
//                                    userPointers.append(user)
//                                }
//                            }
//                        }
//                        else if let user = dict as? PFUser {
//                            let user = PFUser.objectWithoutDataWithObjectId(user.objectId)
//                            userPointers.append(user)
//                        }
//                    }
//                    self.followers = userPointers
//                }
//            }
    }
    }
}
