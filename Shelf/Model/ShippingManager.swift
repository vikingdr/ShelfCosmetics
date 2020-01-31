//
//  ShippingManager.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/9/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class ShippingManager : NSObject {
    let kShipping = "shippingInfo"
    var shipping : AddressInfoModel?
    
    static let sharedInstance = ShippingManager()
    
    override init() {
        super.init()
        shipping = AddressInfoModel()
        secureRetrieve()
    }
    
    func secureSave() {
        let data = NSKeyedArchiver.archivedData(withRootObject: shipping!)
		KeychainWrapper.standard.set(data, forKey: kShipping, withAccessibility: nil)
    }
    
    fileprivate func secureRetrieve() {
        if let savedData = KeychainWrapper.standard.data(forKey: kShipping){
            shipping = NSKeyedUnarchiver.unarchiveObject(with: savedData) as? AddressInfoModel
        }
    }
    
}
