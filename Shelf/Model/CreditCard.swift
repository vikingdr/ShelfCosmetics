//
//  CreditCard.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/7/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
class CreditCard : NSObject, NSCoding {
    var billingAddress = AddressInfoModel()
    var isDefaultCreditCard = false
    var creditCardNumber = ""
    var expires = ""
    var cvc = ""
    var promoCode = ""
    
    let kCreditCardKey = "ccpaymentCC"
    let kExpiresKey = "ccpaymentExpires"
    let kCvcKey = "ccpaymentCVC"
    let kPromoKey = "ccpaymentPromo"
    let kDefaultCreditCardKey = "ccdefaultCreditCard"
    let kBillingAddressKey = "ccBilling"
    
    override init(){
        super.init()

    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(isDefaultCreditCard, forKey: kDefaultCreditCardKey)

        aCoder.encode(creditCardNumber, forKey: kCreditCardKey)
        aCoder.encode(expires, forKey: kExpiresKey)
        //Legally we are not allowed to store CVC codes
        //aCoder.encodeObject(cvc, forKey: kCvcKey)
        aCoder.encode(promoCode, forKey: kPromoKey)
        aCoder.encode(billingAddress, forKey: kBillingAddressKey )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        if let defaultCard = aDecoder.decodeObject(forKey: kDefaultCreditCardKey) as? Bool {
            isDefaultCreditCard = defaultCard
        }

        creditCardNumber = aDecoder.decodeObject(forKey: kCreditCardKey) as! String
        expires = aDecoder.decodeObject(forKey: kExpiresKey) as! String
        //Legally we are not allowed to store CVC codes
        //cvc = aDecoder.decodeObjectForKey(kCvcKey) as! String
        promoCode = aDecoder.decodeObject(forKey: kPromoKey) as! String
        if let billing = aDecoder.decodeObject(forKey: kBillingAddressKey) as? AddressInfoModel {
            billingAddress = billing
        }
    }
    
}
