//
//  SOrder.swift
//  Shelf
//
//  Created by Matthew James on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

let kParseClassNameOrder = "Order"

let kParseOrderId = "orderId"
let kParseUser = "user"
let kParseProducts = "products"

class SOrder: SObject {
    var orderId: NSNumber?
    
    var products: [ParseShopifyProduct]?
    
    override init() {
        super.init()
    }
    
    override init(data: PFObject) {
        super.init(data: data)
        
        if let orderId = data[kParseOrderId] as? NSNumber {
            self.orderId = orderId
        }
        
        if let products = data[kParseProducts] as? [[String: String]] {
            self.products = []
            for product in products {
                if let parseShopifyProduct = ParseShopifyProduct(JSON: product) {
                    self.products!.append(parseShopifyProduct)
                }
            }
        }
    }
}
