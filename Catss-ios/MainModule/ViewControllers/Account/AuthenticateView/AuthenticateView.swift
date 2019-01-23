//
//  AuthenticateView.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/23/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit

class AuthenticateView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var passwordTextField: BorderTextField!
    @IBOutlet weak var authenticateButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("AuthenticateView", owner: self, options: nil)
        contentView.fixInView(self)
    }
}
