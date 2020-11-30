//
//  ShopifyLineItem.swift
//  Shelf
//
//  Created by Matthew James on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyVariantId = "variant_id"
let kShopifyQuantity = "quantity"
let kShopifyGrams = "grams"
let kShopifySku = "sku"
let kShopifyVariantTitle = "variant_title"
let kShopifyVendor = "vendor"
let kShopifyFulfillmentService = "fulfillment_service"
let kShopifyProductId = "product_id"
let kShopifyRequiresShipping = "requires_shipping"
let kShopifyTaxable = "taxable"
let kShopifyGiftCard = "gift_card"
let kShopifyVariantInventoryManagement = "variant_inventory_management"
let kShopifyProperties = "properties"
let kShopifyProductExists = "product_exists"
let kShopifyFulfillableQuantity = "fulfillable_quantity"
let kShopifyOriginalLocation = "original_location"
let kShopifyDestinationLocation = "destination_location"

class ShopifyLineItem: Mappable {
    var id: Int?
    var variantId: Int?
    var title: String?
    var quantity: Int?
    var price: String?
    var grams: Int?
    var sku: String?
    var variantTitle: String?
    var vendor: String?
    var fulfillmentService: String?
    var productId: Int?
    var requiresShipping: Bool?
    var taxable: Bool?
    var giftCard: Bool?
    var name: String?
    var variantInventoryManagement: AnyObject? // TODO: ??
    var properties = [Any]() // TODO: ??
    var productExists: Bool?
    var fulfillableQuanity: Int?
    var totalDiscount: String?
    var fulfillmentStatus: String?
    var taxLines: [ShopifyTaxLine]?
    var originalLocation: ShopifyAddress?
    var destinationLocation: ShopifyAddress?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                              <- map[kShopifyId]
        variantId                       <- map[kShopifyVariantId]
        title                           <- map[kShopifyTitle]
        quantity                        <- map[kShopifyQuantity]
        price                           <- map[kShopifyPrice]
        grams                           <- map[kShopifyGrams]
        sku                             <- map[kShopifySku]
        variantTitle                    <- map[kShopifyVariantTitle]
        vendor                          <- map[kShopifyVendor]
        fulfillmentService              <- map[kShopifyFulfillmentService]
        productId                       <- map[kShopifyProductId]
        requiresShipping                <- map[kShopifyRequiresShipping]
        taxable                         <- map[kShopifyTaxable]
        giftCard                        <- map[kShopifyGiftCard]
        name                            <- map[kShopifyName]
        variantInventoryManagement      <- map[kShopifyVariantInventoryManagement]
        properties                      <- map[kShopifyProperties]
        productExists                   <- map[kShopifyProductExists]
        fulfillableQuanity              <- map[kShopifyFulfillableQuantity]
        totalDiscount                   <- map[kShopifyTotalDiscounts]
        fulfillmentStatus               <- map[kShopifyFulfillmentStatus]
        taxLines                        <- map[kShopifyTaxLines]
        originalLocation                <- map[kShopifyOriginalLocation]
        destinationLocation             <- map[kShopifyDestinationLocation]
    }
}
