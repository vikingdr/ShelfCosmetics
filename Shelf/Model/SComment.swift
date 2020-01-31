//
//  SComment.swift
//  Shelf
//
//  Created by Nathan Konrad on 22/07/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class SComment: SObject {
    
    var user        : PFUser?
    var color       : SColor?
    var message     : String?
    var updatedAt   : Date?
    var userTags    : [String] = []
    
    override init() {
        super.init()
    }
    
    override init(data: PFObject) {
        super.init(data : data)
        // user
        if let parseNameAuthor = data["user"] as? PFUser {
            self.user = parseNameAuthor
        }
        
        // text
        if let parseText = data["message"] as? String {
            self.message = parseText
        }
        
        // updated at
        if let parseUpdatedAt = data["updatedAt"] as? Date {
            self.updatedAt = parseUpdatedAt
        }
    }
    
    // MARK: -
    
    func save(_ onSuccess : @escaping (_ comment: SComment) -> Void, onFailed: @escaping (_ error: NSError) -> Void) {
        
//        let object = PFObject(className: "Comment")
//        object["user"]          = self.user
//        object["message"]       = self.message
//        object["color"]         = self.color?.object
//        object["userTags"]      = self.userTags
//
//        object.saveInBackgroundWithBlock { (success, error) -> Void in
//            if error == nil {
//                self.createdAt  = NSDate()
//                self.object     = object
//                onSuccess(comment: self)
//            } else {
//                onFailed(error: error!)
//            }
//            
//        }
        PFCloud.callFunction(inBackground: "addComment", withParameters: ["message":self.message!,"colorId":self.color!.objectId!,"userTags": self.userTags]) { (result, error) -> Void in
            guard error == nil else {
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
                
                onFailed(error! as NSError)
                return
            }
            
            self.createdAt = Date()
            onSuccess(self)
        }
    }
}
