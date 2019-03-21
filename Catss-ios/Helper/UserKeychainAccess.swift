//
//  UserKeyChainAccess.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/3/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//
import Foundation
import KeychainAccess


struct UserKeychainAccess{
    
    private static let profileKey = "profile"
    private static let fingerPrintEnabled = "fingerEnabled"
    private static let bankKey = "bank"

    
    private static let keychain = Keychain(service: "com.cavidel.Catss")
    
    static func saveUserProfile(dict: [String:Any]){
        do {
            print(dict)
            let data = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: true) as Data
            try keychain.set(data, key: profileKey)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    static func getUserProfile() ->Profile? {
        do {
            guard let data = try keychain.getData(profileKey) else{
                return nil
            }
            
            if let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Any]{
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let profile = try JSONDecoder().decode(Profile.self, from: jsonData)
                return profile
            }else{
                return nil
            }
            
        }catch let DecodingError.dataCorrupted(context) {
            print(context)
            return nil
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    static func setFingerPrintEnabled(_ isEnabled:Bool){
        do{
            print(isEnabled)
            try keychain.set(isEnabled.description, key: fingerPrintEnabled)
        }catch{
            print("\(error.localizedDescription)")
        }
    }
    
    static func isFingerPrintEnabled()->Bool{
        do {
            guard let data = try keychain.get(fingerPrintEnabled) else{
                fatalError()
            }
            
            return data == "true" ? true : false
            
        }catch {
            print("error: ", error.localizedDescription)
            return false
        }
        
    }
    
    static func removeProfile() {
        do {
            try keychain.remove(profileKey)
        } catch let error {
            print("error: \(error.localizedDescription)")
        }
    }
    
    static func saveAccountDetailsToKeychain(account: String, password: String){
        guard !account.isEmpty, !password.isEmpty else { return }
        
        UserDefaults.standard.set(account, forKey: "lastAccessedUserName")
        
        do{
            try keychain.set(password, key: "password")
            
        }catch let error{
            print("error: \(error.localizedDescription)")
        }
        
    }
    
    static func loadPasswordFromKeychain(account:String)->String?{
        do {
            let savedPassword = try keychain.get("password")
            return savedPassword
        } catch let error {
            print("error: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    static func saveBanks(banks: [Bank]) {
        do {
            let dict = try banks.map {try $0.asDictionary()}
            let data = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: true) as Data
            try keychain.set(data, key: bankKey)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    static func getBanks() -> [Bank]? {
        do {
            guard let data = try keychain.getData(bankKey) else {return nil}
            if let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [[String: Any]?]{
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let decoder = JSONDecoder()
                let banks  = try decoder.decode([Bank].self, from: jsonData)
                let sortedBank = banks.sorted(by: { $0.name.lowercased() > $1.name.lowercased() })
                return sortedBank
            } else {
                return nil
            }
        } catch {
            print("\(error.localizedDescription)")
            return nil
        }
    }
}
