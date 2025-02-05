//
//  AccountViewModel.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/17/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RxCocoa
import RxSwift
import KeychainAccess
import Paystack

class AccountViewModel {
    let provider = MoyaProvider<AccountRequest>(plugins:[NetworkLoggerPlugin(verbose:true)])
    
    private let disposeBag = DisposeBag()
    typealias AuthCompletion = (_ error: String?)-> Void
    typealias BanksCompletion = (_ banks: [Bank])-> Void
    
    var getProfile: Profile? {
        guard let profile = UserKeychainAccess.getUserProfile() else{ return nil }
        return profile
    }
    
    private func sendMessageStream(userId:Int, subject:String, message: String, completion: @escaping AuthCompletion)->Observable<String>{
        
        return Observable<String>.create({ observer -> Disposable in
            
            let request =  self.provider.request(.support(userId: userId, subject: subject, message: message)) { [weak self] result in
                guard `self` != nil else{return}
                
                switch result {
                case .success(let response):
                    do{
                        let data = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                        
                        if let message = data.message{
                            observer.onNext(message)
                        }
                        observer.onCompleted()
                    }catch let err{
                        print(String(describing: err.localizedDescription))
                    }
                case .failure(let error):
                    print(error)
                    
                }
            }
            return Disposables.create{request.cancel()}
        })
        
    }
    
    func sendSupportMessage(subject:String, message: String, completion: @escaping AuthCompletion){
        if let id = self.getProfile?.id {
            sendMessageStream(userId: id, subject: subject, message: message, completion: completion)
                .subscribe(onNext:{message in
                    completion(message)
                }, onError: { error in
                    print(String(describing: error.localizedDescription))
                    completion(error.localizedDescription)
                }).disposed(by: disposeBag)
        }
        
    }
    
    
    private func resetPasswordStream(userId:Int, oldPassword:String, newPassword: String, completion: @escaping AuthCompletion)->Observable<String>{
        
        return Observable<String>.create({ observer -> Disposable in
            
            let request =  self.provider.request(.passwordReset(userId: userId, oldPassword:oldPassword, newPassword:newPassword)) { [weak self] result in
                guard `self` != nil else{return}
                
                switch result {
                case .success(let response):
                    do{
                        let data = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                        
                        if let message = data.message{
                            observer.onNext(message)
                        }
                        observer.onCompleted()
                    }catch let err{
                        print(String(describing: err.localizedDescription))
                    }
                case .failure(let error):
                    print(error)
                    
                }
            }
            return Disposables.create{request.cancel()}
        })
        
    }
    
    func resetPassword(oldPassword:String, newPassword: String, completion: @escaping AuthCompletion){
        if let id = self.getProfile?.id {
            resetPasswordStream(userId: id, oldPassword: oldPassword, newPassword: newPassword, completion: completion)
                .subscribe(onNext:{message in
                    completion(message)
                }, onError: { error in
                    print(String(describing: error.localizedDescription))
                    completion(error.localizedDescription)
                }).disposed(by: disposeBag)
        }
        
    }
    
    func processPayment(cardParams: PSTCKCardParams, vc: UIViewController, completion: @escaping AuthCompletion) {
        
        if let email = self.getProfile?.email {
            let transactionParams = PSTCKTransactionParams.init()
            transactionParams.amount = 20000 * 100
            transactionParams.email = email
            transactionParams.additionalAPIParameters = ["enforce_otp": "true"]
            
            PSTCKAPIClient.shared().chargeCard(cardParams, forTransaction: transactionParams, on: vc, didEndWithError: { (error, reference) in
                print(error)
                //self.outputOnLabel(str: "Charge errored")
                // what should I do if an error occured?
                print(error)
                if error._code == PSTCKErrorCode.PSTCKExpiredAccessCodeError.rawValue{
                    // access code could not be used
                    // we may as well try afresh
                }
                if error._code == PSTCKErrorCode.PSTCKConflictError.rawValue{
                    // another transaction is currently being
                    // processed by the SDK... please wait
                }
                if let errorDict = (error._userInfo as! NSDictionary?){
                    
                    if let errorString = errorDict.value(forKeyPath: "com.paystack.lib:ErrorMessageKey") as! String? {
                        if let _ = reference {
                            completion("An error occured while completing: \(errorString)")
                        } else {
                            completion("An error occured while completing: \(errorString)")
                        }
                    }
                }
                
            }, didRequestValidation: { (reference) in
                completion("")
                //self.outputOnLabel(str: "requested validation: " + reference)
            }, willPresentDialog: {
                completion("")
                // make sure dialog can show
                // if using a "processing" dialog, please hide it
                //self.outputOnLabel(str: "will show a dialog")
            }, dismissedDialog: {
                completion("")
                // if using a processing dialog, please make it visible again
                // self.outputOnLabel(str: "dismissed dialog")
                // self.stopAnimating()
            }) { (reference) in
                //self.outputOnLabel(str: "succeeded: " + reference)
                ///self.chargeCardButton.isEnabled = true;
                
                self.verifyTransaction(reference: reference, completion: completion)
                //completed()
            }
            return
        }
        
    }
    
