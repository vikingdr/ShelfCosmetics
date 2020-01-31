//
//  ShopifyCreditCardError.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyMonth = "month"
let kShopifyYear = "year"
let kShopifyVerificationValue = "verification_value"

class ShopifyCreditCardError: Mappable {
    var number: [ShopifyError]?
    var month: [ShopifyError]?
    var year: [ShopifyError]?
    var verifcationValue: [ShopifyError]?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        number                  <- map[kShopifyNumber]
        month                   <- map[kShopifyMonth]
        year                    <- map[kShopifyYear]
        verifcationValue        <- map[kShopifyVerificationValue]
    }
}
