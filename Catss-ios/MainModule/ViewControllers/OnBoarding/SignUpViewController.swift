//
//  SignUpViewController.swift
//  Catss-ios
//
//  Created by Tejumola David on 11/22/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import EGFormValidator
import RxSwift
import RxCocoa

class SignUpViewController: ValidatorViewController {
    
    @IBOutlet weak var userNameTextField: BorderTextField!
    
    @IBOutlet weak var emailTextField: BorderTextField!
    
    @IBOutlet weak var phoneTextField: BorderTextField!
    
    @IBOutlet weak var passwordTextField: BorderTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    var activeField: UITextField?
    
    var lastOffset: CGPoint!
    
    var keyboardHeight: CGFloat!
    
    private var signUpModel = OnBoardingViewModel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = userNameTextField.rx.text.map{$0 ?? ""}.bind(to: signUpModel.name)
        _ = emailTextField.rx.text.map{$0 ?? ""}.bind(to: signUpModel.email)
        _ = phoneTextField.rx.text.map{$0 ?? ""}.bind(to: signUpModel.phone)
        _ = passwordTextField.rx.text.map{$0 ?? ""}.bind(to: signUpModel.password)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    //MARK: - SignupButtonPressed
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        signUpModel.isValid.subscribe(onNext:{ [unowned self]
            valid in
            valid ? self.signUpUser() :  self.showBanner(subtitle: "All input field are required", style: .danger)
        }).disposed(by: disposeBag)
    }
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    //MARK: - Empty all text field
    private func emptyTextField(){
        userNameTextField.text = ""
        emailTextField.text = ""
        phoneTextField.text = ""
        passwordTextField.text = ""
    }
    
    //MARK: - Signup user func
    private func signUpUser(){
        
        let name = userNameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let phone = phoneTextField.text!
        
        self.showProgress(message: "Authenticating")
        
        let signUpParams = ["name": name, "email": email, "password": password, "phone": phone]
        
        signUpModel.registerUser(userDetailParams: signUpParams){ [unowned self] error in
            guard let error = error else {
                self.hideProgress()
                self.emptyTextField()
                self.showBanner(subtitle: "Account was created successfully!", style: .success)
                return
            }
            self.hideProgress()
            self.showBanner(subtitle: error, style: .danger)
        }
    }
}

// MARK: UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}

