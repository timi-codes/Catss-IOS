//
//  SetPriceAlertVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/11/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit

protocol SetPriceDialogDelegate {
    func didSetPrice(secId: Int, price : Double)
}

class SetPriceAlertVC: UIViewController {

    @IBOutlet weak var securityNameLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    var delegate : SetPriceDialogDelegate?
    
    var securityName : String = ""
    var securityMarketPrice : Double?
    var currentSecurityId : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        securityNameLabel.text = securityName
        
        if let price = securityMarketPrice{
            priceTextField.text = String(format: "%.4f", price)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.animateView()
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
  
    @IBAction func decrementButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func incrementButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func setPriceButtonTapped(_ sender: UIButton) {
        guard let price = priceTextField.text, price.count > 0 else {
            return
        }
        self.delegate?.didSetPrice(secId: currentSecurityId!, price: price.toDouble)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func animateView(){
        containerView.alpha = 0
        self.containerView.frame.origin.y =
            self.containerView.frame.origin.y + 50
        
        UIView.animate(withDuration: 0.4){
            self.containerView.alpha = 1
            self.containerView.frame.origin.y =
                self.containerView.frame.origin.y - 50
        }
    }
    
}
