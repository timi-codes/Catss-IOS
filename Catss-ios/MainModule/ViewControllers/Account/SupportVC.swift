//
//  SupportVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/17/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit

class SupportVC: UIViewController {

    @IBOutlet weak var subjectTextField: BorderTextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    private lazy var titleView : UILabel = {
        let label =  UILabel()
        label.text = "Support"
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
    
        let callButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_action_call"), style: .done, target: self, action: #selector(callButtonPressed))
        
        navigationItem.setRightBarButton(callButtonItem, animated: true)
    }
    
    
    @objc private func callButtonPressed(){
        guard let url = URL(string: "tel://\(+2349067354599)") else {
            return
        }
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
    }
    
    @IBAction func passwordBtnPressed(_ sender: Any) {
        if let subject = subjectTextField.text,subject.count>0, let message = messageTextView.text, message.count>0{
            
            accountViewModel.sendSupportMessage(subject: subject, message: message) { [unowned self] error in
                if let error = error {
                    self.showBanner(subtitle: error, style: .success)
                }
            }
        }
        
    }
}
