//
//  BUY+Extensions.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy

private var client: BUYClient!
extension BUYClient {
    
    static var sharedClient: BUYClient {
        if client == nil {
            //Shopify
            client = BUYClient(shopDomain: kShopifyDomain, apiKey: kShopifyAPIKey, appId: kShopifyAppId)
        }
        
        return client
    }
}

private var cart: BUYCart!
private var mutableLineItems: NSMutableOrderedSet = NSMutableOrderedSet()
extension BUYCart {
    
    static var sharedCart: BUYCart {
        if cart == nil {
            cart = BUYCart(modelManager: BUYClient.sharedClient.modelManager, jsonDictionary: nil)
        }
        
        return cart
    }
    
    func mutableLineItemsArray() -> [BUYCartLineItem] {
        return mutableLineItems.array as! [BUYCartLineItem]
    }
    
    func clearExistingCart() {
        cart.clear()
        mutableLineItems = NSMutableOrderedSet()
    }
    
    func removeVariantFromExisiting(_ variant: BUYProductVariant) {
        if let lineItem = lineItemForVariant(variant) {
            mutableLineItems.remove(lineItem)
        }
    }
    
    func setVariantToExisting(_ variant: BUYProductVariant, withTotalQuantity quantity: UInt64) -> Bool {
        let quantity = NSDecimalNumber(mantissa: quantity, exponent: 0, isNegative: false)
        
        if let lineItem = checkVariantExistInCart(variant) {
            lineItem.quantity = quantity
            return false
        }
        
        let lineItem = newCartLineItemWithVariant(variant)
        lineItem.quantity = quantity
        mutableLineItems.add(lineItem)
        return true
    }
    
    func checkVariantExistInCart(_ variant: BUYProductVariant?) -> BUYCartLineItem? {
        guard let variant = variant else {
            return nil
        }
        
        let lineItems = mutableLineItemsArray()
        
        for lineItem in lineItems {
            if variant.product.identifier == lineItem.variant.product.identifier
                && variant.identifier == lineItem.variantId() {
                return lineItem
            }
        }
        
        return nil
    }
    
    func newCartLineItemWithVariant(_ variant: BUYProductVariant) -> BUYCartLineItem {
        let lineItem = BUYClient.sharedClient.modelManager.buy_object(withEntityName: BUYCartLineItem.entityName(), jsonDictionary: nil) as! BUYCartLineItem
        lineItem.variant = variant
        return lineItem
    }
    
    func lineItemForVariant(_ variant: BUYProductVariant) -> BUYCartLineItem? {
        return mutableLineItems.filtered(using: NSPredicate(format: "variant = %@", variant)).lastObject as? BUYCartLineItem
    }
    
    func setLineItems() {
        lineItems = mutableLineItems
    }
}
