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
    case marketOrderBuy(userId: Int, total: String, secId: Int)
    case marketOrderSell(userId: Int, total: String, secId: Int)
    case setWatchlist(userId: Int, secId: Int)
    case loadWatchlist(userId: Int)
    case removeWatchlist(userId: Int, secId: Int)
    case setPriceAlert(userId: Int, secId: Int, price: String)
}

extension MarketRequest : TargetType {
    public var baseURL: URL {
        return URL(string: Constant.BASE_URL)!
    }
    
    public var path: String {
        switch self {
        case .loadSecurities():
            return Constant.SECURITIES
        case .marketOrderBuy(_):
            return Constant.MARKET_ORDER_BUY
        case .marketOrderSell(_):
            return Constant.MARKET_ORDER_SELL
        case .setWatchlist(_):
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
        case .marketOrderBuy(_), .marketOrderSell(_), .setWatchlist(_), .removeWatchlist(_), .setPriceAlert(_):
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
        case .marketOrderBuy(let userId, let total, let secId):
            return .requestParameters(parameters: ["userid" : userId, "total" : total, "secid" : secId], encoding: URLEncoding.queryString)
        case .marketOrderSell(let userId, let total, let secId):
            return .requestParameters(parameters: ["userid" : userId, "total" : total, "secid" : secId], encoding: URLEncoding.queryString)
        case .setWatchlist(let userId, let secId):
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
