//
//  HomeViewModel.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/13/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxCocoa
import Moya



class HomeViewModel {
    
    let provider = MoyaProvider<HomeRequest>()
    
    private let disposeBag = DisposeBag()
    
    typealias AuthCompletion = (_ error: String?)-> Void
    
    private var ranking = BehaviorRelay<Ranking?>(value: nil)
    private var _rankedUsers = BehaviorRelay<[Rank]?>(value: [])
    
    private var news = BehaviorRelay<[FinancialNews]?>(value: nil)
    
    private var stockIndex = BehaviorRelay<[StockIndex]?>(value: nil)


    var rankedUsers : Driver<[Rank]?> {
        return _rankedUsers.asDriver()
    }
    
    var newsList : Driver<[FinancialNews]?> {
        return news.asDriver()
    }
    
    var stockIndexList : Driver<[StockIndex]?> {
        return stockIndex.asDriver()
    }
    
    var newsCount: Int {
        guard let result = news.value else {
            return 0
        }
        return result.count
    }
    
    var stockIndexCount: Int {
        guard let result = stockIndex.value else {
            return 0
        }
        return result.count
    }
    
    
    func itemForRow(index: Int) -> Rank? {
        guard let result = _rankedUsers.value else{
            return nil
        }
        return result[index]
    }
    
    
    var getProfile: Profile? {
        guard let profile = UserKeychainAccess.getUserProfile() else{ return nil }
        return profile
    }
    
     init(completion: @escaping AuthCompletion) {
        
        let combineRequest = Observable.zip(fetchNews(),fetchRanking(), fetchStockIndex()){
            return ($0, $1, $2)
        }
        
        combineRequest.subscribe(onNext: { element in
            completion(element.0)
        }, onError: { error in
            print(String(describing: error.localizedDescription))
            completion(error.localizedDescription)
        }).disposed(by: disposeBag)
        
        
        //fetchNews().subscribe(ObserverType)
        
    }
    
    
    //MARK: Fetch Ranking
    private func fetchRanking()->Observable<String>{
        return Observable<String>.create({ observer -> Disposable in
            let request = self.provider.request(.ranking) { [weak self] result in
                guard let `self` = self else {return}
                switch result {
            
                case .success(let response):
                    do {

                        let data = try JSONDecoder().decode(Ranking.self, from: response.data)
                        
                        let errorData = try JSONDecoder().decode(RankingError.self, from: response.data)
                        
                        if let message = errorData.message {
                            observer.onNext(message)
                        }else{
                            self.ranking.accept(data)
                            let sortedRank = data.ranking.sorted(by: {$0.pAndL > $1.pAndL})
                            self._rankedUsers.accept(sortedRank)
                        }
                        observer.onCompleted()
            
                    } catch let err {
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
    
    
    //MARK: Fetch News
    private func fetchNews()->Observable<String>{
        return Observable<String>.create({ observer -> Disposable in
            let request = self.provider.request(.news) { [weak self] result in
                guard let `self` = self else {return}
                switch result {
                    
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode([FinancialNews].self, from: response.data)
                    
                            self.news.accept(data)
                        observer.onCompleted()

                    } catch let err {
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
    
    
    //MARK: Fetch Stock Index
    private func fetchStockIndex()->Observable<String>{
        return Observable<String>.create({ observer -> Disposable in
            let request = self.provider.request(.priceTicker) { [weak self] result in
                guard let `self` = self else {return}
                switch result {
                    
                case .success(let response):
                    do {
                       // print(try response.mapJSON())
                        
                        let data = try JSONDecoder().decode([StockIndex].self, from: response.data)
                        
//                        let errorData = try JSONDecoder().decode(StockIndexError.self, from: response.data)
//
//                        if let message = errorData.message {
//                            observer.onNext(message)
//                        }else{
                            self.stockIndex.accept(data)
                        //}
                        observer.onCompleted()
                        
                    } catch let err {
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
