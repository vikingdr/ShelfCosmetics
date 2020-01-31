//
//  ShopifyAddress.swift
//  Shelf
//
//  Created by Nathan Konrad on 11/3/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import Foundation
import ObjectMapper

let kShopifyAddress1 = "address1"
let kShopifyPhone = "phone"
let kShopifyCity = "city"
let kShopifyZip = "zip"
let kShopifyProvince = "province"
let kShopifyCountry = "country"
let kShopifyAddress2 = "address2"
let kShopifyCompany = "company"
let kShopifyLatitude = "latitude"
let kShopifyLongitude = "longitude"
let kShopifyCountryCode = "countryCode"
let kShopifyProvinceCode = "provinceCode"

class ShopifyAddress: Mappable {
    var id: Int?
    var firstName: String?
    var address1: String?
    var phone: String?
    var city: String?
    var zip: String?
    var province: String?
    var country: String?
    var lastName: String?
    var address2: String?
    var company: String?
    var latitude: Double?
    var longitude: Double?
    var name: String?
    var countryCode: String?
    var provinceCode: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                      <- map[kShopifyId]
        firstName               <- map[kShopifyFirstName]
        address1                <- map[kShopifyAddress1]
        phone                   <- map[kShopifyPhone]
        city                    <- map[kShopifyCity]
        zip                     <- map[kShopifyZip]
        province                <- map[kShopifyProvince]
        country                 <- map[kShopifyCountry]
        lastName                <- map[kShopifyLastName]
        address2                <- map[kShopifyAddress2]
        company                 <- map[kShopifyCompany]
        latitude                <- map[kShopifyLatitude]
        longitude               <- map[kShopifyLongitude]
        name                    <- map[kShopifyName]
        countryCode             <- map[kShopifyCountryCode]
        provinceCode            <- map[kShopifyProvinceCode]
    }
}
