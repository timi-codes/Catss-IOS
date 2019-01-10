//
//  OnBoardingViewModel.swift
//  Catss-ios
//
//  Created by Tejumola David on 11/27/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import KeychainAccess


enum ValidateResult: Equatable {
    case success
    case error(ValidationError)
}


enum ValidationError: String, Error {
    case invalidName = "Cannot be empty or less than 3 characters!"
    case invalidPhoneNumber = "Invalid Phone Number !"
    case invalidEmail = "Invalid Email Address !"
    case invalidPassword = "Invalid Password !"
}


class OnBoardingViewModel{
    
    typealias AuthCompletion = (_ error: String?)-> Void
    
    let provider = MoyaProvider<UserRequest>()
    
    let disposeBag = DisposeBag()
    
    var email = BehaviorRelay<String>(value:"")
    var password = BehaviorRelay<String>(value:"")
    var name = BehaviorRelay<String>(value:"")
    var phone = BehaviorRelay<String>(value:"")
    
    var userId: Int?
    
    var getProfile: Profile? {
        guard let profile = UserKeychainAccess.getUserProfile() else{ return nil }
        return profile
    }
    
    
    var isValid: Observable<Bool>{
        return Observable.combineLatest(email.asObservable(), password.asObservable(), name.asObservable(), phone.asObservable()){ email, password, name, phone in
            email.count > 0 && password.count > 0 && name.count>0 && phone.count > 0
        }
    }
    
    var isUserLoggedIn: Observable<Bool>{
        if let profile = UserKeychainAccess.getUserProfile() {
            if profile.email != nil{
                return Observable.just(true)
            }
        }
        return Observable.just(false)
    }
    
    
    //Validate if all the values in an array stream contains ValidateResult.success
    func isValid<T: Observable<[ValidateResult]>>(stream:T) -> Observable<Bool>{
        return stream.scan(true, accumulator: { (acc,value) -> Bool in
            let valid = value.reduce(false, { (_, type) -> Bool in
                return (type == ValidateResult.success) ? true : false
            })
            print(valid)
            return acc == valid
        })
    }
    
    //create an array of observable from login fields
    var loginStreamArray: Observable<[ValidateResult]> {
        return Observable.of([email.value, password.value]).map({ (values) -> [ValidateResult] in
            return [self.validateEmail(value: values[0]), self.validPassword(value: values[1])]
        })
    }
    
    //validates email adress matches email pattern
    func validateEmail(value: String)->ValidateResult{
        let emailPattern = "[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]{2,64})+\\.[A-Za-z]{2,64}"
        guard Constant.validateString(value, pattern: emailPattern) else {
            return .error(ValidationError.invalidEmail)
        }
        return .success
    }
    
    
    //ensures password is not empty
    func validPassword(value: String) -> ValidateResult {
        if value.isEmpty {
            return .error(ValidationError.invalidPassword)
        }
        return .success
    }
    
    
    func authenticateStream(params:[String : String], completion: @escaping AuthCompletion) -> Observable<AuthResponse> {
        return Observable<AuthResponse>.create({ observer in
            let request = self.provider.request(.login(loginParams: params)){
                [weak self] result in
                guard self != nil else {return}
                switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                        observer.onNext(data)
                        observer.onCompleted()
                        //completion(data.message)
                    }catch let err {
                        print(String(describing: err.localizedDescription))
                    }
                case .failure(let error):
                    print(error)
                    completion(error.localizedDescription)
                }
            }
            //Finally, we return a disposable to stop the request
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    
    func getUserAccountStream(userId:Int, completion: @escaping AuthCompletion) -> Observable<Response> {
        return Observable<Response>.create({ observer in
            let request = self.provider.request(.getAccount(userId: userId)){
                [weak self] result in
                guard `self` != nil else {return}
                switch result {
                case .success(let response):
                    print(response)
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let err):
                    observer.onError(err)
                    print(err)
                }
            }
            //Finally, we return a disposable to stop the request
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    private func extractProfile(_ response: Response) -> String? {
        do {
            let data = try JSONDecoder()
                .decode(ProfileError.self, from: response.data)
            if data.message == nil {
                if var json = try response.mapJSON() as? [String: Any]  {
                    print("\(json) extracted json")
                    json["id"] = userId
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
    
    func loginUser(params:[String : String], completion:  @escaping AuthCompletion) {
        authenticateStream(params:params,completion: completion).asObservable()
            .flatMap{ [weak self] (authResponse) -> Observable<Response> in
                
                guard let `self` = self else {
                    return Observable.empty()
                }
                guard let id = authResponse.userid else {
                    completion(authResponse.message)
                    return Observable.empty()
                }
                
                self.userId = id
                
                return self.getUserAccountStream(userId:id, completion: completion)
            }
            .subscribe(onNext:{ response in
                let output =  self.extractProfile(response)
                completion(output)
            }, onError : { error in
                print(String(describing: error.localizedDescription))
                completion(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    
    
    func registerUserStream(userDetailParams: [String: String], completion: @escaping AuthCompletion)->Observable<String>{
        return Observable<String>.create({ observer -> Disposable in
            let request = self.provider.request(.registerUser(userDetailParams)){
                [weak self] result in
                guard self != nil else {return}
                switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                        if let message = data.message {
                            observer.onNext(message)
                        }
                        observer.onCompleted()
                    }catch let err {
                        print(String(describing: err.localizedDescription))
                    }
                case .failure(let error):
                    print(error)
                    completion(error.localizedDescription)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func registerUser(userDetailParams: [String: String], completion: @escaping AuthCompletion){
        registerUserStream(userDetailParams: userDetailParams, completion: completion)
            .subscribe(onNext: { message in
                completion(nil)
            }, onError: { error in
                print(String(describing: error.localizedDescription))
                completion(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    
    
}



