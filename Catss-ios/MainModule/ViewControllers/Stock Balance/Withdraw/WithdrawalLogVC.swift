//
//  WithdrawalLogVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 2/26/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class WithdrawLogVC : UIViewController {
    
    var refreshControl : UIRefreshControl!
    
    private let loginModel = OnBoardingViewModel()
    private var stockModel = StockViewModel()
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var withdrawLogTableView: UITableView!
    
    private lazy var titleView : UILabel = {
        let label =  UILabel()
        label.text = "Withdrawal Log"
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
        withdrawLogTableView.refreshControl = refreshControl
        
        withdrawLogTableView.register(UINib(nibName: "WithdrawalLogCell", bundle: nil), forCellReuseIdentifier: WithdrawalLogCell.Indentifier)
        
        initWithdrawalLog()
        
        
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
        initWithdrawalLog()
    }
    
    private func initWithdrawalLog(){
        
        self.withdrawLogTableView.delegate = nil
        self.withdrawLogTableView.dataSource = nil
        
        stockModel.fetchWithdrawalLog()
        
        stockModel.withdrawalLog.asObservable()
            .filterNil()
            .bind(to: self.withdrawLogTableView
                .rx
                .items(cellIdentifier: WithdrawalLogCell.Indentifier, cellType: WithdrawalLogCell.self)){ (row, element, cell) in
                    cell.configureWithdrawLog(with: element)
                    self.refreshControl.endRefreshing()
            }.disposed(by:self.disposeBag)
        
}

}
