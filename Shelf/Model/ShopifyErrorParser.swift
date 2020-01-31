//
//  ShopifyErrorParser.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/16/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation

let kShopifyErrors = "errors"
let kShopifyErrorCodeNotEnoughInStock = "not_enough_in_stock"

class ShopifyErrorParser {
    
    static let sharedInstance = ShopifyErrorParser()
    
    func getCheckoutErrorMessage(_ error: NSError) -> String {
        var errorMessage = ""
        
        let userInfo = error.userInfo
        print("error userInfo: \(userInfo)")
        
        if let errors = userInfo[kShopifyErrors] as? [String: AnyObject] {
            let shopifyErrors = ShopifyErrors(JSON: errors)
            
            
            if let checkout = shopifyErrors?.checkout {
                /**
                 * Credit Card
                 */
                if let creditCard = checkout.creditCard {
                    errorMessage = "Credit card"
                    /**
                     * incorrect number message
                     */
                    if let number = creditCard.number, number.count > 0 {
                        errorMessage += " number"
                        let numberError = number[0]
                        if let message = numberError.message {
                            errorMessage += " \(message)"
                        }
                    }
                    
                    /**
                     * invalid expiry month message
                     */
                    if let month = creditCard.month, month.count > 0 {
                        errorMessage += " month"
                        let monthError = month[0]
                        if let message = monthError.message {
                            errorMessage += " \(message)"
                        }
                    }
                    
                    /**
                     * invalid expiry year message
                     */
                    if let year = creditCard.year, year.count > 0 {
                        errorMessage += " year"
                        let yearError = year[0]
                        if let message = yearError.message {
                            errorMessage += " \(message)"
                        }
                    }
                    
                    /**
                     * invalid CVV message
                     */
                    if let cvv = creditCard.verifcationValue, cvv.count > 0 {
                        errorMessage += " verification value"
                        let cvvError = cvv[0]
                        if let message = cvvError.message {
                            errorMessage += " \(message)"
                        }
                    }
                }
                
                /**
                 * Payment Gateway
                 * card declined message
                 */
                if let paymentGateway = checkout.paymentGateway, paymentGateway.count > 0 {
                    let paymentGatewayError = paymentGateway[0]
                    if let message = paymentGatewayError.message {
                        errorMessage = message
                    }
                }
                
                /**
                 * Discount
                 */
                if let discount = checkout.discount {
                    if let code = discount.code, code.count > 0 {
                        let codeError = code[0]
                        if let message = codeError.message {
                            errorMessage = message
                        }
                    }
                }
                
                /**
                 * Shipping Rate
                 */
                if let shippingRate = checkout.shippingRate {
                    errorMessage = "Shipping rate"
                    if let id = shippingRate.id, id.count > 0 {
                        let idError = id[0]
                        if let message = idError.message {
                            errorMessage += " \(message)"
                        }
                    }
                }
                
                /**
                 * Line Items
                 */
                if let lineItems = checkout.lineItems, lineItems.count > 0 {
                    for index in 0..<lineItems.count {
                        if let lineItem = lineItems[index] {
                            if let quantity = lineItem.quantity, quantity.count > 0 {
                                let quantityError = quantity[0]
                                if let message = quantityError.message {
                                    errorMessage = message
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return errorMessage
    }
    
    func getCheckoutErrorCode(_ error: NSError) -> (Int, String) {        
        let userInfo = error.userInfo
        print("error userInfo: \(userInfo)")
        
        if let errors = userInfo[kShopifyErrors] as? [String: AnyObject] {
            let shopifyErrors = ShopifyErrors(JSON: errors)
            
            
            if let checkout = shopifyErrors?.checkout {
                /**
                 * Credit Card
                 */
                if let creditCard = checkout.creditCard {
                    /**
                     * incorrect number message
                     */
                    if let number = creditCard.number, number.count > 0 {
                        let numberError = number[0]
                        if let code = numberError.code {
                            return (0, code)
                        }
                    }
                    
                    /**
                     * invalid expiry month message
                     */
                    if let month = creditCard.month, month.count > 0 {
                        let monthError = month[0]
                        if let code = monthError.code {
                            return (0, code)
                        }
                    }
                    
                    /**
                     * invalid expiry year message
                     */
                    if let year = creditCard.year, year.count > 0 {
                        let yearError = year[0]
                        if let code = yearError.code {
                            return (0, code)
                        }
                    }
                    
                    /**
                     * invalid CVV message
                     */
                    if let cvv = creditCard.verifcationValue, cvv.count > 0 {
                        let cvvError = cvv[0]
                        if let code = cvvError.code {
                            return (0, code)
                        }
                    }
                }
                
                /**
                 * Payment Gateway
                 * card declined message
                 */
                if let paymentGateway = checkout.paymentGateway, paymentGateway.count > 0 {
                    let paymentGatewayError = paymentGateway[0]
                    if let code = paymentGatewayError.code {
                        return (0, code)
                    }
                }
                
                /**
                 * Discount
                 */
                if let discount = checkout.discount {
                    if let code = discount.code, code.count > 0 {
                        let codeError = code[0]
                        if let code = codeError.code {
                            return (0, code)
                        }
                    }
                }
                
                /**
                 * Shipping Rate
                 */
                if let shippingRate = checkout.shippingRate {
//                    errorMessage = "Shipping rate"
                    if let id = shippingRate.id, id.count > 0 {
                        let idError = id[0]
                        if let code = idError.code {
                            return (0, code)
                        }
                    }
                }
                
                /**
                 * Line Items
                 */
//                print("checkout: \(checkout.toJSONString())")
                if let lineItems = checkout.lineItems, lineItems.count > 0 {
                    for index in 0..<lineItems.count {
                        if let lineItem = lineItems[index] {
                            if let quantity = lineItem.quantity, quantity.count > 0 {
                                let quantityError = quantity[0]
                                if let code = quantityError.code {
                                    return (index, code)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return (0, "")
    }
}
