//
//  ShopifyLineItemError.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

class ShopifyLineItemError: Mappable {
    var quantity: [ShopifyError]?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        quantity                <- map[kShopifyQuantity]
    }
}
