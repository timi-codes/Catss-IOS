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

class MarketViewController: UIViewController {
    
    @IBOutlet weak var marketTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var rightHeaderLabel: UILabel!
    
    
    private var marketModel : MarketViewModel?
    private let  searchController = UISearchController(searchResultsController: nil)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initMarketSecurities()
        
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.keyboardType = UIKeyboardType.asciiCapable
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = Color.primaryColor
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        setDefaultNavigationBar()
        self.setupViews()
    }
    
    private func setupViews(){
        let searchButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_search"), style: .plain, target: self, action: #selector(showUISearchController))
        self.tabBarController?.navigationItem.setRightBarButton(searchButtonItem, animated: true)
        setUpNavBarItem()
    }
    
    @objc private func showUISearchController(){
        present(searchController, animated: true, completion: nil)
    }
    
    private func initMarketSecurities(){
        marketModel = MarketViewModel(sortBy: segmentedControl.rx.selectedSegmentIndex.asDriver(), searchQuery: searchController.searchBar.rx.text.orEmpty.asDriver(), completion: { [unowned self](error) in
            guard let error = error else {return}
            self.showBanner(subtitle: error, style: .danger)
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
    
    
    private func loadMarket(){
        
        self.marketTableView.delegate = nil
        self.marketTableView.dataSource = nil
        
        marketModel?.marketSecurity.asObservable()
            .filterNil()
            .bind(to:
                self.marketTableView.rx.items(cellIdentifier: MarketViewCell.Identifier,
                                              cellType : MarketViewCell.self)){(row, element, cell) in
                                                cell.configureMarketCell(with: element)
                                                
            }.disposed(by: disposeBag)
    }
    
    
    private func loadWatchList(){
        
        self.marketTableView.delegate = nil
        self.marketTableView.dataSource = nil
        
        marketModel?.watchlist.asObservable()
            .filterNil()
            .bind(to:
                self.marketTableView.rx.items(cellIdentifier: MarketViewCell.Identifier,
                                              cellType : MarketViewCell.self)){(row, element, cell) in
                                                cell.configureMarketCell(with: element)
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
