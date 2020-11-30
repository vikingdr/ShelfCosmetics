//
//  SLike.swift
//  Shelf
//
//  Created by Matthew James on 24/07/15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

let kClassNameLike = "Like"
let kKeyUser = "user"
let kKeyColor = "color"

class SLike: SObject {
    var user    : PFUser?
    var color   : SColor?
    
    override init() {
        super.init()
    }
    
    override init(data : PFObject) {
        super.init(data: data)
        
        // user
        if let parseUser = data[kKeyUser] as? PFUser {
            user = parseUser
        }
    }
    
    
    
}
