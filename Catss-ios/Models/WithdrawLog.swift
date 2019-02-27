//
//  WithdrawLog.swift
//  Catss-ios
//
//  Created by Tejumola David on 2/26/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation

struct WithdrawLog: Codable {
    
    let id : Int
    let userId : String
    let amount : String
    let status : String
    let createdAt : String
    let updatedAt : String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case amount = "amount"
        case status = "status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }
}
