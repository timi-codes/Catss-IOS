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

//public static final String USER = "/user";
//public static final String LOGIN = "login" + USER;
//public static final String REGISTER = "signup" + USER;
//public static final String GET_ACCOUNT = "account" + USER ;
//public static final String GET_BALANCE = "stocks" + USER;
//public static final String GET_STOCK_HISTORY = "transaction" + USER;
//public static final String SEND_SUPPORT_MESSAGE = "contact/message";
//public static final String CHANGE_PASSWORD = "change/password";
//public static final String USER_PROFILE = "profile-info/user";
//public static final String UPDATE_PROFILE = "update/setting";
//public static final String AUTHENTICATE_USER = "verify/authenticated";

//public static final String SECURITIES = "load/securities";
//
//public static final String BUY = "/buy";
//public static final String SELL = "/sell";
//
//public static final String POST_REF = "deposit/payment";

//public static final String MARKET_ORDER_BUY = "trade/request"+BUY;
//public static final String MARKET_ORDER_SELL = "trade/request"+SELL;
//public static final String PLACE_ORDER_ASK = "place/order" + SELL;
//public static final String PLACE_ORDER_BID = "place/order" + BUY;
//public static final String LOAD_OPEN_ORDER = "load/orders/all";
//
//public static final String SET_WATCHLIST = "set/watchlist";
//public static final String GET_WATCHLIST = "load/watchlist";
//public static final String REMOVE_FROM_WATCHLIST = "cancel/watchlist";
//public static final String SET_PRICE_ALERT = "set/price-alert";
//public static final String RANKING = "load/ranking";
//public static final String FINANCIALNEWS = "load/news";
//public static final String STOCKINDEX = "load/stockindex";
///api/droid
//public static final String API_HEADER_KEY = "x-access-token";
//yc3ROYW1lIjoiQnJldHQiLCJsYXN0TmFtZSI6Ikxhd3NvbiIsInBob25lTnVtYmVyIjoiNTIxMzM4MTQwOCIsInVybCI6InRlam

public enum UserRequest{
    case registerUser(_ userDetailParams:[String:String])
    case login(loginParams:[String:String])
    case getAccount(userId: Int)
    case getStockBalance(userId: Int)
    case getStockHistory(userId: Int)
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
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login, .registerUser:
            return .post
        case .getAccount, .getStockBalance, .getStockHistory:
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
