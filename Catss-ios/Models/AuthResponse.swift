//
//  AuthResponse.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/3/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation

struct AuthResponse: Codable{
    let status : String?
    let message : String?
    let userid : Int?
    let error : Int?
}


