//
//  Color.swift
//  Shelf
//
//  Created by Matthew James on 30.06.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

let kCloudFuncAddCreatedBy = "addCreatedBy"

class SColor: SObject {

    var image : UIImage?
    var imageFile : PFFile?
    var thumbnail : PFFile?
    var brand = ""
    var comment = ""
    var colorName = ""
    var searchText = ""
    var id = ""
    var rating : Int?
    var numLikes = 0
    var numComments = 0
    var brand_color : PFObject?
    var createdBy : PFUser?
    var geopoint : PFGeoPoint?
    var numberOfCoats : Int?
    var locationName : String?
    var mapsnapShot : UIImage? // This is only used when creating the feed, this will not be uploaded to server
    var shopifyID : NSNumber?
    
    override init() {
        super.init()
    }
    
    override init(data :PFObject) {
        
        super.init(data: data)
        
        // id
        if let parseId = data.objectId {
            id = parseId
        }
        
        // brand
        if let parseBrand = data["brand"] as? String {
            brand = parseBrand
        }
        
        // comment
        if let parseComment = data["comment"] as? String {
            comment = parseComment
        }
        
        // colorName
        if let parseColorName = data["name"] as? String {
            colorName = parseColorName
        }
        
        // rating
        if let parseRating = data["rating"] as? Int {
            rating = parseRating
        }
        
        // searchText
        if let parseSearchText = data["searchText"] as? String {
            searchText = parseSearchText
        }

        // imageFile
        if let parseImageFile = data["image"] as? PFFile {
            imageFile = parseImageFile
        }
        
        // thumbnail
        if let parseThumbnailFile = data["photoThumbnail"] as? PFFile {
            thumbnail = parseThumbnailFile
        }
        
        // numLikes
        if let parseLikes = data["numLikes"] as? Int {
            numLikes = parseLikes as Int
        }
        
        // numComments
        if let parseComments = data["numComments"] as? Int {
            numComments = parseComments as Int
        }
        
        // createdBy
        if let parseAuthor = data["createdBy"] as? PFUser {
            createdBy = parseAuthor
        }
        
        // brand_Color
        if let parseBrandColor = data["brand_color"] as? PFObject {
            brand_color = parseBrandColor
        }
        
        if let parseCoats = data["coats"] as? Int {
            numberOfCoats = parseCoats
        }
        
        if let locName = data["locationName"] as? String{
            locationName = locName
        }
        
        if let location = data["location"] as? PFGeoPoint {
            geopoint = location
        }
        
    }
    
    func createAndSave () {
        // creating PFObject of Color and saving in background to server
        let colorObject = PFObject(className: "Color")
        let imgCompressed = compressImage(image!)
        imageFile = PFFile(name: "color.JPG", data: imgCompressed)
        
        colorObject["comment"] = comment
        colorObject["brand"] = brand
        colorObject["rating"] = rating
        colorObject["image"] = imageFile
        //colorObject["createdBy"] = PFUser.currentUser()
        colorObject["numLikes"] = 0
        colorObject["numComments"] = 0
        colorObject["name"] = colorName
        let searchText = colorName + brand
        colorObject["searchText"] = searchText.lowercased()
        colorObject["brand_color"] = brand_color
        if let geo = geopoint {
            colorObject["location"] = geo
        }
        if let loc = locationName {
            colorObject["locationName"] = loc
        }
        if let coats = numberOfCoats {
   
            colorObject["coats"] = coats
        }
        
        colorObject.saveInBackground { (succeeded, error) -> Void in
            guard error == nil && succeeded == true else {
                return
            }
            
            //Because a infinite loop is occuring by setting createdBy to currentUser
            PFCloud.callFunction(inBackground: kCloudFuncAddCreatedBy, withParameters: [kParseKeyColorId : colorObject.objectId!]) { (result, error) in
                guard error == nil, let _ = result else {
                    //remove the color object
                    colorObject.deleteInBackground()
                    
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
                    return
                }
                
                self.object = colorObject
                NSLog("Color saved")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ColorCreated"), object: nil)
                AnalyticsHelper.sendCustomEvent(kFIREventCreateAShelfieCompletion)
            }
        }
    }
}
