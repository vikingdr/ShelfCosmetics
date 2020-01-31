//
//  ShopifyCountry.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyTax = "tax"
let kShopifyTaxName = "tax_name"
let kShopifyProvinces = "provinces"

class ShopifyCountry: Mappable { // NSObject, NSCoding, Mappable {
    var id: Int?
    var name: String?
    var tax: Double?
    var code: String?
    var taxName: String?
    var provinces: [ShopifyProvince]?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kShopifyId]
        name                    <- map[kShopifyName]
        tax                     <- map[kShopifyTax]
        taxName                 <- map[kShopifyTaxName]
        code                    <- map[kShopifyCode]
        provinces               <- map[kShopifyProvinces]
    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(id, forKey: kShopifyId)
//        aCoder.encodeObject(name, forKey: kShopifyName)
//        aCoder.encodeObject(tax, forKey: kShopifyTax)
//        aCoder.encodeObject(taxName, forKey: kShopifyTaxName)
//        aCoder.encodeObject(code, forKey: kShopifyCode)
//        aCoder.encodeObject(provinces, forKey: kShopifyProvinces)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        id                      = aDecoder.decodeObjectForKey(kShopifyId) as? Int
//        name                    = aDecoder.decodeObjectForKey(kShopifyName) as? String
//        tax                     = aDecoder.decodeObjectForKey(kShopifyTax) as? Double
//        taxName                 = aDecoder.decodeObjectForKey(kShopifyTaxName) as? String
//        code                    = aDecoder.decodeObjectForKey(kShopifyCode) as? String
//        provinces               = aDecoder.decodeObjectForKey(kShopifyProvinces) as? [ShopifyProvince]
//    }
}
