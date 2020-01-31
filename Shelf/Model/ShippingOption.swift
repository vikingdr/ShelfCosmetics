//
//  ShippingOption.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/27/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

class ShippingOption: NSObject , NSCoding{
    var name: String!
    var price: CGFloat!
    var timeDetail: String!
    var deliveryTime: String!
    var id : Int!
    
    let kName = "shippingOptName"
    let kPrice = "shippingOptPrice"
    let kTimeDetail = "shippingOptTimeDetails"
    let kDeliveryTime = "shippingDeliveryTime"
    let kID = "shippingOptionID"
    
    override init(){
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name,forKey: kName)
        aCoder.encode(price,forKey: kPrice)
        aCoder.encode(timeDetail,forKey: kTimeDetail)
        aCoder.encode(deliveryTime,forKey: kDeliveryTime)
        aCoder.encode(id, forKey: kID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: kName) as! String
        price = aDecoder.decodeObject(forKey: kPrice) as! CGFloat
        timeDetail = aDecoder.decodeObject(forKey: kTimeDetail) as! String
        deliveryTime = aDecoder.decodeObject(forKey: kDeliveryTime) as! String
        id = aDecoder.decodeObject(forKey: kID) as! Int
    }
}
