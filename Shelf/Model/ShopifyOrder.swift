//
//  ShopifyOrder.swift
//  Shelf
//
//  Created by Matthew James on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyOrder = "order"
let kShopifyId = "id"
let kShopifyEmail = "email"
let kShopifyClosedAt = "closed_at"
let kShopifyCreatedAt = "created_at"
let kShopifyUpdatedAt = "updated_at"
let kShopifyNumber = "number"
let kShopifyNote = "note"
let kShopifyToken = "token"
let kShopifyGateway = "gateway"
let kShopifyTest = "test"
let kShopifyTotalPrice = "total_price"
let kShopifySubtotalPrice = "subtotal_price"
let kShopifyTotalWeight = "total_weight"
let kShopifyTotalTax = "total_tax"
let kShopifyTaxesIncluded = "taxes_included"
let kShopifyCurrency = "currency"
let kShopifyFinancialStatus = "financial_status"
let kShopifyConfirmed = "confirmed"
let kShopifyTotalDiscounts = "total_discounts"
let kShopifyTotalLineItemsPrice = "total_line_items_price"
let kShopifyCartToken = "cart_token"
let kShopifyBuyerAcceptsMarketing = "buyer_accepts_marketing"
let kShopifyName = "name"
let kShopifyReferringSite = "referring_site"
let kShopifyLandingSite = "landing_site"
let kShopifyCancelledAt = "cancelled_at"
let kShopifyCancelReason = "cancel_reason"
let kShopifyTotalPriceUsd = "total_price_usd"
let kShopifyCheckoutToken = "checkout_token"
let kShopifyReference = "reference"
let kShopifyUserId = "user_id"
let kShopifyLocationId = "location_id"
let kShopifySourceIdentifier = "source_identifier"
let kShopifySourceUrl = "source_url"
let kShopifyProcessedAt = "processed_at"
let kShopifyDeviceId = "device_id"
let kShopifyLandingSiteRef = "landing_site_ref"
let kShopifyOrderNumber = "order_number"
let kShopifyDiscountCodes = "discount_codes"
let kShopifyNoteAttributes = "note_attributes"
let kShopifyPaymentGatewayNames = "payment_gateway_names"
let kShopifyProcessingMethod = "processing_method"
let kShopifyCheckoutId = "checkout_id"
let kShopifySourceName = "source_name"
let kShopifyFulfillmentStatus = "fulfillment_status"
let kShopifyTaxLines = "tax_lines"
let kShopifyTags = "tags"
let kShopifyContactEmail = "contact_email"
let kShopifyOrderStatusUrl = "order_status_url"
let kShopifyLineItems = "line_items"
let kShopifyShippingLines = "shipping_lines"
let kShopifyBillingAddress = "billing_address"
let kShopifyShippingAddress = "shipping_address"
let kShopifyFulfillments = "fulfillments"
let kShopifyClientDetails = "client_details"
let kShopifyRefunds = "refunds"
let kShopifyPaymentDetails = "payment_details"
let kShopifyCustomer = "customer"
let kShopifyTransaction = "transaction"

