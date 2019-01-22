//
//  SummaryView.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/21/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import Paystack

class SummaryView : UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var expiryLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var chargeCardButton: UIButton!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    
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
        Bundle.main.loadNibNamed("SummaryView", owner: self, options: nil)
        contentView.fixInView(self)
    }
}
