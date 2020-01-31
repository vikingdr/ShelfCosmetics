//
//  EntitiesService.swift
//  Shelf
//
//  Created by Nathan Konrad on 03.07.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit

private var service = EntitiesService()

class EntitiesService: NSObject {
    
    class var shared: EntitiesService {
        return service
    }
    
}
