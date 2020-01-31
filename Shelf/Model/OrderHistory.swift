//
//  OrderHistory.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import Buy

private var orders: [SOrder] = []
private var ordersPages: [Int] = []
private var shouldLoadNextPage = false

let kOrdersPerPage = 10

let kParseCloudFunctionGetOrders = "getOrders"

class OrderHistory: NSObject {
    static let sharedHistory = OrderHistory()
    
    func reset() {
        orders = []
        ordersPages = []
        shouldLoadNextPage = false
    }
    
    func currentOrders() -> [SOrder] {
        return orders
    }
    
    func currentOrdersPages() -> [Int] {
        return ordersPages
    }
    
    func shouldLoadnextPage() -> Bool {
        return shouldLoadNextPage
    }
    
    func prependNewOrder(_ order: PFObject) {
        let sOrder = SOrder(data: order)
        
        orders.insert(sOrder, at: 0)
    }
    
    func updateOrders(_ page : Int = 0, itemPerPage : Int = kOrdersPerPage, completion : @escaping ((_ success: Bool, _ shouldLoadNextPage: Bool) -> ())) {
        guard !ordersPages.contains(page) else {
            return
        }
        
        if let _ = PFUser.current() {
            ordersPages.append(page)
			PFCloud.callFunction(inBackground: kParseCloudFunctionGetOrders, withParameters: [kKeyPage: page, kKeyLimit: itemPerPage], block: { (result: Any?, error: Error?) in
                guard error == nil, let objects = result as? [PFObject] else {
                    if let errorLocalized = error?.localizedDescription {
                        let errorData = errorLocalized.data(using: String.Encoding.utf8)
                        do {
                            let errorJson = try JSONSerialization.jsonObject(with: errorData!, options: JSONSerialization.ReadingOptions())
                            if let errorCode = (errorJson as AnyObject).object(forKey: "code") as? Int {
                                // INVALID_SESSION_TOKEN
                                if errorCode == kParseErrorCodeInvalidSessionToken {
                                    if let message = (errorJson as AnyObject).object(forKey: "message") as? String, message == "INVALID_SESSION_TOKEN" {
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: kInvalidSessionTokenNotification), object: nil)
                                    }
                                }
                            }
                        } catch {
                            
                        }
                    }
                    
                    // Call failed, remove next page from existing array and reset shouldLoadNextPage to true to refetch again later
                    ordersPages.removeObject(page)
                    shouldLoadNextPage = true
                    completion(false, false)
                    return
                }
                
                for object in objects {
                    let sOrder = SOrder(data: object)
                    let containOrder = orders.filter { $0.objectId == sOrder.objectId }
                    // Check if orders does not contain new item, append
                    if containOrder.count <= 0 {
                        orders.append(sOrder)
                    }
                }
                
                shouldLoadNextPage = objects.count == kItemsPerPage
                completion(true, shouldLoadNextPage)
            })
        }
    }
}
