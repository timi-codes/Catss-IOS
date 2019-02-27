//
//  MarketViewController.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/17/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class MarketViewController: UIViewController{
    
    @IBOutlet weak var marketTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var rightHeaderLabel: UILabel!
    var refreshControl : UIRefreshControl!
    @IBOutlet weak var marketActivityIndicator: UIActivityIndicatorView!
    
    internal var marketModel : MarketViewModel?
    private let  searchController = UISearchController(searchResultsController: nil)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initMarketSecurities()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(initMarketSecurities), for: .valueChanged)
        
        marketTableView.refreshControl = refreshControl
        
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.keyboardType = UIKeyboardType.asciiCapable
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = Color.primaryColor
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.setDefaultNavigationBar()
        self.setupViews()
        
        marketModel?.isLoading.asDriver()
            .drive(onNext: {[unowned self] (isLoading) in
                if isLoading {
    self.marketActivityIndicator.startAnimating()
                } else {
                    self.marketActivityIndicator.stopAnimating()
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupViews(){
        let searchButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_search"), style: .plain, target: self, action: #selector(showUISearchController))
        self.tabBarController?.navigationItem.setRightBarButton(searchButtonItem, animated: true)
        setUpNavBarItem()
        
        marketTableView.register(UINib(nibName: "MarketViewCell", bundle: nil), forCellReuseIdentifier: MarketViewCell.Identifier)
    }
    
    @objc private func showUISearchController(){
        present(searchController, animated: true, completion: nil)
    }
    
    
    @objc private func initMarketSecurities(){
        marketModel = MarketViewModel(sortBy: segmentedControl.rx.selectedSegmentIndex.asDriver(), searchQuery: searchController.searchBar.rx.text.orEmpty.asDriver(), completion: { [unowned self](error) in
            guard let error = error else {return}
            self.showBanner(subtitle: error, style: .success)
        })
        
        searchController.searchBar.rx.text.orEmpty.asDriver().drive(onNext: { query in
            if query == "" {
                switch self.segmentedControl.selectedSegmentIndex {
                case 0 :
                    self.self.loadMarket()
                case 1:
                    self.self.loadWatchList()
                default:
                    return
                }
            }else{
                self.loadSearchResult()
            }
            print("search bar observer")
        }).disposed(by: disposeBag)
    }
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            self.loadMarket()
            rightHeaderLabel.text = "24h Chg%"
            
        } else if segmentedControl.selectedSegmentIndex == 1 {
            guard (marketModel?.getProfile) != nil else {
                segmentedControl.selectedSegmentIndex = 0
                let loginVC =  UIStoryboard().controllerFor(identifier: "LoginVC")
                present(loginVC, animated: true, completion: nil)
                return
            }
            
            self.loadWatchList()
            rightHeaderLabel.text = "No of Trades"
        }
    }
    
    
    //MARK :  - show market securities in tableview
    
    private func loadMarket(){
        
        self.marketTableView.delegate = nil
        self.marketTableView.dataSource = nil
        
        marketModel?.marketSecurity.asObservable()
            .filterNil()
            .bind(to:
                self.marketTableView
                    .rx
                    .items(cellIdentifier: MarketViewCell .Identifier,
                           cellType : MarketViewCell.self)){(row, element, cell) in
                            self.refreshControl.endRefreshing()
                            cell.configureMarketCell(with: element)
            }.disposed(by: self.disposeBag)
        
        marketTableView.rx.modelSelected(MarketSecurity.self)
            .subscribe(onNext: { [weak self] element in
                guard let `self` = self else{return}
                if self.segmentedControl.selectedSegmentIndex == 0 {
                    self.showBuySellDialog(element.securityName, element.id, element.newPrice)
                }
            }).disposed(by: disposeBag)
        
        self.didLongPressSecurity()
        
    }
    
    
    private func didLongPressSecurity(){
        
        marketTableView.rx.longPressGesture().when(.began)
            .subscribe(onNext: { recognizer in
                
                let point = recognizer.location(in: self.marketTableView)
                
                guard recognizer.state == .began,
                    let indexPath = self.marketTableView.indexPathForRow(at: point) else {return}
                
                switch self.segmentedControl.selectedSegmentIndex {
                case 0:
                    self.marketModel?.marketSecurity.asDriver()
                        .filterNil()
                        .drive(onNext:{ element in
                            print("Selected  MARKET at \(element[indexPath.row].id)")
                            if let userId = self.marketModel?.getProfile?.id {
                                
                                if recognizer.state == .began {
                                    self.createMarketActionAlertController(element[indexPath.row].securityName, userId, element[indexPath.row].id, element[indexPath.row].newPrice)
                                }
                            }
                        }).disposed(by: self.disposeBag)
                    break
                case 1:
                    self.marketModel?.watchlist.asDriver()
                        .filterNil()
                        .drive(onNext:{ element in
                            print("Selected  watclist at \(element[indexPath.row].id)")
                            if let userId = self.marketModel?.getProfile?.id {
                                if recognizer.state == .began {
                                    self.createWatchListActionAlertController(userId, element[indexPath.row].id)
                                }
                            }
                        }).disposed(by: self.disposeBag)
                    break
                default:
                    return
                }
                
            }).disposed(by: self.disposeBag)
    }
    
    
    //MARK :  - show watchlist in tableview
    private func loadWatchList(){
        
        self.marketTableView.delegate = nil
        self.marketTableView.dataSource = nil
        
        marketModel?.watchlist.asObservable()
            .filterNil()
            .bind(to:
                self.marketTableView.rx.items(cellIdentifier: MarketViewCell.Identifier,
                cellType : MarketViewCell.self)){(row, element, cell) in
                cell.configureMarketCell(with: element)
                self.refreshControl.endRefreshing()
            }.disposed(by: disposeBag)
    
    }
    
    private func loadSearchResult(){
        self.marketTableView.delegate = nil
        self.marketTableView.dataSource = nil
        
        self.marketModel?.searchResult.asObservable()
            .filterNil()
            .bind(to:
                self.marketTableView.rx.items(cellIdentifier: MarketViewCell.Identifier,
                    cellType:MarketViewCell.self)){(row, element, cell) in
                    cell.configureMarketCell(with: element)
            }.disposed(by: self.disposeBag)
    }
}
