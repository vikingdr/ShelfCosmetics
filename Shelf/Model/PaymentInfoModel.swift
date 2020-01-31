//
//  PaymentInfoModel.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/1/16.
//  Copyright © 2016 Shelf. All rights reserved.
//
// This class stores credit card information in keychain as a password
// All data in keychain
import Foundation
import SwiftKeychainWrapper
class PaymentInfoModel : NSObject , NSCoding{
    var creditCardNumber = ""
    var expires = ""
    var cvc = ""
    var promoCode = ""
    
    let kCreditCardKey = "paymentCC"
    let kExpiresKey = "paymentExpires"
    let cvcKey = "paymentCVC"
    let promoKey = "paymentPromo"
    
    override init() {
        super.init()
        secureRetrieve()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        creditCardNumber = aDecoder.decodeObject(forKey: kCreditCardKey) as! String
        expires = aDecoder.decodeObject(forKey: kExpiresKey) as! String
        cvc = aDecoder.decodeObject(forKey: cvcKey) as! String
        promoCode = aDecoder.decodeObject(forKey: promoKey) as! String
    }
    
    func encode(with aCoder: NSCoder) {
        creditCardNumber = aCoder.decodeObject(forKey: kCreditCardKey) as! String
        expires = aCoder.decodeObject(forKey: kExpiresKey) as! String
        cvc = aCoder.decodeObject(forKey: cvcKey) as! String
        promoCode = aCoder.decodeObject(forKey: promoKey) as! String
    }
    
    func secureSave() {
		KeychainWrapper.standard.set(creditCardNumber, forKey: kCreditCardKey, withAccessibility: nil)
        KeychainWrapper.standard.set(expires,forKey: kExpiresKey, withAccessibility: nil)
        KeychainWrapper.standard.set(cvc, forKey: cvcKey, withAccessibility: nil)
        KeychainWrapper.standard.set(promoCode, forKey: promoKey, withAccessibility: nil)
    }
    
    fileprivate func secureRetrieve() {
        if let storedCC = KeychainWrapper.standard.string(forKey: kCreditCardKey) {
            creditCardNumber = storedCC
        }
        
		if let storedExpires = KeychainWrapper.standard.string(forKey: kExpiresKey) {
            expires = storedExpires
        }
        
		if let storedCVC = KeychainWrapper.standard.string(forKey: cvcKey){
            cvc = storedCVC
        }
    
		if let storedPromo = KeychainWrapper.standard.string(forKey: promoKey) {
            promoCode = storedPromo
        }
    }
}
