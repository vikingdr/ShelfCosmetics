//
//  Place.swift
//  Shelf
//
//  Created by Nathan Konrad on 9/20/16.
//  Copyright © 2016 Shelf. All rights reserved.
//


import UIKit
import MapKit

class Place: NSObject  {
    var place : MKMapItem!
    var distance : CLLocationDistance!
    
    init(place : MKMapItem, distance : CLLocationDistance) {
        self.place = place
        self.distance = distance
    }

}

