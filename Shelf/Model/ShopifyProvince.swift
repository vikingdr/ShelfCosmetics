//
//  ShopifyProvince.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyCountryId = "country_id"
let kShopifyTaxType = "tax_type"
let kShopifyShippingZoneId = "shipping_zone_id"
let kShopifyTaxPercentage = "tax_percentage"

class ShopifyProvince: Mappable { // NSObject, NSCoding, Mappable {
    var id: Int?
    var countryId: Int?
    var name: String?
    var code: String?
    var tax: Double?
    var taxName: String?
    var taxType: AnyObject?
    var shippingZoneId: Int?
    var taxPercentage: Double?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kShopifyId]
        countryId               <- map[kShopifyCountryId]
        name                    <- map[kShopifyName]
        code                    <- map[kShopifyCode]
        tax                     <- map[kShopifyTax]
        taxName                 <- map[kShopifyTaxName]
        taxType                 <- map[kShopifyTaxType]
        shippingZoneId          <- map[kShopifyShippingZoneId]
        taxPercentage           <- map[kShopifyTaxPercentage]
    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(id, forKey: kShopifyId)
//        aCoder.encodeObject(countryId, forKey: kShopifyCountryId)
//        aCoder.encodeObject(name, forKey: kShopifyName)
//        aCoder.encodeObject(code, forKey: kShopifyCode)
//        aCoder.encodeObject(tax, forKey: kShopifyTax)
//        aCoder.encodeObject(taxName, forKey: kShopifyTaxName)
//        aCoder.encodeObject(taxType, forKey: kShopifyTaxType)
//        aCoder.encodeObject(shippingZoneId, forKey: kShopifyShippingZoneId)
//        aCoder.encodeObject(taxPercentage, forKey: kShopifyTaxPercentage)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        id                      = aDecoder.decodeObjectForKey(kShopifyId) as? Int
//        countryId               = aDecoder.decodeObjectForKey(kShopifyCountryId) as? Int
//        name                    = aDecoder.decodeObjectForKey(kShopifyName) as? String
//        code                    = aDecoder.decodeObjectForKey(kShopifyCode) as? String
//        tax                     = aDecoder.decodeObjectForKey(kShopifyTax) as? Double
//        taxName                 = aDecoder.decodeObjectForKey(kShopifyTaxName) as? String
//        taxType                 = aDecoder.decodeObjectForKey(kShopifyTaxType) as? String
//        shippingZoneId          = aDecoder.decodeObjectForKey(kShopifyShippingZoneId) as? Int
//        taxPercentage           = aDecoder.decodeObjectForKey(kShopifyTaxPercentage) as? Double
//    }
}
