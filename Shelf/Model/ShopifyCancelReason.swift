//
//  ShopifyCancelReason.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/4/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyFraud = "fraud"
let kShopifyInventory = "inventory"
let kShopifyOther = "other"

class ShopifyCancelReason: Mappable {
    var customer: ShopifyCustomer?
    var fraud: AnyObject?
    var inventory: AnyObject?
    var other: AnyObject?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        customer                <- map[kShopifyCustomer]
        fraud                   <- map[kShopifyFraud]
        inventory               <- map[kShopifyInventory]
        other                   <- map[kShopifyOther]
    }
}
