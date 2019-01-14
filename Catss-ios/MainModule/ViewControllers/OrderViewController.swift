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
    
    private let loginModel = OnBoardingViewModel()
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
        setDefaultNavigationBar()
        setupViews()

    }
    
    private func setupViews(){
        self.tabBarController?.navigationItem.titleView = titleView
        self.tabBarController?.navigationItem.titleView?.isHidden = false
        setUpNavBarItem()
    }
    
    @objc func selectSecurity(){
        print("select button clicked")
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
