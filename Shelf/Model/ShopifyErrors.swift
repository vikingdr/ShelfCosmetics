//
//  ShopifyErrors.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyCheckout = "checkout"

class ShopifyErrors: Mappable {
    var checkout: ShopifyCheckoutError?
    
    init() {
    
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        checkout                <- map[kShopifyCheckout]
    }
}
