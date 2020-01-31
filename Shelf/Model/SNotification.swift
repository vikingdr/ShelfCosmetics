//
//  Color.swift
//  Shelf
//
//  Created by Nathan Konrad on 30.06.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class SNotification: SObject {

    var fromUser : PFUser?
    var toUser : PFUser?
    var type = ""
    var color : PFObject?
    var comment : PFObject?
    
    override init() {
        super.init()
    }
    
    override  init(data :PFObject) {
        super.init(data: data)
        

        
        // type
        if let parseType = data["type"] as? String {
            type = parseType
        }
        
        // fromUser
        if let parseFromUser = data["fromUser"] as? PFUser {
            fromUser = parseFromUser
        }
        
        // toUser
        if let parseToUser = data["toUser"] as? PFUser {
            toUser = parseToUser
        }

        if let parseColor = data["color"] as? PFObject {
            color = parseColor
        }
        
        if let parseComment = data["comment"] as? PFObject {
            comment = parseComment
        }
    }
}
