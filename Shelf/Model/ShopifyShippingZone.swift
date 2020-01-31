//
//  ShopifyShippingZone.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyShippingZones = "shipping_zones"
let kShopifyCountries = "countries"
let kShopifyWeightBasedShippingRates = "weight_based_shipping_rates"
let kShopifyPriceBasedShippingRates = "price_based_shipping_rates"
let kShopifyCarrierShippingRateProviders = "carrier_shipping_rate_provider"

class ShopifyShippingZone: Mappable { // NSObject, NSCoding, Mappable {
    var id: Int?
    var name: String?
    var countries: [ShopifyCountry]?
    var weightBasedShippingRates: [ShopifyShippingRate]?
    var priceBasedShippingRates: [ShopifyShippingRate]?
    var carrierShippingRateProviders: [ShopifyShippingRateProvider]?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                              <- map[kShopifyId]
        name                            <- map[kShopifyName]
        countries                       <- map[kShopifyCountries]
        weightBasedShippingRates        <- map[kShopifyWeightBasedShippingRates]
        priceBasedShippingRates         <- map[kShopifyPriceBasedShippingRates]
        carrierShippingRateProviders    <- map[kShopifyCarrierShippingRateProviders]
    }
    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(id, forKey: kShopifyId)
//        aCoder.encodeObject(name, forKey: kShopifyName)
//        aCoder.encodeObject(countries, forKey: kShopifyCountries)
//        aCoder.encodeObject(weightBasedShippingRates, forKey: kShopifyWeightBasedShippingRates)
//        aCoder.encodeObject(priceBasedShippingRates, forKey: kShopifyPriceBasedShippingRates)
//        aCoder.encodeObject(carrierShippingRateProviders, forKey: kShopifyCarrierShippingRateProviders)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        id                              = aDecoder.decodeObjectForKey(kShopifyId) as? Int
//        name                            = aDecoder.decodeObjectForKey(kShopifyName) as? String
//        countries                       = aDecoder.decodeObjectForKey(kShopifyCountries) as? [ShopifyCountry]
//        weightBasedShippingRates        = aDecoder.decodeObjectForKey(kShopifyWeightBasedShippingRates) as? [ShopifyShippingRate]
//        priceBasedShippingRates         = aDecoder.decodeObjectForKey(kShopifyPriceBasedShippingRates) as? [ShopifyShippingRate]
//        carrierShippingRateProviders    = aDecoder.decodeObjectForKey(kShopifyCarrierShippingRateProviders) as? [ShopifyShippingRateProvider]
//    }
}
