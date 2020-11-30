//
//  ShopifyShippingRateProvider.swift
//  Shelf
//
//  Created by Matthew James on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyCarrierServiceId = "carrier_service_id"
let kShopifyFlatModifier = "flat_modifier"
let kShopifyPercentModifier = "percent_modifier"
let kShopifyServiceFilter = "service_filter"

class ShopifyShippingRateProvider: Mappable { // NSObject, NSCoding, Mappable {
    var id: Int?
    var carrierServiceId: Int?
    var flatModifier: String?
    var percentModifier: Double?
    var serviceFilter: [String: String]?
    var shippingZoneId: Int?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kShopifyId]
        carrierServiceId        <- map[kShopifyCarrierServiceId]
        flatModifier            <- map[kShopifyFlatModifier]
        percentModifier         <- map[kShopifyPercentModifier]
        serviceFilter           <- map[kShopifyServiceFilter]
        shippingZoneId          <- map[kShopifyShippingZoneId]
    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(id, forKey: kShopifyId)
//        aCoder.encodeObject(carrierServiceId, forKey: kShopifyCarrierServiceId)
//        aCoder.encodeObject(flatModifier, forKey: kShopifyFlatModifier)
//        aCoder.encodeObject(percentModifier, forKey: kShopifyPercentModifier)
//        aCoder.encodeObject(serviceFilter, forKey: kShopifyServiceFilter)
//        aCoder.encodeObject(shippingZoneId, forKey: kShopifyShippingZoneId)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        id                      = aDecoder.decodeObjectForKey(kShopifyId) as? Int
//        carrierServiceId        = aDecoder.decodeObjectForKey(kShopifyCarrierServiceId) as? Int
//        flatModifier            = aDecoder.decodeObjectForKey(kShopifyFlatModifier) as? String
//        percentModifier         = aDecoder.decodeObjectForKey(kShopifyPercentModifier) as? Double
//        serviceFilter           = aDecoder.decodeObjectForKey(kShopifyServiceFilter) as? [String: String]
//        shippingZoneId          = aDecoder.decodeObjectForKey(kShopifyShippingZoneId) as? Int
//    }
}
