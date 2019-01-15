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
    
    private let disposeBag = DisposeBag()
    
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setDefaultNavigationBar()
        self.setupViews()
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
        
    }
    
    func didPickSecurity(name: String, secId: Int, price: Double) {
        titleView.setTitle(name, for: .normal)
        priceTextField.text = String(format: "%.4f%", price)
        quantityTextField.text = "1"
    }
    

}
