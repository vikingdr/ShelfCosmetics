//
//  ShopifyDiscountError.swift
//  Shelf
//
//  Created by Matthew James on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

class ShopifyDiscountError: Mappable {
    var code: [ShopifyError]?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        code                    <- map[kShopifyCode]
    }
}
