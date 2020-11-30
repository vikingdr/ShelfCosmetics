//
//  ShopifyCustomer.swift
//  Shelf
//
//  Created by Matthew James on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyAcceptsMarketing = "accepts_marketing"
let kShopifyFirstName = "first_name"
let kShopifyLastName = "last_name"
let kShopifyOrdersCount = "orders_count"
let kShopifyState = "state"
let kShopifyTotalSpent = "total_spent"
let kShopifyLastOrderId = "last_order_id"
let kShopifyVerifiedEmail = "verified_email"
let kShopifyMultipassIdentifier = "multipass_identifier"
let kShopifyTaxExempt = "tax_exempt"
let kShopifyLastOrderName = "last_order_name"
let kShopifyDefaultAddress = "default_address"

class ShopifyCustomer: Mappable {
    var email: String?
    var acceptsMarketing: Bool?
    var createdAt: String?
    var updatedAt: String?
    var firstName: String?
    var lastName: String?
    var ordersCount: Int?
    var state: String?
    var totalSpent: String?
    var lastOrderId: String?
    var note: String?
    var verifiedEmail: Bool?
    var mulitipassIdentifier: String?
    var taxExempt: Bool?
    var tags: String?
    var lastOrderName: String?
    var defaultAddress: ShopifyAddress?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        email                   <- map[kShopifyEmail]
        acceptsMarketing        <- map[kShopifyAcceptsMarketing]
        createdAt               <- map[kShopifyCreatedAt]
        updatedAt               <- map[kShopifyUpdatedAt]
        firstName               <- map[kShopifyFirstName]
        lastName                <- map[kShopifyLastName]
        ordersCount             <- map[kShopifyOrdersCount]
        state                   <- map[kShopifyState]
        totalSpent              <- map[kShopifyTotalSpent]
        lastOrderId             <- map[kShopifyLastOrderId]
        note                    <- map[kShopifyNote]
        verifiedEmail           <- map[kShopifyVerifiedEmail]
        mulitipassIdentifier    <- map[kShopifyMultipassIdentifier]
        taxExempt               <- map[kShopifyTaxExempt]
        tags                    <- map[kShopifyTags]
        lastOrderName           <- map[kShopifyLastOrderName]
        defaultAddress          <- map[kShopifyDefaultAddress]
    }
}
