//
//  ShopifyClientDetail.swift
//  Shelf
//
//  Created by Matthew James on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyBrowserIp = "browser_ip"
let kShopifyAcceptLanguage = "accept_language"
let kShopifyUserAgent = "user_agent"
let kShopifySessionHash = "session_hash"
let kShopifyBrowserWidth = "browser_width"
let kShopifyBrowserHeight = "browser_height"

class ShopifyClientDetail: Mappable {
    var browserIp: String?
    var acceptLanguage: String?
    var userAgent: String?
    var sessionHash: String?
    var browserWidth: String?
    var browserHeight: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        browserIp               <- map[kShopifyBrowserIp]
        acceptLanguage          <- map[kShopifyAcceptLanguage]
        userAgent               <- map[kShopifyUserAgent]
        sessionHash             <- map[kShopifySessionHash]
        browserWidth            <- map[kShopifyBrowserWidth]
        browserHeight           <- map[kShopifyBrowserHeight]
    }
}
