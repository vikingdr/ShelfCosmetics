//
//  MaxLengthRule.swift
//  Validator
//
//  Created by Guilherme Berger on 4/6/15.
//

import Foundation

open class MaxLengthRule: Rule {
    
    fileprivate var DEFAULT_LENGTH: Int = 16
    
    public init(){}
    
    public init(length: Int){
        self.DEFAULT_LENGTH = length
    }
    
    open func validate(_ value: String) -> Bool {
        return value.characters.count <= DEFAULT_LENGTH
    }
    
    open func errorMessage() -> String {
        return "Must be at most \(DEFAULT_LENGTH) characters long"
    }
}
