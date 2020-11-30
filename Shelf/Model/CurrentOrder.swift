//
//  CurrentOrder.swift
//  Shelf
//
//  Created by Matthew James on 11/2/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

class CurrentOrder : NSObject {
    var shippingInfo : AddressInfoModel?
    var creditCard : CreditCard?
    var shippingMethodInfo : ShippingMethodModel?
}
