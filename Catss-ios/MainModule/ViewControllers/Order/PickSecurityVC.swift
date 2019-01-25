//
//  PickSecurityVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/15/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture


protocol PickSecurityDelegate {
    func didPickSecurity(name: String, secId: Int, price: Double)
}
class PickSecurityVC: UIViewController {
    
    var delegate : PickSecurityDelegate?
    
    private var marketModel : MarketViewModel?
    private let disposeBag = DisposeBag()
    
    var refreshControl : UIRefreshControl!
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate lazy var tableView : UITableView  = {
        let tv = UITableView(frame: self.view.bounds)
        tv.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tv.backgroundColor = .clear
        tv.separatorColor = #colorLiteral(red: 0.6705882353, green: 0.6705882353, blue: 0.6705882353, alpha: 0.1)
        tv.setContentOffset(CGPoint(x: -50, y: -50), animated: true)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coverView = UIView(frame: view.bounds)
        coverView.backgroundColor = #colorLiteral(red: 0.07450980392, green: 0.1176470588, blue: 0.1294117647, alpha: 1)
        
        view.addSubview(coverView)
        view.sendSubviewToBack(coverView)
        
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search a security"
        self.searchController.searchBar.barStyle = .blackOpaque
        self.definesPresentationContext = true
        
        self.navigationItem.titleView = searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        activityIndicator.widthAnchor.isEqual(40)
        activityIndicator.heightAnchor.isEqual(40)
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.register(UINib(nibName: "MarketViewCell", bundle: nil), forCellReuseIdentifier: MarketViewCell.Identifier)
        
        initMarketSecurity()
        
        marketModel?.isLoading.asDriver()
            .drive(onNext: {[unowned self] (isLoading) in
                if isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }).disposed(by: disposeBag)
        
    }
    
    @objc fileprivate func refresh(){
        initMarketSecurity()
    }
    
    private func initMarketSecurity(){
        marketModel = MarketViewModel(searchQuery: searchController.searchBar.rx.text.orEmpty.asDriver(), completion: { error in
            
        })
        loadMarket()
        
        searchController.searchBar.rx.text.orEmpty.asDriver().drive(onNext: { query in
            if query == "" {
                self.loadMarket()
            }else{
                self.loadSearchResult()
            }
            print("search bar observer")
        }).disposed(by: disposeBag)
    }
    
    
    private func loadSearchResult(){
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        self.marketModel?.searchResult.asObservable()
            .filterNil()
            .bind(to:
                self.tableView.rx.items(cellIdentifier: MarketViewCell.Identifier,
                                        cellType:MarketViewCell.self)){(row, element, cell) in
                                            cell.configureMarketCell(with: element)
            }.disposed(by: self.disposeBag)
    }
    
    private func loadMarket(){
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        marketModel?.marketSecurity.asObservable()
            .filterNil()
            .bind(to:
                self.tableView
                    .rx
                    .items(cellIdentifier: MarketViewCell .Identifier,
                           cellType : MarketViewCell.self)){(row, element, cell) in
                            cell.configureMarketCell(with: element)
                            self.refreshControl.endRefreshing()
            }.disposed(by: self.disposeBag)
        
        
        
        tableView.rx.modelSelected(MarketSecurity.self).subscribe(onNext: { security in
            self.delegate?.didPickSecurity(name: security.securityName, secId: security.id, price: security.newPrice!)
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        
    }
}
