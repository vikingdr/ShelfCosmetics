//
//  BUYCheckoutManager.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy

class BUYCheckoutManager {
    var checkout: BUYCheckout?
    var paymentToken: BUYPaymentToken?
    var shippingRates: [BUYShippingRate]?
    static let sharedInstance = BUYCheckoutManager()
    
    func createCheckout(_ completion: @escaping ((BUYCheckout?, NSError?) -> ())) {
        checkout = BUYCheckout(modelManager: BUYClient.sharedClient.modelManager, cart: BUYCart.sharedCart)
        if let email = PFUser.current()?.email {
            checkout?.email = email
        }
		
		BUYClient.sharedClient.createCheckout(checkout!) { (checkout, error) in
            guard error == nil, let checkout = checkout else {
                print("error: \(error)")
                completion(nil, error as NSError?)
                return
            }
            self.checkout = checkout
            completion(checkout, error as NSError?)
        }
    }
    
    func getShippingRatesForCheckoutWithToken(_ completion: @escaping ((NSError?) -> ())) {
        guard let checkout = checkout else {
            return
        }
		
		BUYClient.sharedClient.getShippingRatesForCheckout(withToken: checkout.token) { (shippingRates, status, error) in
            completion(error as NSError?)
        }
    }
    
    func clearCheckout() {
        checkout = nil
        paymentToken = nil
    }
    
    func updateCheckout(_ checkout: BUYCheckout) {
        self.checkout = checkout
    }
    
    func updateCheckoutWithCart(_ completion: @escaping ((BUYCheckout?, NSError?) -> ())) {
        guard let checkout = checkout else {
            createCheckout(completion)
            return
        }
        
        BUYCart.sharedCart.setLineItems()
        checkout.update(with: BUYCart.sharedCart)
        updateCheckoutToShopify(completion)
    }
    
    func updateCheckoutToShopify(_ completion: @escaping ((BUYCheckout?, NSError?) -> ())) {
        guard let checkout = checkout else {
            completion(nil, nil)
            return
        }
		
		BUYClient.sharedClient.update(checkout) { (checkout, error) in
            guard error == nil, let checkout = checkout else {
                completion(nil, error as NSError?)
                return
            }
            
            self.checkout = checkout
            completion(checkout, error as NSError?)
        }
    }
    
    func updateCheckoutWithBillingAddress(_ address: AddressInfoModel) {
        guard let checkout = checkout else {
            return
        }
        let billingAddress = getBUYAddress(address)
        checkout.billingAddress = billingAddress
    }
    
    func updateCheckoutWithShippingAddress(_ address: AddressInfoModel) {
        guard let checkout = checkout else {
            return
        }
        
        let shippingAddress = getBUYAddress(address)
        checkout.shippingAddress = shippingAddress
        
        // If completion, fetch data
    }
    
    fileprivate func getBUYAddress(_ address: AddressInfoModel) -> BUYAddress {
        let buyAddress = BUYAddress(modelManager: BUYClient.sharedClient.modelManager, jsonDictionary: nil)
        
        let nameComponents = address.name.components(separatedBy: " ")
        if nameComponents.count > 1 {
            buyAddress.firstName = nameComponents[0]
            buyAddress.lastName = nameComponents[1]
        }
        else {
            buyAddress.firstName = address.name
        }
        
        buyAddress.address1 = address.address
        if let aptSte = address.aptSte {
            buyAddress.address2 = aptSte
        }
        if let co = address.co {
            buyAddress.company = co
        }
        buyAddress.city = address.city
        buyAddress.province = address.state
        buyAddress.zip = address.zip
        buyAddress.country = "US"
        
        return buyAddress
    }
    
    func updateCheckoutWithCreditCard(_ creditCard: CreditCard, completion: @escaping ((NSError?, Bool) -> ())) {
        guard let checkout = checkout else {
            completion(nil, false)
            return
        }
        
        let buyCreditCard = BUYCreditCard()
        let creditCardComponents = creditCard.expires.components(separatedBy: "/")
        if creditCardComponents.count > 1 {
            buyCreditCard.expiryMonth = creditCardComponents[0]
            buyCreditCard.expiryYear = creditCardComponents[1]
        }
        buyCreditCard.number = creditCard.creditCardNumber
        buyCreditCard.cvv = creditCard.cvc
        buyCreditCard.nameOnCard = creditCard.billingAddress.name
		
		BUYClient.sharedClient.store(buyCreditCard, checkout: checkout) { (token, error) in
            guard error == nil, let token = token else {
                completion(error as NSError?, false)
                return
            }
            
            self.paymentToken = token
            completion(error as NSError?, true)
        }
    }
    
    func updateCheckoutWithDiscount(_ discountCode: String, completion: @escaping ((BUYCheckout?, NSError?) -> ())) {
        guard let checkout = checkout else {
            return
        }
        
        let buyDiscount = BUYDiscount(modelManager: BUYClient.sharedClient.modelManager, jsonDictionary: nil)
        buyDiscount.code = discountCode
        
        checkout.discount = buyDiscount
        updateCheckoutToShopify(completion)
    }
    
    func updateCheckoutWithShippingRate(_ shippingRate: BUYShippingRate, completion: @escaping ((BUYCheckout?, NSError?) -> ())) {
        guard let checkout = checkout else {
            return
        }
        
        checkout.shippingRate = shippingRate
        updateCheckoutToShopify(completion)
    }

    func getShippingRates(_ completion : @escaping ((NSError?, [BUYShippingRate]?) -> ())) {
        guard let checkout = checkout else {
            completion(nil, nil)
            return
        }
		
		BUYClient.sharedClient.getShippingRatesForCheckout(withToken: checkout.token) { (rates, status, error) in
            guard error == nil, let rates = rates else {
                completion(error as NSError?, nil)
                return
            }
            
            self.shippingRates = rates
            completion(error as NSError?, rates)
        }
    }
    
    func getCompletedCheckout(_ completion : @escaping ((NSError?, Bool) -> ())) {
        guard let checkout = checkout else {
            completion(nil, false)
            return
        }
		
		BUYClient.sharedClient.getCheckoutWithToken(checkout.token) { (checkout, error) in
            guard error == nil, let checkout = checkout else {
                completion(error as NSError?, false)
                return
            }
            
            self.checkout = checkout
            completion(error as NSError?, true)
        }
    }
    
    func completeCheckoutToShopifyWithToken(_ completion: @escaping ((BUYCheckout?, NSError?) -> ())) {
        guard let checkout = checkout, let paymentToken = paymentToken else {
            completion(nil, nil)
            return
        }
		
		BUYClient.sharedClient.completeCheckout(withToken: checkout.token, paymentToken: paymentToken) { (checkout, error) in
            completion(checkout, error as NSError?)
            guard error == nil, let checkout = checkout else {
                return
            }
            
            self.checkout = checkout
        }
    }
}
