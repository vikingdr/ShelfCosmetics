//
//  ShippingMethodModel.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/2/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

class ShippingMethodModel : NSObject , NSCoding{
    let kOption = "shippingSelected"
    var selectedOption : ShippingOption?
    
    
    override init(){
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(selectedOption,forKey: kOption)
    }
    
    required init?(coder aDecoder: NSCoder) {
        selectedOption = aDecoder.decodeObject(forKey: kOption) as? ShippingOption
    }
}
