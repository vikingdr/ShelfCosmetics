//
//  ShopifyPaymentDetail.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyCreditCardBin = "credit_card_bin"
let kShopifyAvsResultCode = "avs_result_code"
let kShopifyCvvResultCode = "cvv_result_code"
let kShopifyCreditCardNumber = "credit_card_number"
let kShopifyCreditCardCompany = "credit_card_company"

class ShopifyPaymentDetail: Mappable {
    var creditCardBin: String?
    var avsResultCode: String?
    var cvvResultCode: String?
    var creditCardNumber: String?
    var creditCardCompany: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        creditCardBin           <- map[kShopifyCreditCardBin]
        avsResultCode           <- map[kShopifyAvsResultCode]
        cvvResultCode           <- map[kShopifyCvvResultCode]
        creditCardNumber        <- map[kShopifyCreditCardNumber]
        creditCardCompany       <- map[kShopifyCreditCardCompany]
    }
}
