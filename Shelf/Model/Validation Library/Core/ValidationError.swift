//
//  File.swift
//  Pingo
//
//  Created by Matthew James on 11/11/14.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import Foundation
import UIKit

open class ValidationError {
    open let textField:UITextField
    open var errorLabel:UILabel?
    open let errorMessage:String
    
    public init(textField:UITextField, error:String){
        self.textField = textField
        self.errorMessage = error
    }
}
