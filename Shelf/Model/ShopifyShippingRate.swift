//
//  ShopifyShippingRate.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyWeightLow = "weight_low"
let kShopifyWeightHigh = "weight_high"
let kShopifyMinOrderSubtotal = "min_order_subtotal"
let kShopifyMaxOrderSubtotal = "max_order_subtotal"

class ShopifyShippingRate: Mappable { // NSObject, NSCoding, Mappable {
    var id: Int?
    var weightLow: Int?
    var weightHigh: Int?
    var minOrderSubtotal: String?
    var maxOrderSubtotal: String?
    var name: String?
    var price: String?
    var shippingZoneId: Int?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kShopifyId]
        weightLow               <- map[kShopifyWeightLow]
        weightHigh              <- map[kShopifyWeightHigh]
        minOrderSubtotal        <- map[kShopifyMinOrderSubtotal]
        maxOrderSubtotal        <- map[kShopifyMaxOrderSubtotal]
        name                    <- map[kShopifyName]
        price                   <- map[kShopifyPrice]
        shippingZoneId          <- map[kShopifyShippingZoneId]
    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(id, forKey: kShopifyId)
//        aCoder.encodeObject(weightLow, forKey: kShopifyWeightLow)
//        aCoder.encodeObject(weightHigh, forKey: kShopifyWeightHigh)
//        aCoder.encodeObject(minOrderSubtotal, forKey: kShopifyMinOrderSubtotal)
//        aCoder.encodeObject(maxOrderSubtotal, forKey: kShopifyMaxOrderSubtotal)
//        aCoder.encodeObject(name, forKey: kShopifyName)
//        aCoder.encodeObject(price, forKey: kShopifyPrice)
//        aCoder.encodeObject(shippingZoneId, forKey: kShopifyShippingZoneId)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        id                      = aDecoder.decodeObjectForKey(kShopifyId) as? Int
//        weightLow               = aDecoder.decodeObjectForKey(kShopifyWeightLow) as? Int
//        weightHigh              = aDecoder.decodeObjectForKey(kShopifyWeightHigh) as? Int
//        minOrderSubtotal        = aDecoder.decodeObjectForKey(kShopifyMinOrderSubtotal) as? String
//        maxOrderSubtotal        = aDecoder.decodeObjectForKey(kShopifyMaxOrderSubtotal) as? String
//        name                    = aDecoder.decodeObjectForKey(kShopifyName) as? String
//        price                   = aDecoder.decodeObjectForKey(kShopifyPrice) as? String
//        shippingZoneId          = aDecoder.decodeObjectForKey(kShopifyShippingZoneId) as? Int
//    }
}
