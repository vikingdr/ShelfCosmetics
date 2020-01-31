//
//  ShopifyShippingLine.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyTitle = "title"
let kShopifyPrice = "price"
let kShopifyCode = "code"
let kShopifySource = "source"
let kShopifyRequestedFulfillmentServiceId = "requested_fulfillment_service_id"
let kShopifyDeliveryCategory = "delivery_category"
let kShopifyCarrierIdentifier = "carrier_identifer"

class ShopifyShippingLine: Mappable {
    var id: String?
    var title: String?
    var price: String?
    var code: String?
    var source: String?
    var phone: String?
    var requestedFulfillmentServiceId: String?
    var deliveryCategory: String?
    var carrierIdentifier: String?
    var taxLines = [Any]()
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                              <- map[kShopifyId]
        title                           <- map[kShopifyTitle]
        price                           <- map[kShopifyPrice]
        code                            <- map[kShopifyCode]
        source                          <- map[kShopifySource]
        phone                           <- map[kShopifyPhone]
        requestedFulfillmentServiceId   <- map[kShopifyRequestedFulfillmentServiceId]
        deliveryCategory                <- map[kShopifyDeliveryCategory]
        carrierIdentifier               <- map[kShopifyCarrierIdentifier]
        taxLines                        <- map[kShopifyTaxLines]
    }
}
