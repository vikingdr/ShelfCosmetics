//
//  ShopifyAPI.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import AFNetworking

private let kShelfUsername = "9e0af7dc9a84ba1ab05affe5a117cf13"
private let kShelfPassword = "c4897558d09af4512e4337cd9fb7613c"
private let kShopifyAPIUrl = "https://shelf-cosmetics.myshopify.com/admin/"

class ShopifyAPI {
    var params = [String: AnyObject]()
    
    init() {
        
    }
    
    func get(_ urlSegment: String!, parameters: [String: AnyObject]?, serializer: AFHTTPRequestSerializer = AFHTTPRequestSerializer(), completion: @escaping (_ responseObject: AnyObject?) -> Void) {
        let manager = AFHTTPSessionManager()
        let url = kShopifyAPIUrl + urlSegment
        manager.requestSerializer = serializer
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(kShelfUsername, password: kShelfPassword)
		
		manager.get(url, parameters: parameters, progress: { (progress) in
			
		}, success: { (operation: URLSessionDataTask, responseObject: Any?) in
			completion(responseObject as AnyObject?)
		}) { (operation: URLSessionDataTask?, error: Error) in
			completion(nil)
		}
    }
}
