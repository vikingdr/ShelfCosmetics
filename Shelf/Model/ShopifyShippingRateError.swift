//
//  ShopifyShippingRateError.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

class ShopifyShippingRateError: Mappable {
    var id: [ShopifyError]?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kShopifyId]
    }
}
