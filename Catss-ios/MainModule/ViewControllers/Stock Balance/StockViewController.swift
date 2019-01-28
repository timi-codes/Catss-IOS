//
//  StockViewController.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/6/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class StockViewController: UIViewController{
    
    @IBOutlet weak var onBoardView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var pAndL: UILabel!
    @IBOutlet weak var pOrLable: UILabel!
    @IBOutlet weak var stockTableView: UITableView!
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var stockActivityIndicator: UIActivityIndicatorView!
    
    private let loginModel = OnBoardingViewModel()
    private var stockModel : StockViewModel?
    private let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        loginModel.isUserLoggedIn.subscribe(onNext:{ [unowned self] loggedIn in
            if loggedIn {
                self.initUserStockRecord()
                self.loadingindicatorSetup()
            }
        }).disposed(by: disposeBag)
    }
    
    func loadingindicatorSetup(){
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        stockModel?.isLoading.asDriver()
            .drive(onNext: {[unowned self] (isLoading) in
                if isLoading {
                    self.stockActivityIndicator.startAnimating()
                } else {
                    self.stockActivityIndicator.stopAnimating()
                }
            }).disposed(by: disposeBag)
    }
    
    @objc func reloadData(){
        initUserStockRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDefaultNavigationBar()
        
        loginModel.isUserLoggedIn.subscribe(onNext:{ [unowned self] loggedIn in
            if loggedIn {
                self.setupViews()
                self.onBoardView.isHidden = true
                self.scrollView.isHidden = false
            }else{
                self.onBoardView.isHidden = false
                self.scrollView.isHidden = true
                self.setDefaultNavigationBar()
            }
        }).disposed(by: disposeBag)
    }
    
    private func initUserStockRecord(){
        
        if let profile = loginModel.getProfile {
            
            self.stockTableView.delegate = nil
            self.stockTableView.dataSource = nil
            
            stockModel = StockViewModel(userId: profile.id!, completion: { [unowned self](error) in
                guard let error = error else {return}
                self.showBanner(subtitle: error, style: .warning)
            })

            stockModel?.accountBalance.drive(onNext:{ [unowned self]
                balance in
                self.balanceLabel.text = balance?.nairaEquivalent
                if self.refreshControl != nil {
                    self.refreshControl.endRefreshing()
                }
            }).disposed(by: disposeBag)
            
            stockModel?.stockRevaluation.drive(onNext:{
                [unowned self] stock in
                self.pAndL.text =  stock?.bal.toString().nairaEquivalent
                self.pOrLable.text = stock?.tag.uppercased()
            }).disposed(by: disposeBag)
            
            stockModel?.stockBalance.asObservable()
                .filterNil()
                .bind(to: self.stockTableView.rx.items(cellIdentifier: StockCell.Identifier, cellType: StockCell.self)) { (row, element, cell) in
                    cell.configureStockBalanceCell(stockBalance: element)
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func setupViews(){
        let logoutButtonItem = UIBarButtonItem(title: "Transaction log", style: .done, target: self, action: #selector(logoutUser))
        self.tabBarController?.navigationItem.setRightBarButton(logoutButtonItem, animated: true)
        setUpNavBarItem()
    }
    
    
    @objc private func logoutUser(){
        print("logout clicked")
    }
    
    @IBAction func onAuthenticateUser(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let signUpVC = UIStoryboard().controllerFor(identifier: "SignUpVC")
            present(signUpVC, animated: true, completion: nil)
            break;
        case 2:
            let loginVC = UIStoryboard().controllerFor(identifier: "LoginVC")
            present(loginVC, animated: true, completion: nil)
            break;
        default:
            return
        }
    }
}
