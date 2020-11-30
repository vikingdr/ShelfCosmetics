//
//  ShopifyAPI+OrderHistory.swift
//  Shelf
//
//  Created by Matthew James on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

extension ShopifyAPI {
    func getOrderWithOrderId(_ orderId: NSNumber, completion: @escaping (_ responseObject: AnyObject?) -> Void) {
        get("orders/\(orderId).json", parameters: nil) { (responseObject: AnyObject?) in
            completion(responseObject)
        }
    }
}
