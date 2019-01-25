//
//  AccountViewController.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/6/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KeychainAccess
import RxGesture
import Paystack

class AccountViewController: UIViewController {
    
    @IBOutlet weak var actionTileView: UIView!
    @IBOutlet weak var onBoardView: UIView!
    @IBOutlet weak var emailAddressLable: UILabel!
    private let loginModel = OnBoardingViewModel()
    private let accountModel = AccountViewModel()
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var settingsUIView: UIView!
    @IBOutlet weak var supportUIView: UIView!
    @IBOutlet weak var securityUIView: UIView!
    @IBOutlet weak var depositUIView: UIView!
    
    lazy var paymentLauncher: PaystackPaymentLauncher = {
        let launcher = PaystackPaymentLauncher()
        return launcher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpActionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setDefaultNavigationBar()
        loginModel.isUserLoggedIn.subscribe(onNext:{ [unowned self] loggedIn in
            if loggedIn {
                self.setupViews()
                self.actionTileView.isHidden = false
                self.onBoardView.isHidden = true
            }else{
                self.actionTileView.isHidden = true
                self.onBoardView.isHidden = false
            }
        }).disposed(by: disposeBag)
        
        if let profile = loginModel.getProfile {
            emailAddressLable.text = profile.email
        }
    }
    
    private func setupViews(){
        let logoutButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logoutUser))
        self.tabBarController?.navigationItem.setRightBarButton(logoutButtonItem, animated: true)
                setUpNavBarItem()
    }
    
    private func setUpActionView(){
        supportUIView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ _ in
                let supportVC = UIStoryboard().controllerFor(identifier: "SupportVC")
                supportVC.hidesBottomBarWhenPushed = true
//                let backButton = UIBarButtonItem()
//                backButton.title = ""
//                backButton.tintColor = .white
//                self.navigationItem.leftBarButtonItem = backButton
                self.navigationController?.pushViewController(supportVC, animated: true)
            }).disposed(by: disposeBag)
        
        securityUIView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ _ in
                let securityVC = UIStoryboard().controllerFor(identifier: "SecurityVC")
                securityVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(securityVC, animated: true)
            }).disposed(by: disposeBag)
        
        depositUIView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ _ in
                self.paymentLauncher.currentVC = self
                self.paymentLauncher.setUpViews()
            }).disposed(by: disposeBag)
        
        
        settingsUIView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ _ in
                let settingsVC = UIStoryboard().controllerFor(identifier: "SettingsVC")
                settingsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(settingsVC, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    @objc private func logoutUser(){
        
        let alertVC = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            UserKeychainAccess.removeProfile()
            self.actionTileView.isHidden = true
            self.onBoardView.isHidden = false
            self.setDefaultNavigationBar()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
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
    
    func handlePaymentWithPaystack(cardParams: PSTCKCardParams, completed: @escaping () -> ()){
        accountModel.processPayment(cardParams: cardParams, vc: self) { error in
            if let error = error {
                self.showBanner(subtitle: error, style: .success)
                completed()
            }
        }
    }
}
