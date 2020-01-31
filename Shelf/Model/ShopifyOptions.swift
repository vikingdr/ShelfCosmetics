//
//  ShopifyOptions.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyRawGatewayError = "raw_gateway_error"

class ShopifyOptions: Mappable {
    var rawGatewayError: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        rawGatewayError         <- map[kShopifyRawGatewayError]
    }
}
