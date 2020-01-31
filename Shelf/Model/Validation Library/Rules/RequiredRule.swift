//
//  Required.swift
//  pyur-ios
//
//  Created by Jeff Potter on 12/22/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

open class RequiredRule: Rule {
    
    public init(){}
    
    var message: String {
        return "This field is required"
    }
    
    open func validate(_ value: String) -> Bool {
        return !value.isEmpty
    }
    
    open func errorMessage() -> String {
        return message
    }
}
