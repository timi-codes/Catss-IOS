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
        
        
        searchQuery.drive(onNext:{ [weak self] query in
            guard let `self` = self else {return}
            
            var _result : [MarketSecurity]?
            
            switch self.currentSortBy  {
            case 0:
                _result = self._marketSecurity.value.map{
                    $0.filter{$0.securityName.lowercased().contains(query.lowercased())}
                }
            case 1 :
                _result = self._watchlist.value.map{
                    $0.filter{$0.securityName.lowercased().contains(query.lowercased())}
                }
            default:
                return
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
}
