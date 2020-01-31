//
//  LengthRule.swift
//  Validator
//
//  Created by Jeff Potter on 3/6/15.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

open class MinLengthRule: Rule {
    
    fileprivate var DEFAULT_LENGTH: Int = 3
    
    public init(){}
    
    public init(length: Int){
        self.DEFAULT_LENGTH = length
    }
    
    open func validate(_ value: String) -> Bool {
        return value.characters.count >= DEFAULT_LENGTH
    }
    
    open func errorMessage() -> String {
        return "Must be at least \(DEFAULT_LENGTH) characters long"
    }
}
