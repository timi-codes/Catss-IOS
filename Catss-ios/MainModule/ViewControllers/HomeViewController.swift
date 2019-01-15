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

class HomeViewController : UIViewController {
    
    @IBOutlet weak var rankingTableView: UITableView!
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var stockIndexCollectionView: UICollectionView!
    
    var homeViewModel : HomeViewModel!
    let disposeBag = DisposeBag()
    
    var currentNewsScrollPosition = 0
    var currentStockIndexPosition = 0
    
    override func viewWillAppear(_ animated: Bool) {
        setDefaultNavigationBar()
    }
    
    override func viewDidLoad() {
        homeViewModel = HomeViewModel(completion: { [unowned self](error) in
            guard let error = error else {return}
            self.showBanner(subtitle: error, style: .danger)
        })
        setDefaultNavigationBar()
        setUpNavBarItem()
        setupRankCellConfiguration(with: homeViewModel)
        setupNewsCellConfiguration(with: homeViewModel)
        setupStockIndexCellConfiguration(with: homeViewModel)
        //notifyScrollStart()
    }
    
    private func setupRankCellConfiguration(with viewModel: HomeViewModel) {
        viewModel.rankedUsers.asObservable()
            .filterNil()
            .bind(to: self.rankingTableView.rx.items(cellIdentifier: RankingCell.Identifier, cellType: RankingCell.self)) { (row, element, cell) in
                cell.configureRankCell(index: row, rankUser: element)
            }
            .disposed(by: disposeBag)
    }
    
    
    private func setupNewsCellConfiguration(with viewModel:HomeViewModel) {
        
        newsCollectionView.register(UINib(nibName: "NewsCell", bundle: nil), forCellWithReuseIdentifier: NewsCell.Identifier)
        
        viewModel.newsList.asObservable()
            .filterNil()
            .bind(to: self.newsCollectionView.rx.items(cellIdentifier: NewsCell.Identifier, cellType: NewsCell.self)){
                (row, element, cell) in
                cell.configureNewsCollectionView(newsItem: element)
            }.disposed(by: disposeBag)
        
        //SELECTION MODEL
        newsCollectionView.rx.modelSelected(FinancialNews.self).subscribe(onNext: { news in
            if let url = news.linkToNews {
                UIApplication.shared.open(url, options: [:])
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupStockIndexCellConfiguration(with viewModel:HomeViewModel) {
        stockIndexCollectionView.register(UINib(nibName: "StockIndexCell", bundle: nil), forCellWithReuseIdentifier: StockIndexCell.Indentifier)
        
        viewModel.stockIndexList.asObservable()
            .filterNil()
            .bind(to: self.stockIndexCollectionView.rx.items(cellIdentifier: StockIndexCell.Indentifier, cellType: StockIndexCell.self)){
                (row, element, cell) in
                cell.configureStockindexCollectionView(with : element)
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
}
