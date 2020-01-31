//
//  ShopifyReceipt.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyPaidAmount = "paid_amount"  

class ShopifyReceipt: Mappable {
    var paidAmount: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        paidAmount              <- map[kShopifyPaidAmount]
    }
}
