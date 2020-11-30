//
//  Validator.swift
//  Pingo
//
//  Created by Matthew James on 11/10/14.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import Foundation
import UIKit

public protocol ValidationDelegate {
    func validationSuccessful()
    func validationFailed(_ errors: [UITextField:ValidationError])
}

open class Validator {
    // dictionary to handle complex view hierarchies like dynamic tableview cells
    open var errors:[UITextField:ValidationError] = [:]
    open var validations:[UITextField:ValidationRule] = [:]
    
    public init(){}
    
    // MARK: Using Keys
    
    open func registerField(_ textField:UITextField, rules:[Rule]) {
        validations[textField] = ValidationRule(textField: textField, rules: rules, errorLabel: nil)
    }
    
    open func registerField(_ textField:UITextField, errorLabel:UILabel, rules:[Rule]) {
        validations[textField] = ValidationRule(textField: textField, rules:rules, errorLabel:errorLabel)
    }
    
    open func unregisterField(_ textField:UITextField) {
        validations.removeValue(forKey: textField)
    }
    
    open func validate(_ delegate:ValidationDelegate) {
        
        for field in validations.keys {
            if let currentRule: ValidationRule = validations[field] {
                if let error: ValidationError = currentRule.validateField() {
                    if currentRule.errorLabel != nil {
                        error.errorLabel = currentRule.errorLabel
                    }
                    errors[field] = error
                } else {
                    errors.removeValue(forKey: field)
                }
            }
        }
        
        if errors.isEmpty {
            delegate.validationSuccessful()
        } else {
            delegate.validationFailed(errors)
        }
    }
    
    func clearErrors() {
        self.errors = [:]
    }
}
