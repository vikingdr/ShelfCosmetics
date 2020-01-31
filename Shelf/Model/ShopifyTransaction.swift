//
//  ShopifyTransaction.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyOrderId = "order_id"
let kShopifyKind = "kind"
let kShopifyStatus = "status"
let kShopifyMessage = "message"
let kShopifyAuthorization = "authorization"
let kShopifyParentId = "parent_id"
let kShopifyReceipt = "receipt"
let kShopifyErrorCode = "error_code"

class ShopifyTransaction: Mappable {
    var id: Int?
    var order_id: Int?
    var amount: String?
    var kind: String? // "capture", "sale",
    var gateway: String?
    var status: String?
    var message: String?
    var createAt: String?
    var test: Bool?
    var authorization: String?
    var currency: String?
    var locationId: AnyObject?
    var userId: AnyObject?
    var parentId: AnyObject?
    var deviceId: AnyObject?
    var receipt: ShopifyReceipt?
    var errorCode: AnyObject?
    var sourceName: String? // mobile_app
    var paymentDetails: ShopifyPaymentDetail?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kShopifyId]
        order_id                <- map[kShopifyOrderId]
        amount                  <- map[kShopifyAmount]
        kind                    <- map[kShopifyKind]
        gateway                 <- map[kShopifyGateway]
        status                  <- map[kShopifyStatus]
        message                 <- map[kShopifyMessage]
        createAt                <- map[kShopifyCreatedAt]
        test                    <- map[kShopifyTest]
        authorization           <- map[kShopifyAuthorization]
        currency                <- map[kShopifyCurrency]
        locationId              <- map[kShopifyLocationId]
        userId                  <- map[kShopifyUserId]
        parentId                <- map[kShopifyParentId]
        deviceId                <- map[kShopifyDeviceId]
        receipt                 <- map[kShopifyReceipt]
        errorCode               <- map[kShopifyErrorCode]
        sourceName              <- map[kShopifySourceName]
        paymentDetails          <- map[kShopifyPaymentDetails]
    }
}
