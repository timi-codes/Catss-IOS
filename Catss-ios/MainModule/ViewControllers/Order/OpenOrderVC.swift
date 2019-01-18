//
//  OpenOrderVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/16/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class OpenOrderVC: UIViewController {

    var refreshControl : UIRefreshControl!
    
    private var orderViewModel : OrderViewModel?
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var openOrderTableView: UITableView!
    
    private lazy var titleView : UILabel = {
        let label =  UILabel()
        label.text = "Open Orders"
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
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        openOrderTableView.refreshControl = refreshControl

openOrderTableView.register(UINib(nibName: "OpenOrderCell", bundle: nil), forCellReuseIdentifier: OpenOrderCell.Indentifier)
        
        initOpenorder()
    }

    @objc fileprivate func refresh(){
        
    }
    
    private func initOpenorder(){
       
        orderViewModel = OrderViewModel(completion: { [unowned self](error) in
                guard let error = error else {return}
                self.showBanner(subtitle: error, style: .danger)
            })

        
        
        self.openOrderTableView.delegate = nil
        self.openOrderTableView.dataSource = nil
        
        orderViewModel?.openOrder.asObservable()
        .filterNil()
        .bind(to: self.openOrderTableView
        .rx
            .items(cellIdentifier: OpenOrderCell.Indentifier, cellType: OpenOrderCell.self)){ (row, element, cell) in
                cell.configureOpenOrder(with: element)
        }.disposed(by:self.disposeBag)
        
    }
}
