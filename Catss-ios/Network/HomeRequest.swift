//
//  HomeRequest.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/14/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import Alamofire

public enum HomeRequest {
    case ranking
    case priceTicker
    case news
}

extension HomeRequest : TargetType {
    public var baseURL: URL {
        return URL(string: Constant.BASE_URL)!
    }
    
    public var path: String {
        switch self {
        case .ranking:
            return Constant.RANKING
        case .priceTicker:
            return Constant.STOCKINDEX
        case .news:
            return Constant.FINANCIALNEWS
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var headers: [String : String]? {
        let header = [Constant.AUTH_TOKEN_KEY: Constant.AUTH_TOKEN]
        return header
    }
    
    public var validationType: ValidationType {
        return .customCodes(Array(200..<501))
    }
}
