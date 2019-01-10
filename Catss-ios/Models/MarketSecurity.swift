//
//  Security.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/7/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation

struct MarketSecurity : Codable {
   
    let id : Int
    let board : String?
    let securityName : String
    let refPrice : Double?
    let openPrice : Double?
    let closePrice : Double?
    let changePrice : Double?
    let previousClose : Double?
    let realPrice : Double?
    let newPrice : Double?
    let status : String?
    let date : String
    
    let trade : Int?
    let price : String?
    let gap : Int?
    
    enum CodingKeys : String, CodingKey {
        case id, board, status, date, trade, price, gap
        case securityName = "security"
        case refPrice = "ref_price"
        case openPrice = "open_price"
        case closePrice = "close_price"
        case changePrice = "change_price"
        case previousClose = "previous_close"
        case realPrice = "real_price"
        case newPrice = "new_price"
    }
    
}
