//
//  MarketViewModel.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/7/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RxCocoa
import RxSwift
import KeychainAccess

class MarketViewModel {
    
    let provider = MoyaProvider<MarketRequest>(plugins:[NetworkLoggerPlugin(verbose:true)])
    
    private let disposeBag = DisposeBag()
    typealias AuthCompletion = (_ error: String?)-> Void
    
    private var _marketSecurity = BehaviorRelay<[MarketSecurity]?>(value:nil)
    
    private var _watchlist = BehaviorRelay<[MarketSecurity]?>(value: nil)
    
    private var _searchResult = BehaviorRelay<[MarketSecurity]?>(value: nil)
    
    
    var getProfile: Profile? {
        guard let profile = UserKeychainAccess.getUserProfile() else{ return nil }
        return profile
    }
    
    var marketSecurity: Driver<[MarketSecurity]?> {
        return _marketSecurity.asDriver()
    }
    
    var watchlist: Driver<[MarketSecurity]?> {
        return _watchlist.asDriver()
    }
    
    var searchResult : Driver<[MarketSecurity]?>{
        return _searchResult.asDriver()
    }
    
    var currentSortBy = 0
    /**
     * 0 - Market
     * 1 - Watchlist
     **/
    init(sortBy : Driver<Int>, searchQuery : Driver<String>, completion: @escaping AuthCompletion) {
        
        sortBy.drive(onNext: { [weak self] type in
            guard let `self` = self else{return}
            self.currentSortBy = type
            switch type {
            case 0 :
                self.fetchMarketSecurity().subscribe({_ in
                    print("fetch market security successfully")
                }).disposed(by: self.disposeBag)
            case 1 :
                if let userId = self.getProfile?.id {
                    self.fetchWatchList(userid: userId).subscribe({_ in
                        print("fetch watchlist successfully")
                    }).disposed(by: self.disposeBag)
                }
            default :
                print("")
            }
        }).disposed(by: disposeBag)
        
        searchStream(searchQuery)
        
    }
    
    
    init(searchQuery : Driver<String>, completion: @escaping AuthCompletion) {
        self.fetchMarketSecurity().subscribe({_ in
            print("fetch market security successfully")
        }).disposed(by: self.disposeBag)
        
        searchStream(searchQuery)
    }
    
    private func searchStream(_ searchQuery : Driver<String>){
        
        searchQuery.drive(onNext:{ [weak self] query in
        guard let `self` = self else {return}
    
            let _result = self._marketSecurity.value.map{
    $0.filter{$0.securityName.lowercased().contains(query.lowercased())}
        }
        self._searchResult.accept(_result)
        }).disposed(by: disposeBag)
    }
    
    private func fetchMarketSecurity()->Observable<String>{
        return Observable.create({ (observer) -> Disposable in
            let request = self.provider.request(.loadSecurities()){ [weak self] result in
                guard let `self` = self else {return}
                
                switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode([MarketSecurity].self, from: response.data)
                        self._marketSecurity.accept(data)
                        observer.onCompleted()
                        
                        print(data)
                        
                    }catch let err {
                        print(String(describing: err.localizedDescription))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            return Disposables.create{
                request.cancel()
                
            }
        })
    }
    
    private func fetchWatchList(userid: Int)->Observable<String>{
        return Observable.create({ (observer) -> Disposable in
            let request = self.provider.request(.loadWatchlist(userId:userid)){ [weak self] result in
                guard let `self` = self else {return}
                
                switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode([MarketSecurity].self, from: response.data)
                        self._watchlist.accept(data)
                        observer.onCompleted()
                        
                        print(data)
                        
                    }catch let err {
                        print(String(describing: err.localizedDescription))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            return Disposables.create{
                request.cancel()
                
            }
        })
    }
    
    private func removeFromWatchListStreams(userid: Int, secid: Int, completion: @escaping AuthCompletion)->Observable<String>{
        return Observable<String>.create({ observer  in

             let request = self.provider.request(.removeWatchlist(userId: userid, secId: secid)) {[weak self] result in
                guard `self` != nil else{return}
                switch result {
                case .success(let response):
                    do {
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
    
    func removeFromWatchList(userId: Int, securityId: Int, completion: @escaping AuthCompletion) {
        removeFromWatchListStreams(userid: userId, secid: securityId, completion: completion)
            .subscribe(onNext: { message in
                completion(message)
            }, onError: { error in
                print(String(describing: error.localizedDescription))
                completion(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    
    private func addToWatchListStreams(userid: Int, secid: Int, completion: @escaping AuthCompletion)->Observable<String>{
        return Observable<String>.create({ observer  in
            
            let request = self.provider.request(.addToWatchlist(userId: userid, secId: secid)) {[weak self] result in
                guard `self` != nil else{return}
                switch result {
                case .success(let response):
                    do {
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
    
    func addToWatchList(userId: Int, securityId: Int, completion: @escaping AuthCompletion) {
        addToWatchListStreams(userid: userId, secid: securityId, completion: completion)
            .subscribe(onNext: { message in
                completion(message)
            }, onError: { error in
                print(String(describing: error.localizedDescription))
                completion(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    
    private func setPriceAlertStreams(userid: Int, secid: Int,price: Double, completion: @escaping AuthCompletion)->Observable<String>{
        return Observable<String>.create({ observer  in
            
            let request = self.provider.request(.setPriceAlert(userId: userid, secId: secid, price: price)) {[weak self] result in
                guard `self` != nil else{return}
                switch result {
                case .success(let response):
                    do {
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
    
    
    func setPriceAlert(secId: Int, price: Double, completion: @escaping AuthCompletion) {
        
        if let userId = self.getProfile?.id {
            setPriceAlertStreams(userid: userId, secid: secId, price: price, completion: completion)
                .subscribe(onNext: { message in
                    completion(message)
                }, onError: { error in
                    print(String(describing: error.localizedDescription))
                    completion(error.localizedDescription)
                }).disposed(by: disposeBag)
        }
    }
    
    private func setMarketOrderBuyStreams(userId : Int, quantity : Int, secId : Int, completion: @escaping AuthCompletion)->Observable<String>{
        return Observable<String>.create({ observer in
            
            let request = self.provider.request(.marketBuy(userId: userId, total: quantity, secId: secId)){[weak self] result in
                
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
    
    func buyOrder(secId: Int, quantity: Int, completion: @escaping AuthCompletion){
        if let userId = self.getProfile?.id {
            setMarketOrderBuyStreams(userId: userId, quantity: quantity, secId: secId, completion: completion)
            .subscribe(onNext: { message in
                                completion(message)
                            }, onError: { error in
                                print(String(describing: error.localizedDescription))
                                completion(error.localizedDescription)
                            }).disposed(by: disposeBag)
        }
    }
    
    
    private func setMarketOrderSellStreams(userId : Int, quantity : Int, secId : Int, completion: @escaping AuthCompletion)->Observable<String>{
        return Observable<String>.create({ observer in
            
            let request = self.provider.request(.marketSell(userId: userId, total: quantity, secId: secId)){[weak self] result in
                
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
    
    func sellOrder(secId: Int, quantity: Int, completion: @escaping AuthCompletion){
        if let userId = self.getProfile?.id {
            setMarketOrderSellStreams(userId: userId, quantity: quantity, secId: secId, completion: completion)
                .subscribe(onNext: { message in
                    completion(message)
                }, onError: { error in
                    print(String(describing: error.localizedDescription))
                    completion(error.localizedDescription)
                }).disposed(by: disposeBag)
        }
    }
}
