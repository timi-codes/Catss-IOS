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

class AccountViewController: UIViewController {
    
    @IBOutlet weak var actionTileView: UIView!
    @IBOutlet weak var onBoardView: UIView!
    @IBOutlet weak var emailAddressLable: UILabel!
    private let loginModel = OnBoardingViewModel()
    private let disposeBag = DisposeBag()
    
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
}
