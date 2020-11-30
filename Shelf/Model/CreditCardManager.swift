//
//  AddEditPaymentModel.swift
//  Shelf
//
//  Created by Matthew James on 11/7/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class CreditCardManager : NSObject {
    let kCards = "paymentInfoCards"
    var cards : [CreditCard]!
    var defaultCard : CreditCard?
    
    static let sharedInstance = CreditCardManager()
    
    override init() {
        super.init()
        cards = [CreditCard]()
        secureRetrieve()
    }
    
    func secureSave() {
        let data = NSKeyedArchiver.archivedData(withRootObject: cards)
		KeychainWrapper.standard.set(data, forKey: kCards)
    }

    func updateAddPayment(_ creditCard : CreditCard) -> Int {
        if creditCard.isDefaultCreditCard == true {
            print("updating \(creditCard.creditCardNumber)")
            defaultCard = creditCard
            removeDefaults()
            creditCard.isDefaultCreditCard = true
        }
        
        var didUpdate = false
        var index = 0
        for card in cards {
            if card.creditCardNumber == creditCard.creditCardNumber{
                cards[index] = creditCard
                didUpdate = true
                break
            }
            index = index + 1
        }
        
        if didUpdate == false { //No update just append to list
            cards.append(creditCard)
        }
    
        secureSave()
        return index
    }
    
    fileprivate func removeDefaults(){
            for card in cards {
                card.isDefaultCreditCard = false
            }
    }
    
    fileprivate func secureRetrieve() {
        if let savedData = KeychainWrapper.standard.data(forKey: kCards){
            cards = NSKeyedUnarchiver.unarchiveObject(with: savedData) as! [CreditCard]
            for card in cards {
                if card.isDefaultCreditCard == true {
                    defaultCard = card
                }
            }
        }
    }
}
