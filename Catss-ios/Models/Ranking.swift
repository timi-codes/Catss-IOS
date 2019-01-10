//
//  Ranking.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/14/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation

struct Ranking: Codable {
    let ranking: [Rank]
}

struct Rank: Codable {
    let userId: Int
    let userName: String
    let pAndL: Double
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case userName = "user"
        case pAndL = "profit"
    }
}

struct RankingError: Codable {
    let status: String?
    let message: String?
    let error: Int?
}