class ShopifyOrder: Mappable {
    var id: Int?
    var email: String?
    var closedAt: String?
    var createdAt: String?
    var updatedAt: String?
    var number: Int?
    var note: String?
    var token: String?
    var gateway: String?
    var test: Bool?
    var totalPrice: String?
    var subtotalPrice: String?
    var totalWeight: Int?
    var totalTax: String?
    var taxesIncluded: Bool?
    var currency: String?
    var financialStatus: String?
    var confirmed: Bool?
    var totalDiscounts: String?
    var totalLineItemsPrice: String?
    var cart_token: String?
    var buyerAcceptsMarketing: Bool?
    var name: String?
    var referringSite: String?
    var landingSite: String?
    var cancelledAt: String?
    var cancelReason: ShopifyCancelReason?
    var totalPriceUsd: String?
    var checkoutToken: String?
    var reference: String?
    var userId: Int?
    var locationId: AnyObject?
    var sourceIdentifier: AnyObject?
    var sourceUrl: AnyObject?
    var processAt: String?
    var deviceId: AnyObject?
    var browserIp: String?
    var landingSiteRef: AnyObject?
    var orderNumber: Int?
    var discountCodes: [ShopifyDiscountCode]?
    var noteAttributes: [String: String]?
    var paymentGatewayNames: [String]?
    var processingMethod: String?
    var checkoutId: Int?
    var sourceName: String?
    var fulfillmentStatus: AnyObject?
    var taxLines: [ShopifyTaxLine]?
    var tags: String?
    var contactEmail: String?
    var orderStatusUrl: String?
    var lineItems: [ShopifyLineItem]?
    var shippingLines: [ShopifyShippingLine]?
    var billingAddress: ShopifyAddress?
    var shippingAddress: ShopifyAddress?
    var fulfillments: AnyObject?
    var clientDetails: ShopifyClientDetail?
    var refunds: AnyObject?
    var paymentDetails: ShopifyPaymentDetail?
    var customer: ShopifyCustomer?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kShopifyId]
        email                   <- map[kShopifyEmail]
        closedAt                <- map[kShopifyClosedAt]
        createdAt               <- map[kShopifyCreatedAt]
        updatedAt               <- map[kShopifyUpdatedAt]
        number                  <- map[kShopifyNumber]
        note                    <- map[kShopifyNote]
        token                   <- map[kShopifyToken]
        gateway                 <- map[kShopifyGateway]
        test                    <- map[kShopifyTest]
        totalPrice              <- map[kShopifyTotalPrice]
        subtotalPrice           <- map[kShopifySubtotalPrice]
        totalWeight             <- map[kShopifyTotalWeight]
        totalTax                <- map[kShopifyTotalTax]
        taxesIncluded           <- map[kShopifyTaxesIncluded]
        currency                <- map[kShopifyCurrency]
        financialStatus         <- map[kShopifyFinancialStatus]
        confirmed               <- map[kShopifyConfirmed]
        totalDiscounts          <- map[kShopifyTotalDiscounts]
        totalLineItemsPrice     <- map[kShopifyTotalLineItemsPrice]
        cart_token              <- map[kShopifyCartToken]
        buyerAcceptsMarketing   <- map[kShopifyBuyerAcceptsMarketing]
        name                    <- map[kShopifyName]
        referringSite           <- map[kShopifyReferringSite]
        landingSite             <- map[kShopifyLandingSite]
        cancelledAt             <- map[kShopifyCancelledAt]
        cancelReason            <- map[kShopifyCancelReason]
        totalPriceUsd           <- map[kShopifyTotalPriceUsd]
        checkoutToken           <- map[kShopifyCheckoutToken]
        reference               <- map[kShopifyReference]
        userId                  <- map[kShopifyUserId]
        locationId              <- map[kShopifyLocationId]
        sourceIdentifier        <- map[kShopifySourceIdentifier]
        sourceUrl               <- map[kShopifySourceUrl]
        processAt               <- map[kShopifyProcessedAt]
        deviceId                <- map[kShopifyDeviceId]
        browserIp               <- map[kShopifyBrowserIp]
        landingSiteRef          <- map[kShopifyLandingSiteRef]
        orderNumber             <- map[kShopifyOrderNumber]
        discountCodes           <- map[kShopifyDiscountCodes]
        noteAttributes          <- map[kShopifyNoteAttributes]
        paymentGatewayNames     <- map[kShopifyPaymentGatewayNames]
        processingMethod        <- map[kShopifyProcessingMethod]
        checkoutId              <- map[kShopifyCheckoutId]
        sourceName              <- map[kShopifySourceName]
        fulfillmentStatus       <- map[kShopifyFulfillmentStatus]
        taxLines                <- map[kShopifyTaxLines]
        tags                    <- map[kShopifyTags]
        contactEmail            <- map[kShopifyContactEmail]
        orderStatusUrl          <- map[kShopifyOrderStatusUrl]
        lineItems               <- map[kShopifyLineItems]
        shippingLines           <- map[kShopifyShippingLines]
        billingAddress          <- map[kShopifyBillingAddress]
        shippingAddress         <- map[kShopifyShippingAddress]
        fulfillments            <- map[kShopifyFulfillments]
        clientDetails           <- map[kShopifyClientDetails]
        refunds                 <- map[kShopifyRefunds]
        paymentDetails          <- map[kShopifyPaymentDetails]
        customer                <- map[kShopifyCustomer]        
    }
}
