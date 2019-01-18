//
//  File.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/16/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation

struct AllOrder: Codable {
    let status, message: String
    let orders: [Order]
}

struct Order: Codable {
    let id: Int
    let secId, asset, userId, refId: String
    let price, qty, type, option: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case secId = "sec_id"
        case asset
        case userId = "user_id"
        case refId = "ref_id"
        case price, qty, type, option, date
    }
}
