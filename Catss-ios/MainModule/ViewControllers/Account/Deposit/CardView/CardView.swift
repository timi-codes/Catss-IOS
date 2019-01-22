//
//  CardView.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/21/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import Paystack
import RxCocoa
import RxSwift

class CardView : UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var cardNumberTextField: BorderTextField!
    
    @IBOutlet weak var cvvNumberTextField: UITextField!
    
    @IBOutlet weak var expiryDateTextField: UITextField!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var errorLabelView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit(){
        Bundle.main.loadNibNamed("CardView", owner: self, options: nil)
        contentView.fixInView(self)
    }
}

