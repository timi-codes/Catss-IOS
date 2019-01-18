//
//  SecurityVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/17/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit

class SecurityVC: UIViewController {

    @IBOutlet weak var oldPasswordTextField: BorderTextField!
    
    @IBOutlet weak var newPasswordTextField: BorderTextField!
    
    private let accountViewModel = AccountViewModel()

    private lazy var titleView : UILabel = {
        let label =  UILabel()
        label.text = "Reset Password"
        label.textColor = .white
            
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = titleView
        let backButton = UIBarButtonItem()
        backButton.title = " "
        backButton.tintColor = .white
        self.navigationItem.backBarButtonItem = backButton
    }
    
    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        if let oldPassword = oldPasswordTextField.text,oldPassword.count>0, let newPassword = newPasswordTextField.text, newPassword.count>0{
            
            accountViewModel.resetPassword(oldPassword: oldPassword, newPassword: newPassword) { [unowned self] error in
                if let error = error {
                    self.showBanner(subtitle: error, style: .success)
                }
            }
        }
    }
    
}
