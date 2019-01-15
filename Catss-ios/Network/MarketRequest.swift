//
//  MarketRequest.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/7/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum MarketRequest{
    case loadSecurities()
    case marketBuy(userId: Int, total: Int, secId: Int)
    case marketSell(userId: Int, total: Int, secId: Int)
    case addToWatchlist(userId: Int, secId: Int)
    case loadWatchlist(userId: Int)
    case removeWatchlist(userId: Int, secId: Int)
    case setPriceAlert(userId: Int, secId: Int, price: Double)
}

extension MarketRequest : TargetType {
    public var baseURL: URL {
        return URL(string: Constant.BASE_URL)!
    }
    
    public var path: String {
        switch self {
        case .loadSecurities():
            return Constant.SECURITIES
        case .marketBuy(_):
            return Constant.MARKET_BUY
        case .marketSell(_):
            return Constant.MARKET_SELL
        case .addToWatchlist(_):
            return Constant.SET_WATCHLIST
        case .loadWatchlist(_):
            return Constant.GET_WATCHLIST
        case .removeWatchlist(_):
            return Constant.REMOVE_FROM_WATCHLIST
        case .setPriceAlert(_):
            return Constant.SET_PRICE_ALERT
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .loadSecurities(), .loadWatchlist(_):
            return .get
        case .marketBuy(_), .marketSell(_), .addToWatchlist(_), .removeWatchlist(_), .setPriceAlert(_):
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .loadSecurities():
            return .requestPlain
        case .loadWatchlist(let userId):
            return .requestParameters(parameters: ["userid" : userId], encoding: URLEncoding.queryString)
        case .marketBuy(let userId, let total, let secId):
            return .requestParameters(parameters: ["userid" : userId, "total" : total, "secid" : secId], encoding: URLEncoding.queryString)
        case .marketSell(let userId, let total, let secId):
            return .requestParameters(parameters: ["userid" : userId, "total" : total, "secid" : secId], encoding: URLEncoding.queryString)
        case .addToWatchlist(let userId, let secId):
            return .requestParameters(parameters: ["userid" : userId, "secid" : secId], encoding: URLEncoding.queryString)
        case .removeWatchlist(let userId, let secId):
            return .requestParameters(parameters: ["userid" : userId, "secid" : secId], encoding: URLEncoding.queryString)
        case .setPriceAlert(let userId, let secId, let price):
            return .requestParameters(parameters: ["userid" : userId, "secid" : secId, "price" : price], encoding: URLEncoding.queryString)
        }
    }
    
    public var headers: [String : String]? {
        let header = [Constant.AUTH_TOKEN_KEY: Constant.AUTH_TOKEN]
        return header
    }
    
    public var validationType: ValidationType {
        return .customCodes(Array(200..<501))
    }
}
