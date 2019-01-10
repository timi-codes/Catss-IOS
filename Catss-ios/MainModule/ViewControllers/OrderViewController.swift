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

class OrderViewController: UIViewController {
    
    @IBOutlet weak var onBoardView: UIView!
    
    private let loginModel = OnBoardingViewModel()
    private let disposeBag = DisposeBag()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setDefaultNavigationBar()
        
        loginModel.isUserLoggedIn.subscribe(onNext:{ [unowned self] loggedIn in
            if loggedIn {
                self.setupViews()
                self.onBoardView.isHidden = true
                
            }else{
                self.onBoardView.isHidden = false
                self.setDefaultNavigationBar()
            }
        }).disposed(by: disposeBag)
    }
    
    
    private func setupViews(){
        
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
