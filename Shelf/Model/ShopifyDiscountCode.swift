//
//  ShopifyDiscountCode.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/4/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyAmount = "amount"
let kShopifyType = "type"

class ShopifyDiscountCode: Mappable {
    var amount: String?
    var code: String?
    var type: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        amount                  <- map[kShopifyAmount]
        code                    <- map[kShopifyCode]
        type                    <- map[kShopifyType]
    }
}
