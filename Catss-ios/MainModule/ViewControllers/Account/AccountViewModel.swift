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

class AccountViewModel {
    let provider = MoyaProvider<AccountRequest>(plugins:[NetworkLoggerPlugin(verbose:true)])
    
    private let disposeBag = DisposeBag()
    typealias AuthCompletion = (_ error: String?)-> Void
    
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
    
}