    func verifyTransaction(reference: String, completion: @escaping AuthCompletion){
        
        if let id = self.getProfile?.id {
            provider.request(.postDepositReference(userId: id, refId: reference , amount : 20000)) {result in
                
                switch result {
                case .success(let response):
                    do {
                        print(try response.mapJSON())
                        let output = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                            completion(output.message)
                    } catch let error {
                        completion(error.localizedDescription)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    
    func authenticate(password : String, completion: @escaping AuthCompletion){
        if let id = self.getProfile?.id {
            provider.request(.authenticate(userId: id, password: password)){ result in
                switch result {
                case .success(let response):
                    do {
                        print(try response.mapJSON())
                        let output = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                        completion(output.status)
                    } catch let error {
                        completion(error.localizedDescription)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    //userId : Int, phone : Int, address : String, zipcode : String, accountNumber : String, bankName : String
    func updateUserProfile(phone : Int, address : String, zipcode: String, accountNumber : String, bankName : String, completion: @escaping AuthCompletion){
        if let id = self.getProfile?.id {
            provider.request(.updateUserDetail(userId: id, phone: phone,  address: address, zipcode: zipcode, accountNumber:accountNumber, bankName : bankName)){ result in
                switch result {
                case .success(let response):
                    do {
                        print(try response.mapJSON())
                        let output = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                        completion(output.message)
                    } catch let error {
                        completion(error.localizedDescription)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    

    func loadUserProfile(completion: @escaping AuthCompletion){
        if let id = self.getProfile?.id {
            provider.request(.loadUserDetails(userId: id)){ result in
                switch result {
                case .success(let response):
                    do {
                        print(try response.mapJSON())
                        let output = self.extractProfile(id,response)
                        completion(output)
                    } catch let error {
                        completion(error.localizedDescription)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    
    private func extractProfile(_ id: Int, _ response: Response) -> String? {
        do {
            let data = try JSONDecoder()
                .decode(ProfileError.self, from: response.data)
            if data.message == nil {
                if var json = try response.mapJSON() as? [String: Any]  {
                    print("\(json) extracted json")
                    json["id"] = id
                    UserKeychainAccess.saveUserProfile(dict: json)
                    return nil
                } else {
                    print(String(describing: data))
                    return "Please try again!"
                }
            } else {
                return data.message
            }
        } catch let err {
            print(String(describing: err.localizedDescription))
            return err.localizedDescription
        }
    }
    
    
    func requestWithdrawal(amount : Double, completion: @escaping AuthCompletion){
        if let id = self.getProfile?.id {
            provider.request(.withdrawAmount(userId: id, amount: amount)) { result in
                switch result {
                case .success(let response):
                    do{
                        print(try response.mapJSON())
                        let output = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                        completion(output.message)
                    } catch let error {
                        completion(error.localizedDescription)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    func getBanks(completion: @escaping BanksCompletion){
        
            provider.request(.fetchBanks) {[weak self] result in
                switch result {
                case .success(let response):
                    do {
                        let output = try JSONDecoder().decode(BankResponse.self, from: response.data)
                        
                        UserKeychainAccess.saveBanks(banks: output.bank)
                        
                        let sortedBank = output.bank.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                        
                        completion(sortedBank)
                        
                    }catch let error {
                        print(error.localizedDescription)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
}
