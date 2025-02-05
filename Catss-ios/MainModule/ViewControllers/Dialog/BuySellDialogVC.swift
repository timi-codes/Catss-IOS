//
//  BuySellDialogVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/11/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


protocol BuySellDialogDelegate {
    func didSelectBuy(secId : Int, quantity : Int)
    func didSelectSell(secId : Int, quantity : Int)

}
class BuySellDialogVC: UIViewController {
    
    var delegate : BuySellDialogDelegate?

    @IBOutlet weak var securityNameLabel: UILabel!
    
    @IBOutlet weak var marketPriceTextField: UITextField!
    
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var totalAmountTextField: UITextField!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var buySellActivityIndicator: UIActivityIndicatorView!
    
    
    var securityName : String = ""
    var securityMarketPrice : Double?
    var currentSecurityId: Int?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        securityNameLabel.text = securityName
        
        if let price = securityMarketPrice{
            marketPriceTextField.text = String(format: "%.4f", price)
        }
        
        buySellActivityIndicator.stopAnimating()
        
        Driver.combineLatest(marketPriceTextField.rx.text.asDriver(), quantityTextField.rx.text.asDriver()){
            price, quantity in
            self.marketPriceTextField.text!.toDouble * self.quantityTextField.text!.toDouble
            }.drive(onNext:{ total in
                let totalInString = String(format: "%.4f%", total)
                self.totalAmountTextField.text = totalInString.nairaEquivalent
            }).disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.animateView()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sellButtonTapped(_ sender: UIButton) {
        guard let quantity = quantityTextField.text, quantity.count > 0 else {
            return
        }
        delegate?.didSelectSell(secId: currentSecurityId!,quantity: Int(quantity)!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buyButtonTapped(_ sender: UIButton) {
        guard let quantity = quantityTextField.text, quantity.count > 0 else {
            return
        }
        delegate?.didSelectBuy(secId: currentSecurityId!,quantity: Int(quantity)!)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func incrementTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func decrementTapped(_ sender: UIButton) {
        
    }
    
    private func animateView(){
        containerView.alpha = 0
        self.containerView.frame.origin.y = self.containerView.frame.origin.y + 50
        
        UIView.animate(withDuration: 0.4){
            self.containerView.alpha = 1
            self.containerView.frame.origin.y = self.containerView.frame.origin.y + 50
        }
    }
}
