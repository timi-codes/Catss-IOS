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
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fingerPrintButton: UIButton!
    
    
    private var loginViewModel = OnBoardingViewModel()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fingerPrintButton.imageView?.imageColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        print(UserKeychainAccess.isFingerPrintEnabled())

        if UserKeychainAccess.isFingerPrintEnabled(){
            authenticateUserTouchID()
        }else{
            fingerPrintButton.isHidden = true
        }
        
        emailTextField.rx.controlEvent([.editingDidEndOnExit])
            .asDriver()
            .drive(onNext:{[unowned self] _ in
                self.passwordTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        passwordTextField.rx.controlEvent([.editingDidEndOnExit])
            .asDriver()
            .drive(onNext:{[unowned self] _ in
                self.passwordTextField.resignFirstResponder()
                //self.activeField = nil
            }).disposed(by: disposeBag)
        
        emailTextField.rx.text.map{$0 ?? ""}.bind(to: loginViewModel.email).disposed(by: disposeBag)
        
        passwordTextField.rx.text.map{$0 ?? ""}.bind(to: loginViewModel.password).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {

        loginUser(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func showFingerPrintDialog(_ sender: Any) {
        self.authenticateUserTouchID()
    }
    
    
    //MARK: - Signup user func
    private func loginUser(email:String, password:String){
        
        guard !email.isEmpty, !password.isEmpty else { return }

        let email = email
        let password = password
        
        self.showProgress(message: "Authenticating")
        
        let params = ["email": email, "password": password]
        
        loginViewModel.loginUser(params: params) { [unowned self] error in
            guard let error = error else {
                UserKeychainAccess.saveAccountDetailsToKeychain(account: email,password: password)
                self.hideProgress()
                self.dismiss(animated: true, completion: nil)
                return
            }
            self.hideProgress()
            self.showBanner(subtitle: error, style: .warning)
        }
    }
    
    private func authenticateUserTouchID(){
        
        guard let lastAccessedUserName = UserDefaults.standard.object(forKey: "lastAccessedUserName") as? String else { return }
        
        let context : LAContext = LAContext()
        // Declare a NSError variable.
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: lastAccessedUserName) { success, evaluateError in
                if success // IF TOUCH ID AUTHENTICATION IS SUCCESSFUL, NAVIGATE TO NEXT VIEW CONTROLLER
                {
                    DispatchQueue.main.async{
                        print("Authentication success by the system")
                        let storedPassword = UserKeychainAccess.loadPasswordFromKeychain(account: lastAccessedUserName);
                        
                        if let pass = storedPassword{
                            self.loginUser(email: lastAccessedUserName,password: pass )
                        }
                        
                    }
                }
                else // IF TOUCH ID AUTHENTICATION IS FAILED, PRINT ERROR MSG
                {
                    if let error = evaluateError as? LAError{
                        let message = self.showErrorMessageForLAErrorCode(errorCode: error.code.rawValue)
                        print(message)
                    }
                }
            }
        }
    }
    
    
    func showErrorMessageForLAErrorCode( errorCode:Int ) -> String{
        
        var message = ""
        
        switch errorCode {
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.biometryLockout.rawValue:
            message = "Too many failed attempts."
            
        case LAError.biometryNotAvailable.rawValue:
            message = "TouchID is not available on the device"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = "Did not find error code on LAError object"
            
        }
        
        return message
        
    }
}

