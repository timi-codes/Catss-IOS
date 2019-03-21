//
//  Bank.swift
//  Catss-ios
//
//  Created by Tejumola David on 3/21/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation

struct BankResponse : Codable {
    let status : Bool
    let message : String
    let bank : [Bank]
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case bank = "data"
    }
}

struct Bank : Codable {
    let id : Int
    let name : String
    let code : String
}
