//
//  AccountRequest.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/17/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum AccountRequest{
    case support(userId: Int, subject: String, message: String)
    case authenticate(userId: Int, password: String)
    case passwordReset(userId: Int, oldPassword: String, newPassword: String)
    case loadUserDetails(userId:Int)
    case updateUserDetail(userId : Int, phone : Int, address : String, state : String)
    case postDepositReference(userId : Int, refId:String, amount:Int)
    case withdrawAmount(userId : Int, amount: Double)
}

extension AccountRequest : TargetType {
    
    public var baseURL: URL {
        return URL(string: Constant.BASE_URL)!
    }
    
    public var path: String {
        switch self {
        case .support(_):
            return Constant.SEND_SUPPORT_MESSAGE
        case .authenticate(_):
            return Constant.AUTHENTICATE_USER
        case .passwordReset(_):
            return Constant.RESET_PASSWORD
        case .loadUserDetails(_):
            return Constant.USER_PROFILE
        case .updateUserDetail(_):
            return Constant.UPDATE_PROFILE
        case .postDepositReference(_):
            return Constant.POST_REF
        case .withdrawAmount(_):
            return Constant.WITHDRAW
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .support(_),.authenticate(_),.passwordReset(_),.updateUserDetail(_),.postDepositReference(_),.withdrawAmount(_):
            return .post
        case .loadUserDetails(_):
            return .get
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .support(let userId, let subject, let message):
            return .requestParameters(parameters: ["userid":userId, "subject":subject, "message":message], encoding: URLEncoding.queryString)
        case .authenticate(let userId, let password):
            return .requestParameters(parameters: ["userid":userId, "password":password], encoding:URLEncoding.queryString)
        case .passwordReset(let userId, let oldPassword, let newPassword):
            return .requestParameters(parameters: ["userid":userId, "oldpassword":oldPassword, "newpassword": newPassword], encoding: URLEncoding.queryString)
        case .loadUserDetails(let userId):
            return .requestParameters(parameters: ["userid":userId], encoding: URLEncoding.queryString)
        case .updateUserDetail(let userId, let phone, let address, let state):
            return .requestParameters(parameters: ["userid":userId, "phone": phone, "address":address, "state":state], encoding: URLEncoding.queryString)
        case .postDepositReference(let userId, let refId, let amount):
            return .requestParameters(parameters: ["userid" : userId, "refid" : refId, "amount" : amount], encoding: URLEncoding.queryString)
        case .withdrawAmount(let userId, let amount):
            return .requestParameters(parameters: ["userid" : userId, "amount" : amount], encoding: URLEncoding.queryString)
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
