//
//  ParseShopifyProduct.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/4/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kParseId = "id"
let kParseKImageUrl = "imageUrl"

class ParseShopifyProduct: Mappable {
    var id: String?
    var imageUrl: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kParseId]
        imageUrl                   <- map[kParseKImageUrl]
    }
}
