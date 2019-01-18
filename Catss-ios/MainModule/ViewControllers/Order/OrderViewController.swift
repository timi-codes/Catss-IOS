//
//  OrderViewController.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/6/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OrderViewController: UIViewController , PickSecurityDelegate {
    
    @IBOutlet weak var buyOrSellSegmentControl: UISegmentedControl!
    @IBOutlet weak var priceTextField: BorderTextField!
    @IBOutlet weak var quantityTextField: BorderTextField!
    @IBOutlet weak var totalTextField: BorderTextField!
    @IBOutlet weak var recentOrderTableView: UITableView!
    @IBOutlet weak var askBidButton: UIButton!
    
    
    private let disposeBag = DisposeBag()
    private var orderViewModel : OrderViewModel?
    
    
    private var selectedSecId : Int?
    
    private lazy var titleView : UIButton = {
        let button =  UIButton(type: .custom)
        
        let myImage = #imageLiteral(resourceName: "arrow_drop_down")
        button.setImage(myImage, for: UIControlState.normal)
        
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 160, bottom: 0, right: 0)
        button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        
        button.titleLabel?.textColor = .white
        button.setTitle("SELECT A SECURITY", for: .normal)
        button.titleLabel?.font = UIFont.setFont(of: 13)
        
        button.addTarget(self, action: #selector(self.selectSecurity), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //askBidButton.titleLabel?.sizeToFit()

//        askBidButton.titleLabel?.minimumScaleFactor = 1
//        askBidButton.titleLabel?.numberOfLines = 2
//        askBidButton.titleLabel?.adjustsFontSizeToFitWidth = true

        buyOrSellSegmentControl.rx.selectedSegmentIndex
            .asDriver().drive(onNext:{
                [weak self] type in
                guard let `self` = self else{return}
               
                switch type {
                case 0:
                    self.askBidButton.backgroundColor = Color.successColor
                    self.askBidButton.setTitle("BUY", for: .normal)
                    break
                case 1:
                    self.askBidButton.backgroundColor = Color.warningColor
                    self.askBidButton.setTitle("SELL", for: .normal)
                    break
                default:
                    return
                }
            }).disposed(by: disposeBag)
        
        Driver.combineLatest(priceTextField.rx.text.asDriver(), quantityTextField.rx.text.asDriver()){
            price, quantity in
                self.priceTextField.text!.toDouble * self.quantityTextField.text!.toDouble
            }.drive(onNext:{ total in
                let totalInString = String(format: "%.4f%", total)
                self.totalTextField.text = totalInString.nairaEquivalent
            }).disposed(by: disposeBag)
        
        recentOrderTableView.register(UINib(nibName: "OpenOrderCell", bundle: nil), forCellReuseIdentifier: OpenOrderCell.Indentifier)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setDefaultNavigationBar()
        self.setupViews()
        initOpenorder()
    }
    
    private func setupViews(){
        self.tabBarController?.navigationItem.titleView = titleView
        self.tabBarController?.navigationItem.titleView?.isHidden = false
        setUpNavBarItem()

    }
    
    @objc func selectSecurity(){
        let searchVC = PickSecurityVC()
        searchVC.delegate = self
        //searchVC.hidesBottomBarWhenPushed = true
        let backButton = UIBarButtonItem()
        backButton.title = " "
        backButton.tintColor = .white
        navigationItem.backBarButtonItem = backButton
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func openOrderButtonPressed(_ sender: UIButton) {
        let openOrderVC = UIStoryboard().controllerFor(identifier: "OpenOrderVC")
        openOrderVC.hidesBottomBarWhenPushed = true
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = .white
        navigationItem.backBarButtonItem = backButton
        self.navigationController?.pushViewController(openOrderVC, animated: true)
    }
    
    @IBAction func askBidOrderPressed(_ sender: UIButton) {
        if let price = priceTextField.text, price.count > 0, let quantity = quantityTextField.text, quantity.count > 0, let secid = selectedSecId{
            orderViewModel?.bidAskOrder(secId: secid, price: price.toDouble, quantity: Int(quantity)!, sortBy: (buyOrSellSegmentControl?.selectedSegmentIndex)!) { error  in
                guard let error = error else {
                    return
                }
                self.showBanner(subtitle: error, style: .success)
                self.recentOrderTableView.reloadData()
            }
        }
    }
    
    func didPickSecurity(name: String, secId: Int, price: Double) {
        titleView.setTitle(name, for: .normal)
        priceTextField.text = String(format: "%.4f%", price)
        quantityTextField.text = "1"
        selectedSecId = secId
    }
    
    private func initOpenorder(){
        
        orderViewModel = OrderViewModel(completion: { [unowned self](error) in
            guard let error = error else {return}
            self.showBanner(subtitle: error, style: .danger)
        })
        
        self.recentOrderTableView.delegate = nil
        self.recentOrderTableView.dataSource = nil
        
        orderViewModel?.openOrder.asObservable()
            .filterNil()
            .bind(to: self.recentOrderTableView
                .rx
                .items(cellIdentifier: OpenOrderCell.Indentifier, cellType: OpenOrderCell.self)){ (row, element, cell) in
                    cell.configureOpenOrder(with: element)
            }.disposed(by:self.disposeBag)
    }
}
