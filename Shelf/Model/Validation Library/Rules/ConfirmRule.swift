//
//  ConfirmRule.swift
//  Validator
//
//  Created by Jeff Potter on 3/6/15.
//  Copyright (c) 2015 jpotts18. All rights reserved.
//

import Foundation
import UIKit

open class ConfirmationRule: Rule {
    
    fileprivate let confirmField: UITextField
    
    public init(confirmField: UITextField) {
        self.confirmField = confirmField
    }
    
    open func validate(_ value: String) -> Bool {
        return confirmField.text == value
    }
    
    open func errorMessage() -> String {
        return "This field does not match"
    }
}
