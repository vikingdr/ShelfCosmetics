//
//  ZipCodeRule.swift
//  Validator
//
//  Created by Jeff Potter on 3/6/15.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

open class ZipCodeRule: RegexRule {
    
    public init(){
        super.init(regex: "\\d{5}")
    }
    
    override public init(regex: String) {
        super.init(regex: regex)
    }
    
    open override func errorMessage() -> String {
        return "Enter a valid 5 digit zipcode"
    }
    
}
