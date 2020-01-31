//
//  ShopifyAPI.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy
class ShopifySDKAPI : NSObject {
    
    static func createCheckout(_ completion : ((BUYCheckout?, NSError?) -> ())!){
        // Create checkout
        let checkout = BUYCheckout(modelManager: BUYClient.sharedClient.modelManager, cart: BUYCart.sharedCart)
        checkout.includesTaxes = true
        if let email = PFUser.current()?.email {
            checkout.email = email
        }
		
		BUYClient.sharedClient.createCheckout(checkout) { (checkout: BUYCheckout?, error: Error?) in
            guard error == nil, let checkout = checkout else {
                print("error: \(error?.localizedDescription)")
                completion!(nil , error as NSError?)
                return
            }
            completion!(checkout, nil)
        }
    }
    
    static func updateShippingAndBillingAddress( _ cc : CreditCard, shipping : AddressInfoModel, checkout : BUYCheckout, completion : @escaping ((NSError?, BUYCheckout?) -> ())){
        
        let shippingAddr = BUYAddress(modelManager: BUYClient.sharedClient.modelManager, jsonDictionary: nil)
        //Separate first and last name
        let nameShipping = shipping.name.components(separatedBy: " ")
        if nameShipping.count > 1 {
            shippingAddr.firstName = nameShipping[0]
            shippingAddr.lastName = nameShipping[1]
        }else{
            shippingAddr.firstName = shipping.name
        }
        
        shippingAddr.address1 = shipping.address
        shippingAddr.address2 = shipping.aptSte
        shippingAddr.company = shipping.co
        shippingAddr.city = shipping.city
        shippingAddr.province = shipping.state
        shippingAddr.zip = shipping.zip
        shippingAddr.countryCode = "US"
        
        let billingAddr = BUYAddress(modelManager: BUYClient.sharedClient.modelManager, jsonDictionary: nil)
        //Separate first and last name
        let nameBilling = cc.billingAddress.name.components(separatedBy: " ")
        if nameBilling.count > 1 {
            billingAddr.firstName = nameBilling[0]
            billingAddr.lastName = nameBilling[1]
        }else{
            billingAddr.firstName = cc.billingAddress.name
        }

        billingAddr.address1 = cc.billingAddress.address
        billingAddr.address2 = cc.billingAddress.aptSte
        billingAddr.company = shipping.co
        billingAddr.city = cc.billingAddress.city
        billingAddr.province = cc.billingAddress.state
        billingAddr.zip = cc.billingAddress.zip
        billingAddr.countryCode = "US"

        checkout.shippingAddress = shippingAddr
        checkout.billingAddress = billingAddr

		BUYClient.sharedClient.update(checkout) { (checkout: BUYCheckout?, error: Error?) in
            completion(error as NSError?, checkout)
        }
    }
    
    static func getShippingRatesForCheckout(_ checkout : BUYCheckout, completion : @escaping ((NSError?, [BUYShippingRate]?, BUYStatus?) -> ())){
        BUYClient.sharedClient.getShippingRatesForCheckout(withToken: checkout.token, completion: { (shippingRates, status, error) in
            if error == nil {
                completion(nil, shippingRates, status )
            }else {
                completion(error as NSError?,nil,nil)
            }
            
        })
    }
    
    static func updateCreditCard(_ creditCard : CreditCard, checkout : BUYCheckout,  completion : @escaping ((NSError?, BUYCheckout?, BUYPaymentToken?) -> ())){
        let cc = BUYCreditCard()
        cc.number = creditCard.creditCardNumber
        let ccExpire = creditCard.expires.components(separatedBy: "/")
        cc.expiryMonth = ccExpire[0]
        cc.expiryYear = ccExpire[1]
        cc.cvv = creditCard.cvc
        cc.nameOnCard = creditCard.billingAddress.name
        
        BUYClient.sharedClient.store(cc, checkout: checkout) { (token, error) in
            if error == nil {
                completion(nil, checkout, token)
            }else{
                completion(error as NSError?,checkout, nil)
            }
        }
    }
    
    static func updateShippingRate(_ rate : BUYShippingRate, checkout : BUYCheckout?, completion : @escaping ((NSError?, BUYCheckout?) -> ())){
        if checkout != nil {
            checkout?.shippingRate = rate
            BUYClient.sharedClient.update(checkout!) { (checkout: BUYCheckout?, error: Error?) in
                completion(error as NSError?,checkout)
            }
        }
    }
    
    static func completeCheckout(_ checkout : BUYCheckout, token : BUYPaymentToken , completion : @escaping ((NSError?, BUYCheckout?) -> ())){
        BUYClient.sharedClient.completeCheckout(withToken: checkout.token, paymentToken: token, completion: { (checkout, error
            ) in
            completion(error as NSError?, checkout)
        })
    }
}
