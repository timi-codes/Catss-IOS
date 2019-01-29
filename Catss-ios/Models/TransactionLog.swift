//
//  TransactionLog.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/29/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation

struct TransactionLog: Codable {
    let name : String
    let unit : String
    let qty : String
    let trade : String
    let amount : String
    let date : String
    
    enum CodingKeys: String, CodingKey {
        case name = "stock_name"
        case unit = "stock_unit"
        case qty = "stock_qty"
        case trade = "stock_trade"
        case amount = "stock_amount"
        case date = "stock_date"
    }
}

