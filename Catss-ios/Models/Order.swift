//
//  File.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/16/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation

struct AllOrder: Codable{
    let status : String?
    let message : String?
    let orders : [Open]?
}

struct Open: Codable{
    let orderId : Int
    let secId : String
    let securityName : String
    let userId : Int
    let refId : String
    let price : String
    let quantity : String
    let type : String
    let option : String
    let date : String
    
    enum CodingKeys: String, CodingKey {
        case id
        case secId = "sec_id"
        case asset
        case userId = "user_id"
        case refId = "ref_id"
        case price, qty, type, option, date
    }
}
}
