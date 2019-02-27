//
//  WithdrawVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 2/26/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit


protocol WithdrawDialogDelegate{
    func didWithdraw(amount : Double)
}

class WithdrawDialogVC: UIViewController {

    @IBOutlet weak var amountTextField: BorderTextField!
    
    @IBOutlet weak var containerView: UIView!
    
    var delegate : WithdrawDialogDelegate?
    
    @IBOutlet weak var withdrawalActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var requestWithdrawBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        withdrawalActivityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.animateView()
    }
    
    @IBAction func onWithdrawPressed(_ sender: UIButton) {
        guard let amount = amountTextField.text, amount.count > 0 else {
            return
        }
        self.delegate?.didWithdraw(amount : amount.toDouble)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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

