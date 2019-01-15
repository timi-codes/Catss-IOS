//
//  OrderRequest.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/15/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum OrderRequest{
    
    case orderBid(userId: Int, secId: Int, price : Double, quantity : Int)
     case orderAsk(userId: Int, secId: Int, price : Double, quantity : Int)
    case loadAllOrder(userId: Int)
    case cancelOrder(userId: Int, orderId: Int)
}

extension OrderRequest : TargetType {
    public var baseURL: URL {
        return URL(string: Constant.BASE_URL)!
    }
    
    public var path: String {
        switch self {
        case .orderBid(_):
            return Constant.PLACE_ORDER_BID
        case .orderAsk(_):
            return Constant.PLACE_ORDER_ASK
        case .loadAllOrder(_):
            return Constant.LOAD_OPEN_ORDER
        case .cancelOrder(_):
            return Constant.CANCEL_ORDER
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .loadAllOrder(_):
            return .get
        case .orderBid(_), .orderAsk(_), .cancelOrder(_):
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .loadAllOrder(let userId):
            return .requestParameters(parameters: ["userid" : userId], encoding: URLEncoding.queryString)
        case .cancelOrder(let userId, let orderId):
            return .requestParameters(parameters: ["userid" : userId, "orderid" : orderId], encoding: URLEncoding.queryString)
        case .orderBid(let userId, let secId, let price, let quantity):
            return .requestParameters(parameters: ["userid" : userId, "secid" : secId, "type" : "buy", "option":"limit", "price" : price, "total" : quantity], encoding: URLEncoding.queryString)
        case .orderAsk(let userId, let secId, let price, let quantity):
            return .requestParameters(parameters: ["userid" : userId, "secid" : secId, "type" : "sell", "option":"limit", "price" : price, "total" : quantity], encoding: URLEncoding.queryString)
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
