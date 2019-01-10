//
//  StockIndex.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/20/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation
import Alamofire


struct StockIndex :   Codable {
    let id: Int
    let pairs, stockIndexOpen, close: String
    
    var percentile: Double {
        let changeInPrice = stockIndexOpen.toDouble - close.toDouble
        return changeInPrice / close.toDouble  * 100
    }
    
    enum CodingKeys: String, CodingKey {
        case id, pairs
        case stockIndexOpen = "open"
        case close
    }
}

struct StockIndexError : Codable {
    let status: String?
    let message: String?
}
