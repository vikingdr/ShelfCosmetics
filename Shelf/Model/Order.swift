//
//  Order.swift
//  Shelf
//
//  Created by Matthew James on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

class Order: NSObject {
    var image: UIImage!
    var date: String!
    var title: String!
    var orderNumber: String!
    var orderTotal: CGFloat!
    var subtotal: CGFloat!
    var shippingHandling: CGFloat!
    var tax: CGFloat!
    var shippingAddress: String!
    var shippingMethod: String!
    var payment: String!
    var promo: String!
    var distributor: String!
}
