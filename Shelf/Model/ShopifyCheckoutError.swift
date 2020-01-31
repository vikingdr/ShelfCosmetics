//
//  ShopifyCheckoutError.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyCreditCard = "credit_card"
let kShopifyPaymentGateway = "payment_gateway"
let kShopifyDiscount = "discount"
let kShopifyShippingRate = "shipping_rate"

class ShopifyCheckoutError: Mappable {
    var creditCard: ShopifyCreditCardError?
    var paymentGateway: [ShopifyError]?
    var discount: ShopifyDiscountError?
    var shippingRate: ShopifyShippingRateError?
    var lineItems: [ShopifyLineItemError?]?
    var sourceName: [AnyObject]?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        creditCard              <- map[kShopifyCreditCard]
        paymentGateway          <- map[kShopifyPaymentGateway]
        discount                <- map[kShopifyDiscount]
        shippingRate            <- map[kShopifyShippingRate]
        // For multiple products, "<null>" is being returned if there's no error for the line item
        lineItems               = mapArrayOfLineItemOptionals(map, field: kShopifyLineItems)
        sourceName              <- map[kShopifySourceName]
    }
    
    fileprivate func mapArrayOfLineItemOptionals(_ map: Map, field: String) -> [ShopifyLineItemError?] {
        if let values = map[field].value() as [AnyObject]? {
            var resultValues = [ShopifyLineItemError?]()
            for value in values {
				let value1 = value as! [String: AnyObject]
                if value is NSNull {
                    resultValues.append(nil)
                } else if let _ = value1[kShopifyQuantity] {
                    if let shopifyLineItemError = ShopifyLineItemError(JSON: value as! [String: AnyObject]) {
                        resultValues.append(shopifyLineItemError)
                    }
                }
            }
            return resultValues
        }
        
        return []
    }
}
