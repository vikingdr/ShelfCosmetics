//
//  ShippingInfoModel.swift
//  Shelf
//
//  Created by Matthew James on 10/31/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

class AddressInfoModel : NSObject{
    var name = ""
    var address = ""
    var aptSte : String?
    var co : String?
    var city = ""
    var state = ""
    var zip = ""
    var phone = ""
    
    var kNameKey = "sName"
    var kAddressKey = "saddress"
    var kAptSteKey = "saptSte"
    var kCOKey = "sCO"
    var kCityKey = "sCity"
    var kStateKey = "sState"
    var kZipKey = "sZip"
    var kPhoneKey = "sPhone"
    
    override init(){
        super.init()
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(name,forKey: kNameKey)
        aCoder.encode(address,forKey: kAddressKey)
        if let aptSte = aptSte {
            aCoder.encode(aptSte,forKey: kAptSteKey)
        }
        if let co = co {
            aCoder.encode(co,forKey: kCOKey)
        }
        aCoder.encode(city,forKey: kCityKey)
        aCoder.encode(state,forKey: kStateKey)
        aCoder.encode(zip,forKey: kZipKey)
        aCoder.encode(phone,forKey: kPhoneKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        name = aDecoder.decodeObject(forKey: kNameKey) as! String
        address = aDecoder.decodeObject(forKey: kAddressKey) as! String
        
        if let aptDecode = aDecoder.decodeObject(forKey: kAptSteKey) as? String{
            aptSte = aptDecode
        }
        
        if let coDecode = aDecoder.decodeObject(forKey: kCOKey) as? String {
            co = coDecode
        }
        city = aDecoder.decodeObject(forKey: kCityKey) as! String
        state = aDecoder.decodeObject(forKey: kStateKey) as! String
        zip = aDecoder.decodeObject(forKey: kZipKey) as! String
        phone = aDecoder.decodeObject(forKey: kPhoneKey) as! String
    }
    
}

