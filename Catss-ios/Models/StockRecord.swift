//
//  StockBalance.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/21/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation

struct StockRecord : Codable {
    let accountBalance : String?
    let stockBalance : [StockBalance]
    let stockRevaluation: StockRevaluation
    
    enum CodingKeys : String, CodingKey {
        case accountBalance  = "account_balance"
        case stockBalance = "stock_balance"
        case stockRevaluation = "stock_revaulation"
    }
}

struct StockBalance : Codable {
    let name: String
    let qty: String
    let price: String
}

struct StockRevaluation : Codable {
    let profit: Double
    let loss: Double
    let net: Double
    let bal: Double
    let tag: String
}
