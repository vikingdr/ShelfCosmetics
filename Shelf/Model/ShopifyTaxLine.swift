//
//  ShopifyTaxLine.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/4/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyRate = "rate"

class ShopifyTaxLine: Mappable {
    var title: String?
    var price: Double?
    var rate: Double?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        title                   <- map[kShopifyTitle]
        price                   <- map[kShopifyPrice]
        rate                    <- map[kShopifyRate]
    }
}
