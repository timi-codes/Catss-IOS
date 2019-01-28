//
//  ViewController.swift
//  Catss-ios
//
//  Created by Tejumola David on 11/9/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var activeField: UITextField?
    
    private var loginViewModel = OnBoardingViewModel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.rx.controlEvent(.editingDidBegin)
            .asDriver()
            .drive(onNext:{[unowned self] _ in
                self.activeField = self.emailTextField
            }).disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent(.editingDidBegin)
            .asDriver()
            .drive(onNext:{[unowned self] _ in
                self.activeField = self.passwordTextField
            }).disposed(by: disposeBag)
        
        emailTextField.rx.controlEvent([.editingDidEndOnExit])
            .asDriver()
            .drive(onNext:{[unowned self] _ in
                self.passwordTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        passwordTextField.rx.controlEvent([.editingDidEndOnExit])
            .asDriver()
            .drive(onNext:{[unowned self] _ in
                self.passwordTextField.resignFirstResponder()
                self.activeField = nil
            }).disposed(by: disposeBag)
        
        emailTextField.rx.text.map{$0 ?? ""}.bind(to: loginViewModel.email).disposed(by: disposeBag)
        
        passwordTextField.rx.text.map{$0 ?? ""}.bind(to: loginViewModel.password).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add touch gesture for contentView
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.bind(onNext:{
            [unowned self] recogniser in
            
            if let activeField = self.activeField {
                activeField.resignFirstResponder()
                self.activeField = nil
            }
        }).disposed(by: disposeBag)
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
            loginUser()
    }
    
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: - Signup user func
    private func loginUser(){
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        self.showProgress(message: "Authenticating")
        
        let params = ["email": email, "password": password]
        
        loginViewModel.loginUser(params: params) { [unowned self] error in
            guard let error = error else {
                self.hideProgress()
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.hideProgress()
            self.showBanner(subtitle: error, style: .warning)
        }
    }
}

