//
//  OrderViewModel.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/15/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//


import Foundation
import Moya
import Alamofire
import RxCocoa
import RxSwift
import KeychainAccess

class OrderViewModel {
    
    let provider = MoyaProvider<OrderRequest>(plugins:[NetworkLoggerPlugin(verbose:true)])
    
    private let disposeBag = DisposeBag()
    typealias AuthCompletion = (_ error: String?)-> Void
    
    private var _order = BehaviorRelay<AllOrder?>(value:nil)

    private var _openorder = BehaviorRelay<[Order]?>(value: nil)
    
    private var _isLoading = BehaviorRelay<Bool>(value: false)
    
    
    var isLoading: Driver<Bool> {return _isLoading.asDriver()}
    

    var getProfile: Profile? {
        guard let profile = UserKeychainAccess.getUserProfile() else{ return nil }
        return profile
    }
    
    var openOrder: Driver<[Order]?> {
        return _openorder.asDriver()
    }
    
    init(completion: @escaping AuthCompletion) {
        if let id = getProfile?.id{
            fetchAllOpenOrder(with: id).subscribe({_ in
                print("fetch order successfully")
            }).disposed(by: disposeBag)
        }
       
    }
    
    init(){
        
    }

    private func fetchAllOpenOrder(with id: Int)->Observable<String>{
        self._isLoading.accept(true)
        return Observable.create({ (observer) -> Disposable in
            let request = self.provider.request(.loadAllOrder(userId: id)){ [weak self] result in
                guard let `self` = self else {return}
                
                switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode(AllOrder.self, from: response.data)
                        self._order.accept(data)
                        self._openorder.accept(data.orders)
                        self._isLoading.accept(false)

                       
                        observer.onCompleted()
                        
                    }catch let err {
                        print(String(describing: err.localizedDescription))
                       self._isLoading.accept(false)

                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self._isLoading.accept(false)
                }
            }
            
            return Disposables.create{
                request.cancel()
                
            }
        })
    }
    
    

    func bidAskOrder(secId: Int, price: Double, quantity: Int, sortBy : Int, completion: @escaping AuthCompletion){
        
            switch sortBy {
            case 0 :
                self.bidOrder(secId, price: price, quantity, completion)
            case 1 :
                self.askOrder(secId,price: price, quantity, completion)
            default :
                print("")
            }
    }
    
    private func setOrderBidStreams(userId : Int, secId : Int, price : Double, quantity : Int,  completion: @escaping AuthCompletion)->Observable<String>{
        return Observable<String>.create({ observer in
            
            let request = self.provider.request(.orderBid(userId: userId, secId: secId, price : price, quantity: quantity )){[weak self] result in
                
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
                    completion(error.localizedDescription)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func bidOrder(_ secId : Int, price : Double, _ quantity : Int,_ completion: @escaping AuthCompletion){
        if let userId = self.getProfile?.id {
            setOrderBidStreams(userId: userId, secId: secId, price: price, quantity: quantity, completion: completion)
                .subscribe(onNext: { message in
                    completion(message)
                }, onError: { error in
                    print(String(describing: error.localizedDescription))
                    completion(error.localizedDescription)
                }).disposed(by: disposeBag)
        }
    }
    
    
   
    private func setOrderAskStreams(userId : Int, secId : Int, price : Double, quantity : Int,  completion: @escaping AuthCompletion)->Observable<String>{
        return Observable<String>.create({ observer in
            
            let request = self.provider.request(.orderAsk(userId: userId, secId: secId, price : price, quantity: quantity )){[weak self] result in
                
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
                    completion(error.localizedDescription)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    func askOrder(_ secId : Int, price : Double, _ quantity : Int,_ completion: @escaping AuthCompletion){
        if let userId = self.getProfile?.id {
            setOrderAskStreams(userId: userId, secId: secId, price: price, quantity: quantity, completion: completion)
                .subscribe(onNext: { message in
                    completion(message)
                }, onError: { error in
                    print(String(describing: error.localizedDescription))
                    completion(error.localizedDescription)
                }).disposed(by: disposeBag)
        }
    }
    
    
}
