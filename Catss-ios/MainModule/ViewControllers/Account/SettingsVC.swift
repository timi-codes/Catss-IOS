//
//  SettingVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/17/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
class SettingsVC: UIViewController {
    
    @IBOutlet weak var editSettingsButton: UIButton!
    @IBOutlet weak var userNameTextField: BorderTextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var accountNumberTextField: UITextField!
    
    @IBOutlet weak var bankTextField: UITextField!
    
    //@IBOutlet weak var dropDown: UIButton!

    
    enum DefaulState: String {
        case placeholder = "Select Bank Name"
        case none
    }
    
    var wasEdited = false
    
    private let authenticateView = AuthenticateView()
    
    let blackView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6732930223)
        view.alpha = 0
        return view
    }()
    
    
    @IBAction func onEditClicked(_ sender: BorderTextField) {
        bankTextField.isEnabled = false
        
    }
    private lazy var titleView : UILabel = {
        let label =  UILabel()
        label.text = "Settings"
        label.textColor = .white
        
        return label
    }()
    
    private let accountViewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = titleView
        let backButton = UIBarButtonItem()
        backButton.title = " "
        backButton.tintColor = .white
        self.navigationItem.backBarButtonItem = backButton
        setUpView()
    }
    
    private func setUpView(){
        if let profile = accountViewModel.getProfile{
            userNameTextField.text = profile.name
            phoneNumberTextField.text =  profile.phone
            zipTextField.text = profile.zip_code
            addressTextField.text = profile.address
        }
        
        self.editSettingsButton.backgroundColor = Color.accentColor
        self.editSettingsButton.imageView?.image = #imageLiteral(resourceName: "edit")
        
    }
    
    private func setUpAuthenticateView(){
        if let window = UIApplication.shared.keyWindow {
            blackView.frame = window.frame
            
            window.addSubview(blackView)
            window.addSubview(authenticateView)
            
            authenticateView.backgroundColor = .white
            authenticateView.layer.cornerRadius = 3
            authenticateView.clipsToBounds = true
            
            authenticateView.activityIndicatorView.isHidden = true
            
            authenticateView.translatesAutoresizingMaskIntoConstraints = false
            
            authenticateView.leftAnchor.constraint(equalTo: window.leftAnchor, constant: 20).isActive = true
            authenticateView.rightAnchor.constraint(equalTo: window.rightAnchor, constant: -20).isActive = true
            authenticateView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            authenticateView.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: -20).isActive = true
            authenticateView.heightAnchor.isEqual(550)
            
            authenticateView.dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
            
            authenticateView.authenticateButton.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
            }, completion: nil)
            
        }
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            self.blackView.removeFromSuperview()
            self.authenticateView.removeFromSuperview()
        }) { (completed: Bool) in
        }
    }
    
    @objc func authenticate(){
        if let password = authenticateView.passwordTextField.text{
            authenticateView.authenticateButton.isEnabled = false
            authenticateView.passwordTextField.isEnabled = false
            authenticateView.activityIndicatorView.isHidden = false
            accountViewModel.authenticate(password: password) { [unowned self] status in
                
                self.authenticateView.authenticateButton.isEnabled = true
                self.authenticateView.passwordTextField.isEnabled = true
                self.authenticateView.activityIndicatorView.isHidden = true
                self.authenticateView.passwordTextField.text = ""
                
                switch status {
                case "success" :
                    self.userNameTextField.isEnabled = true
                    self.phoneNumberTextField.isEnabled =  true
                    self.zipTextField.isEnabled = true
                    self.addressTextField.isEnabled = true
                    self.bankTextField.isEnabled = true
                    self.accountNumberTextField.isEnabled = true
                    
                    self.bankTextField.setRightViewFAIcon(icon:.FACaretDown, rightViewMode: .always, textColor: .white, backgroundColor: .clear, size: CGSize(width: 25, height: 25))
                    self.userNameTextField.addLayer(.bottom).addPadding(.left)
                    self.phoneNumberTextField.addLayer(.bottom).addPadding(.left)
                    self.zipTextField.addLayer(.bottom).addPadding(.left)
                    self.addressTextField.addLayer(.bottom).addPadding(.left)
                    self.accountNumberTextField.addLayer(.bottom).addPadding(.left)
                    self.bankTextField.addLayer(.bottom).addPadding(.left)
                    self.wasEdited = true
                    self.editSettingsButton.backgroundColor = Color.successColor
                    self.editSettingsButton.imageView?.image = #imageLiteral(resourceName: "done")
                    self.handleDismiss()
                case "error":
                    self.showBanner(subtitle: "Invalid password", style: .warning)
                case .none:
                    return
                case .some(_):
                    return
                }
            }
            
        }
    }
    
    @IBAction func editDoneButtonTapped(_ sender: UIButton) {
        
        if wasEdited {
            
            if let phone = phoneNumberTextField.text, phone.isNotEmpty, let address = addressTextField.text, address.isNotEmpty{
                
                accountViewModel.updateUserProfile(phone: Int(phone)!, address: address, state: "Lagos"){ [unowned self] message in
                    if let message = message {
                        
                        self.showBanner(subtitle: message, style: .warning)
                        self.userNameTextField.removeLayer()
                        self.phoneNumberTextField.removeLayer()
                        self.zipTextField.removeLayer()
                        self.addressTextField.removeLayer()
                        
                        self.userNameTextField.isEnabled = false
                        self.phoneNumberTextField.isEnabled =  false
                        self.zipTextField.isEnabled = false
                        self.addressTextField.isEnabled = false
                        self.accountNumberTextField.isEnabled = false
                        self.bankTextField.isEnabled = false
                        
                    self.bankTextField.setRightViewFAIcon(icon:.FANone, rightViewMode: .always, textColor: .white, backgroundColor: .clear, size: nil)

                        
                        self.editSettingsButton.backgroundColor = Color.accentColor
                        self.editSettingsButton.imageView?.image = #imageLiteral(resourceName: "edit")
                        
                        self.wasEdited = false
                    }
                }
                
            }else{
                self.showBanner(subtitle: "Field cannot the empty", style: .warning)
                                        self.editSettingsButton.backgroundColor = Color.successColor
                                        self.editSettingsButton.imageView?.image = #imageLiteral(resourceName: "done")
            }
            
        }else{
            setUpAuthenticateView()
        }
        
    }
    
}
