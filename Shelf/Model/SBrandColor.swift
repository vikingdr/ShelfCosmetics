//
//  SBrandColor.swift
//  Shelf
//
//  Created by Matthew James on 27.07.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

class SBrandColor: SObject {
    var image : PFFile?
    var brand = ""
    var name = ""
    var code = ""
    var hex = ""
    var colorDescription = ""
    var shopifyID : Int?
    
    override init() {
        super.init()
    }
    
    override init(data :PFObject) {
        
        super.init(data: data)
        
        // brand
        if let parseBrand = data["brand"] as? String {
            brand = parseBrand
        }
        
        // image
        if let parseImage = data["image"] as? PFFile {
            image = parseImage
        }
        
        // name
        if let parseName = data["name"] as? String {
            name = parseName
        }
        
        // code
        if let parseCode = data["code"] as? String {
            code = parseCode
        }
        
        if let parseHex = data["colorHex"] as? String {
            hex = parseHex
        }
        
        if let parseColorDescription = data["description"] as? String {
            colorDescription = parseColorDescription
        }
        
        if let sID = data["ShopifyID"] as? Int {
            shopifyID = sID
        }
    }

}
