//
//  ShoppingCart.swift
//  Shelf
//
//  Created by Nathan Konrad on 10/27/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy
class ShoppingCart : NSObject {
    static let sharedInstance = ShoppingCart()
    fileprivate var products = [ShoppingCartItem]()
    fileprivate var itemCount = 0
    func addProducts(_ product : BUYProduct, amount : Int = 1){
        var exists = false
        for p in products{
            if p.product.identifier == product.identifier { //same product
                p.count = amount
                exists = true
            }
        }
        if exists == false {
            let newItem = ShoppingCartItem()
            newItem.product = product
            newItem.count = amount
            products.append(newItem)
            itemCount = itemCount + 1
        }
        
    }
    
    func getNumberOfItemsInCart() -> Int{
        return itemCount
    }
    
    func getNumberOfProductsWithId(_ id : NSNumber) -> Int?{
        for p in products {
            if p.product.identifier == id{
                return p.count
            }
        }
        return nil
    }
    
    func doesItemExistInCart(_ id : NSNumber) -> Bool{
        for p in products {
            if p.product.identifier == id{
                return true
            }
        }
        return false
    }
    
    func getProducts() -> [ShoppingCartItem]{
        return products
    }
    
    func removeProductWithId(_ id : NSNumber){
        for p in products {
            if p.product.identifier == id{
                products.removeObject(p)
            }
        }
        itemCount = itemCount - 1
    }
    
    func getSumOfItemsInCart() -> Double {
        var sum : Double = 0
        for p in products {
            if let variant = p.product.variants.firstObject as? BUYProductVariant{
                sum = sum + (Double(variant.price) * Double(p.count))
            }
        }
        return sum
    }

}

class ShoppingCartItem : NSObject {
    var product : BUYProduct!
    var count = 0
}
