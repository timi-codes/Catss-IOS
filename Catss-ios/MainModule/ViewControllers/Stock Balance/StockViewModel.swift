//
//  StockViewModel.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/21/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RxCocoa
import RxSwift
import KeychainAccess

class StockViewModel {
    let provider = MoyaProvider<UserRequest>(plugins:[NetworkLoggerPlugin(verbose:true)])
    
    private let disposeBag = DisposeBag()
    typealias AuthCompletion = (_ error: String?)-> Void
    
    private var _accountBalance = BehaviorRelay<String?>(value: nil)
    
    private var _stockBalance = BehaviorRelay<[StockBalance]?>(value:nil)
    
    private var _stockRevaluation = BehaviorRelay<StockRevaluation?>(value:nil)
    
    private var _transactionLog = BehaviorRelay<[TransactionLog]?>(value:nil)
    
    private var _withdrawalLog = BehaviorRelay<[WithdrawLog]?>(value:nil)

    
    private var _isLoading = BehaviorRelay<Bool>(value: false)
    
    
    var isLoading: Driver<Bool> {return _isLoading.asDriver()}
    
    var getProfile: Profile? {
        guard let profile = UserKeychainAccess.getUserProfile() else{ return nil }
        return profile
    }
    
    private var _order = BehaviorRelay<AllOrder?>(value:nil)
    
    private var _openorder = BehaviorRelay<[Order]?>(value: nil)
    
    var openOrder: Driver<[Order]?> {
        return _openorder.asDriver()
    }
    
    var transactionLog: Driver<[TransactionLog]?> {
        return _transactionLog.asDriver()
    }
    
    var withdrawalLog: Driver<[WithdrawLog]?> {
        return _withdrawalLog.asDriver()
    }
    
    var accountBalance: Driver<String?> {
        return _accountBalance.asDriver()
    }
    
    var stockBalance: Driver<[StockBalance]?> {
        return _stockBalance.asDriver()
    }
    
    var stockRevaluation: Driver<StockRevaluation?> {
        return _stockRevaluation.asDriver()
    }
    
    init(){
        
    }
    
    init( userId: Int, completion: @escaping AuthCompletion) {
        
        fetchStockRecord(with: userId).subscribe({_ in
            print("fecth stock successfully")
        }).disposed(by: disposeBag)
    }
    
    private func fetchStockRecord(with id: Int)->Observable<String>{
        _isLoading.accept(true)
        return Observable.create({ (observer) -> Disposable in
            let request = self.provider.request(.getStockBalance(userId: id)){ [weak self] result in
                guard let `self` = self else {return}
               
                switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode(StockRecord.self, from: response.data)
                        self._accountBalance.accept(data.accountBalance)
                        self._stockBalance.accept(data.stockBalance)
                        self._stockRevaluation.accept(data.stockRevaluation)
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
    
     func fetchTransactionLog(){
        if let id = getProfile?.id {
            fetchTransactionLogStream(with: id).subscribe({_ in
                print("fetch transaction log successfully")
            }).disposed(by: disposeBag)
        }
      
    }
    
    
    private func fetchTransactionLogStream(with id: Int)->Observable<String>{
        self._isLoading.accept(true)
        return Observable.create({ (observer) -> Disposable in
            let request = self.provider.request(.getStockHistory(userId: id)){ [weak self] result in
                guard let `self` = self else {return}
                
                switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode([TransactionLog].self, from: response.data)
                        print(data)
                        self._transactionLog.accept(data)
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
    
    
    func fetchWithdrawalLog(){
        if let id = getProfile?.id {
            fetchWithdrawalLogStream(with: id).subscribe({_ in
                print("fetch withdrawal log successfully")
            }).disposed(by: disposeBag)
        }
        
    }
    
    
    private func fetchWithdrawalLogStream(with id: Int)->Observable<String>{
        self._isLoading.accept(true)
        return Observable.create({ (observer) -> Disposable in
            let request = self.provider.request(.getWithdrawalLog(userId: id)){ [weak self] result in
                guard let `self` = self else {return}
                
                switch result {
                case .success(let response):
                    do {
                        let data = try JSONDecoder().decode([WithdrawLog].self, from: response.data)
                        print(data)
                        self._withdrawalLog.accept(data)
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
    
}
