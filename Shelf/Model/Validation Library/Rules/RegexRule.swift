//
//  RegexRule.swift
//  Validator
//
//  Created by Jeff Potter on 4/3/15.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

open class RegexRule : Rule {
    
    fileprivate var REGEX: String = "^(?=.*?[A-Z]).{8,}$"
    
    public init(regex: String){
        self.REGEX = regex
    }
    
    open func validate(_ value: String) -> Bool {
        if let test = NSPredicate(format: "SELF MATCHES %@", self.REGEX) as NSPredicate? {
            if test.evaluate(with: value) {
                return true
            }
        }
        return false
    }
    
    open func errorMessage() -> String {
        return "Invalid Regular Expression"
    }
}
