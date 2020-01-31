//
//  EmailValidation.swift
//  Pingo
//
//  Created by Jeff Potter on 11/11/14.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation

open class EmailRule: RegexRule {
    
    public init(){
        super.init(regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
    }
    
    override public init(regex:String){
        super.init(regex: regex)
    }

    override open func errorMessage() -> String {
        return "Must be a valid email address"
    }
}
