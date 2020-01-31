//
//  ShopifyError.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyOptions = "options"

class ShopifyError: Mappable {
    var code: String?
    var message: String?
    var options: ShopifyOptions?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        code                    <- map[kShopifyCode]
        message                 <- map[kShopifyMessage]
        options                 <- map[kShopifyOptions]
    }
}
