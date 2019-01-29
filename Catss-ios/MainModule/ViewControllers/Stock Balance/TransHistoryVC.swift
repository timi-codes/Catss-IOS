//
//  TransHistoryVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/29/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TransHistoryVC: UIViewController {
    
    var refreshControl : UIRefreshControl!
    
    private let loginModel = OnBoardingViewModel()
    private var stockModel = StockViewModel()
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var stockTableView: UITableView!
    
    private lazy var titleView : UILabel = {
        let label =  UILabel()
        label.text = "Transaction Log"
        label.textColor = .white
        
        return label
    }()
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = titleView
        
        view.addSubview(activityIndicator)
        
        activityIndicator.widthAnchor.isEqual(40)
        activityIndicator.heightAnchor.isEqual(40)
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        stockTableView.refreshControl = refreshControl
        
        stockTableView.register(UINib(nibName: "OpenOrderCell", bundle: nil), forCellReuseIdentifier: OpenOrderCell.Indentifier)
        
        initStockHistory()
        
        
        stockModel.isLoading.asDriver()
            .drive(onNext: {[unowned self] (isLoading) in
                if isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }).disposed(by: disposeBag)
        
        
    }
    
    @objc fileprivate func refresh(){
        initStockHistory()
    }
    
    private func initStockHistory(){
        
            stockModel.fetchTransactionLog()
            
            self.stockTableView.delegate = nil
            self.stockTableView.dataSource = nil
            
            stockModel.openOrder.asObservable()
                .filterNil()
                .bind(to: self.stockTableView
                    .rx
                    .items(cellIdentifier: OpenOrderCell.Indentifier, cellType: OpenOrderCell.self)){ (row, element, cell) in
                        cell.configureOpenOrder(with: element)
                        self.refreshControl.endRefreshing()
                }.disposed(by:self.disposeBag)

        }
        
    
}
