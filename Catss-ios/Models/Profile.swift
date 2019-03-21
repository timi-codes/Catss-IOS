//
//  Profile.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/3/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation

struct Profile: Codable {
    let id:Int?
    let account_id : String?
    let name, email, avatar : String?
    let phone,address, zip_code, state : String?
    let account_bal : String?
    let account_no: String?
    let bank_name : String?
}

struct ProfileError: Codable {
    let status: String?
    let message: String?
}
