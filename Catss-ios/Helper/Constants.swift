//
//  Constants.swift
//  Catss-ios
//
//  Created by Tejumola David on 11/16/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit

class Constant {
    
    static let BASE_URL = "http://equities.catss.ng/api/droid/"
    static let AUTH_TOKEN_KEY = "x-access-token";
    static let AUTH_TOKEN = "yc3ROYW1lIjoiQnJldHQiLCJsYXN0TmFtZSI6Ikxhd3NvbiIsInBob25lTnVtYmVyIjoiNTIxMzM4MTQwOCIsInVybCI6InRlam"

    //path for UserRequest
    static let USER = "/user"
    static let  LOGIN = "login" + USER
    static let REGISTER = "signup" + USER
    static let GET_ACCOUNT = "account" + USER
    static let GET_STOCK_BALANCE = "stocks" + USER
    static let GET_STOCK_HISTORY = "transaction" + USER
    static let SEND_SUPPORT_MESSAGE = "contact/message"
    static let RESET_PASSWORD = "change/password"
    static let USER_PROFILE = "profile-info/user"
    static let UPDATE_PROFILE = "update/setting"
    static let AUTHENTICATE_USER = "verify/authenticated"

    
    //path for TransactionRequest
    static let SECURITIES = "load/securities"
    static let BUY = "/buy"
    static let SELL = "/sell"
    static let POST_REF = "deposit/payment"
    
    static let MARKET_BUY = "trade/request" + BUY
    static let MARKET_SELL = "trade/request" + SELL
    
    
    static let PLACE_ORDER_ASK = "place/order" + SELL
    static let PLACE_ORDER_BID = "place/order" + BUY
    static let CANCEL_ORDER = "cancel/order"

    static let LOAD_OPEN_ORDER = "load/orders/all"
    
    static let SET_WATCHLIST = "set/watchlist"
    static let GET_WATCHLIST = "load/watchlist"
    static let REMOVE_FROM_WATCHLIST = "cancel/watchlist"
    static let SET_PRICE_ALERT = "set/price-alert"
    static let RANKING = "load/ranking"
    static let FINANCIALNEWS = "load/news"
    static let STOCKINDEX = "load/stockindex"
    
}


//extion for static functions
extension Constant{
    static func  validateString(_ value: String?, pattern: String) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", pattern)
        return test.evaluate(with: value)
    }
}

struct Color {
    static let primaryColor: UIColor = #colorLiteral(red: 0.1019607843, green: 0.1529411765, blue: 0.168627451, alpha: 1)
    static let secondaryColor: UIColor = #colorLiteral(red: 0.07450980392, green: 0.1176470588, blue: 0.1294117647, alpha: 1)
    static let backgroundColor: UIColor = #colorLiteral(red: 0.1058823529, green: 0.168627451, blue: 0.1882352941, alpha: 1)
    static let tabItemTintColor: UIColor = #colorLiteral(red: 0.4331240464, green: 0.5432817826, blue: 0.5701597025, alpha: 1)
    static let accentColor: UIColor = #colorLiteral(red: 0.4509803922, green: 0.4509803922, blue: 0.9254901961, alpha: 1)
    static let warningColor: UIColor = #colorLiteral(red: 0.8196078431, green: 0.1529411765, blue: 0.1529411765, alpha: 1)
    static let successColor: UIColor = #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.3254901961, alpha: 1)
}

