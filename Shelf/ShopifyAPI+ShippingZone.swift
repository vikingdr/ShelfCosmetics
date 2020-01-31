//
//  ShopifyAPI+ShippingZone.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/6/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

extension ShopifyAPI {
    func getShippingZones(_ completion: @escaping (_ responseObject: AnyObject?) -> Void) {
        get("shipping_zones.json", parameters: nil) { (responseObject: AnyObject?) in
            completion(responseObject)
        }
    }
}
