//
//  AnalyticsHelper.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/19/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Predefined
// Add To Cart - Use predefined kFIREventAddToCart
// Added Payment Info - Use predefined kFIREventAddPaymentInfo
// Registration - Use predefined kFIREventSignUp
// Login - Use predefined kFIREventLogin
// Checkout Initiated - Use predefined kFIREventBeginCheckout
// Purchase - Use predefined kFIREventEcommercePurchase
// Search - Use predefined kFIREventSearch
// Search View Results (Optional) - Use predefined kFIREventViewSearchResults
// MARK: - Custom Events
// Invite
let kFIREventInvite = "invite"
// Create A Shelfie Completion
let kFIREventCreateAShelfieCompletion = "create_a_shelfie_completion"
// Initiate Purchase
let kFIREventInitiatePurchase = "initiate_purchase"
// Cart Abandonment
let kFIREventCartAbandonment = "cart_abandonment"

class AnalyticsHelper {
    class func sendCustomEvent(_ eventName: String, parameters: [String: String]?=nil) {
        FIRAnalytics.logEvent(withName: eventName, parameters: parameters as [String : NSObject]?)
    }
}
