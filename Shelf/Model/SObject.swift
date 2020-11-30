//
//  SObject.swift
//  Shelf
//
//  Created by Matthew James on 20.07.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class SObject: NSObject {
       var objectId : String?
    var object : PFObject?
    var createdAt : Date?

    
   
    override init() {
        super.init()
    }
    
    init(data :PFObject) {
        super.init()
        
        object = data
        
        // ObjectId
        objectId = data.objectId
        
        //createdAt
        createdAt = data.createdAt
    }
}
