//
//  HomeViewController.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/13/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift
import RxOptional
import RxCocoa
import Paystack

class HomeViewController : UIViewController {
    
    @IBOutlet weak var homeScrollView: UIScrollView!
    @IBOutlet weak var rankingTableView: UITableView!
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var stockIndexCollectionView: UICollectionView!
    @IBOutlet weak var newsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stockIndexActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rankingActivityIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var supportButton: UIView!
    @IBOutlet weak var depositButton: UIView!
    @IBOutlet weak var withdrawButton: UIView!
    
    lazy var paymentLauncher: PaystackPaymentLauncher = {
        let launcher = PaystackPaymentLauncher()
        return launcher
    }()
    
    var homeViewModel : HomeViewModel!
    var accountModel =  AccountViewModel()

    let disposeBag = DisposeBag()
    
    var currentNewsScrollPosition = 0
    var currentStockIndexPosition = 0
    
    //MARK : - View State
    private var state: State = .loading("all") {
        didSet {
            switch state {
            case .ready(let item):
                readyState(item)
            case .loading(let item):
                loadingState(item)
            case .error:
                errorState()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setDefaultNavigationBar()
    }
    
    override func viewDidLoad() {
        state = .loading("all")
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        homeScrollView.refreshControl = refreshControl
        
        self.reloadData()
        self.cTAButton()
    }
    
    
    @objc func reloadData(){
        
        
        homeViewModel = HomeViewModel(completion: { [unowned self](error) in
            guard let error = error else {return}
            self.showBanner(subtitle: error, style: .warning)
        })
        setDefaultNavigationBar()
        setUpNavBarItem()
        setupRankCellConfiguration(with: homeViewModel)
        setupNewsCellConfiguration(with: homeViewModel)
        setupStockIndexCellConfiguration(with: homeViewModel)
    }
    
    
    private func cTAButton(){
        depositButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ _ in
                if let _ = self.homeViewModel.getProfile?.id {
                    self.paymentLauncher.currentVC = self
                    self.paymentLauncher.setUpViews()
                }else{
                    let loginVC = UIStoryboard().controllerFor(identifier: "LoginVC")
                    self.present(loginVC, animated: true, completion: nil)
                }
            }).disposed(by: disposeBag)
        
        
        supportButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ _ in
                if let _ = self.homeViewModel.getProfile?.id {
                    let supportVC = UIStoryboard().controllerFor(identifier: "SupportVC")
                    supportVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(supportVC, animated: true)
                }else{
                    let loginVC = UIStoryboard().controllerFor(identifier: "LoginVC")
                    self.present(loginVC, animated: true, completion: nil)
                }
            }).disposed(by: disposeBag)
    }
    
    private func setupRankCellConfiguration(with viewModel: HomeViewModel) {
        self.state = .loading("ranking")
        
        rankingTableView.delegate = nil
        rankingTableView.dataSource = nil

        viewModel.rankedUsers.asObservable()
            .filterNil()
            .bind(to: self.rankingTableView.rx.items(cellIdentifier: RankingCell.Identifier, cellType: RankingCell.self)) { (row, element, cell) in
                cell.configureRankCell(index: row, rankUser: element)
                self.state = .ready("ranking")
            }
            .disposed(by: disposeBag)
    }
    
    
    private func setupNewsCellConfiguration(with viewModel:HomeViewModel) {
        self.state = .loading("news")
        
        newsCollectionView.delegate = nil
        newsCollectionView.dataSource = nil
        
        newsCollectionView.register(UINib(nibName: "NewsCell", bundle: nil), forCellWithReuseIdentifier: NewsCell.Identifier)
        
        viewModel.newsList.asObservable()
            .filterNil()
            .bind(to: self.newsCollectionView.rx.items(cellIdentifier: NewsCell.Identifier, cellType: NewsCell.self)){
                (row, element, cell) in
                cell.configureNewsCollectionView(newsItem: element)
                self.state = .ready("news")

            }.disposed(by: disposeBag)
        
        //SELECTION MODEL
        newsCollectionView.rx.modelSelected(FinancialNews.self).subscribe(onNext: { news in
            if let url = news.linkToNews {
                UIApplication.shared.open(url, options: [:])
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupStockIndexCellConfiguration(with viewModel:HomeViewModel) {
        self.state = .loading("stock")
        
        stockIndexCollectionView.delegate = nil
        stockIndexCollectionView.dataSource = nil
        
        stockIndexCollectionView.register(UINib(nibName: "StockIndexCell", bundle: nil), forCellWithReuseIdentifier: StockIndexCell.Indentifier)
        
        viewModel.stockIndexList.asObservable()
            .filterNil()
            .bind(to: self.stockIndexCollectionView.rx.items(cellIdentifier: StockIndexCell.Indentifier, cellType: StockIndexCell.self)){
                (row, element, cell) in
                cell.configureStockindexCollectionView(with : element)
                self.state = .ready("stock")
            }.disposed(by: disposeBag)
    }
    
    
    private func notifyScrollStart(){
        Driver.combineLatest(homeViewModel.newsList.asDriver(),homeViewModel.stockIndexList.asDriver()).drive(onNext:{ [unowned self ] newsData,stockIndexData in
            if let news = newsData{
                if news.count > 0{
                    DispatchQueue.main.async {
                        let _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.autoScrollNews), userInfo: nil, repeats: true)
                    }
                }
            }
            
            if let stockIndex = stockIndexData {
                if stockIndex.count > 0{
                    DispatchQueue.main.async {
                        let _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.autoScrollStockIndex), userInfo: nil, repeats: true)
                    }
                }
            }
            
        }).disposed(by: disposeBag)
    }
    
    @objc func autoScrollNews() {
        if self.currentNewsScrollPosition < self.homeViewModel.newsCount {
            let indexPath = IndexPath(item: currentNewsScrollPosition, section: 0)
            self.newsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.newsCollectionView.setNeedsDisplay()
            self.currentNewsScrollPosition = self.currentNewsScrollPosition + 1
        } else {
            self.currentNewsScrollPosition = 0
            self.newsCollectionView.scrollToItem(at: IndexPath(item: currentNewsScrollPosition, section: 0), at: .centeredHorizontally, animated: true)
            self.newsCollectionView.setNeedsDisplay()
        }
    }
    
    @objc func autoScrollStockIndex() {
        if self.currentStockIndexPosition < self.homeViewModel.newsCount {
            let indexPath = IndexPath(item: currentStockIndexPosition, section: 0)
            self.stockIndexCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.stockIndexCollectionView.setNeedsDisplay()
            self.currentStockIndexPosition = self.currentStockIndexPosition + 1
        } else {
            self.currentStockIndexPosition = 0
            self.stockIndexCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func handlePaymentWithPaystack(cardParams: PSTCKCardParams, completed: @escaping () -> ()){
        accountModel.processPayment(cardParams: cardParams, vc: self) { error in
            if let error = error {
                self.showBanner(subtitle: error, style: .warning)
                completed()
            }
        }
    }
}


extension HomeViewController {
    enum State {
        case loading(_ item : String)
        case ready(_ item : String)
        case error
    }
    
    private func readyState(_ item : String){
        switch item {
        case "news":
            newsActivityIndicator.stopAnimating()
            newsCollectionView.isHidden = false
        case "stock":
            stockIndexActivityIndicator.stopAnimating()
            stockIndexCollectionView.isHidden = false
        case "ranking":
            rankingActivityIndicator.stopAnimating()
            rankingTableView.isHidden = false
            self.refreshControl.endRefreshing()
        default :
            return
        }
    }
    
    private func loadingState(_ item : String){
        switch item {
        case "news" :
            newsActivityIndicator.startAnimating()
        case "stock":
            stockIndexActivityIndicator.startAnimating()
        case "ranking":
            rankingActivityIndicator.startAnimating()
            rankingTableView.isHidden = true
        case "all":
            return
        default :
            return
        }
    }
    
    private func errorState(){
//        switch currentLoadingViewIndex {
//        case 0:
//            newsActivityIndicator.startAnimating()
//            newsCollectionView.isHidden = true
//        case 1:
//            stockIndexActivityIndicator.startAnimating()
//            stockIndexCollectionView.isHidden = true
//        case 2:
//            rankingActivityIndicator.startAnimating()
//            rankingTableView.isHidden = true
//        default :
//            return
//        }
    }
}

