//
//  ValidationRule.swift
//  Pingo
//
//  Created by Matthew James on 11/11/14.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import Foundation
import UIKit

open class ValidationRule {
    open var textField:UITextField
    open var errorLabel:UILabel?
    open var rules:[Rule] = []
    
    public init(textField: UITextField, rules:[Rule], errorLabel:UILabel?){
        self.textField = textField
        self.errorLabel = errorLabel
        self.rules = rules
    }
    
    open func validateField() -> ValidationError? {
        for rule in rules {
            if !rule.validate(textField.text!) {
                return ValidationError(textField: self.textField, error: rule.errorMessage())
            }
        }
        return nil
    }
}
