//
//  UserRequest.swift
//  Catss-ios
//
//  Created by Tejumola David on 11/28/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum UserRequest{
    case registerUser(_ userDetailParams:[String:String])
    case login(loginParams:[String:String])
    case getAccount(userId: Int)
    case getStockBalance(userId: Int)
    case getStockHistory(userId: Int)
    case getWithdrawalLog(userId: Int)

}


extension UserRequest : TargetType {
    
    public var baseURL: URL {
        return URL(string: Constant.BASE_URL)!
    }
    
    public var path: String {
        switch self {
        case .login:
            return Constant.LOGIN
        case .registerUser:
            return Constant.REGISTER
        case .getAccount:
            return Constant.GET_ACCOUNT
        case .getStockBalance:
            return Constant.GET_STOCK_BALANCE
        case .getStockHistory:
            return Constant.GET_STOCK_HISTORY
        case .getWithdrawalLog:
            return Constant.GET_WITHDRAWAL_LOG
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login, .registerUser:
            return .post
        case .getAccount, .getStockBalance, .getStockHistory, .getWithdrawalLog:
            return .get
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .login(let loginParams):
            return .requestParameters(parameters: loginParams, encoding: URLEncoding.default)
        case .registerUser(let userDetailParams):
            return .requestParameters(parameters: userDetailParams, encoding: URLEncoding.default)
        case .getAccount(let userid):
            return .requestParameters(parameters:["userid" : userid], encoding: URLEncoding.queryString)
        case .getStockBalance(let userid):
            return .requestParameters(parameters:["userid" : userid], encoding: URLEncoding.queryString)
        case .getStockHistory(let userid):
            return .requestParameters(parameters:["userid" : userid], encoding: URLEncoding.queryString)
        case .getWithdrawalLog(let userid):
            return .requestParameters(parameters: ["userid" : userid], encoding: URLEncoding.queryString)
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
