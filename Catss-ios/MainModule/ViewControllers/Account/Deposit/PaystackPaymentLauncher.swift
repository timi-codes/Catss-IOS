//
//  PaystackPaymentLaucher.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/21/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import UIKit
import Paystack
import Stripe
import RxSwift
import RxCocoa

class PaystackPaymentLauncher: NSObject{
    
    var accountVC : AccountViewController?
    let cardView = CardView()
    let summaryView = SummaryView()
    private let expiryDateTextFieldDelegate = ExpiryDateTextDelegate()
    private let cardNumberTextFieldDelegate = CardNumberTextFieldDelegate()

    
    let blackView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6732930223)
        view.alpha = 0
        return view
    }()
    
    let cardParams = PSTCKCardParams.init()
    
    let disposeBag = DisposeBag()

    
    func setUpViews(){
        if let window  = UIApplication.shared.keyWindow {
            blackView.frame = window.frame

            window.addSubview(blackView)
            window.addSubview(cardView)
            
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 3
            cardView.clipsToBounds = true
            
            cardView.translatesAutoresizingMaskIntoConstraints = false

            cardView.leftAnchor.constraint(equalTo: window.leftAnchor, constant: 20).isActive = true
            cardView.rightAnchor.constraint(equalTo: window.rightAnchor, constant: -20).isActive = true
            cardView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            cardView.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: -20).isActive = true
            cardView.heightAnchor.isEqual(550)
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1

            }, completion: nil)
            
            cardView.errorLabelView.isHidden = true
            self.cardView.expiryDateTextField.delegate = self.expiryDateTextFieldDelegate
            self.cardView.cardNumberTextField.delegate = self.cardNumberTextFieldDelegate
            
            Observable.combineLatest(cardView.expiryDateTextField.rx.controlEvent([.editingDidBegin]), cardView.cvvNumberTextField.rx.controlEvent([.editingDidBegin]), cardView.cardNumberTextField.rx.controlEvent([.editingDidBegin]))
                .asObservable()
                .subscribe({_ in
                    self.cardView.errorLabelView.isHidden = true
                    }).disposed(by: disposeBag)

            
            cardView.dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
            
             cardView.nextButton.addTarget(self, action: #selector(nextSummary), for: .touchUpInside)
            
        }
    }
    
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            self.blackView.removeFromSuperview()
            self.cardView.removeFromSuperview()
        }) { (completed: Bool) in
        }
    }
    
    @objc func nextSummary(){
        
        if let expiryDate = cardView.expiryDateTextField.text, let cardNumber = cardView.cardNumberTextField.text, let cvvCode = cardView.cvvNumberTextField.text {
            
            cardParams.number = cardNumber
            cardParams.cvc = cvvCode
            
            var dateArray = expiryDate.components(separatedBy: "/")
            if dateArray.count == 2 {
                cardParams.expMonth = UInt(dateArray[0])!
                cardParams.expYear = UInt(dateArray[1])!
                summaryView.expiryLabel.text = expiryDate
            }
            summaryView.cardNumberLabel.text = "**** \(cardNumber.suffix(4))"
            
            let numberValidity = STPCardValidator.validationState(forNumber: cardParams.number, validatingCardBrand: true)
            
            let cvcValidity = STPCardValidator.validationState(forCVC: cardParams.cvc ?? "", cardBrand: STPCardValidator.brand(forNumber: cardParams.number ?? ""))
            
            let expMonthValidity = STPCardValidator.validationState(forExpirationMonth: String(cardParams.expMonth ))
            
            let expYearValidity = STPCardValidator.validationState(forExpirationYear: String(cardParams.expYear ), inMonth: String(cardParams.expMonth ))
            
            if numberValidity == .valid, cvcValidity == .valid, expMonthValidity == .valid, expYearValidity == .valid  {
                showSummary()
            }else{
                cardView.errorLabelView.isHidden = false
            }
        }
        
    }
    
    private func showSummary(){
        self.cardView.removeFromSuperview()

        if let window  = UIApplication.shared.keyWindow {
            window.addSubview(summaryView)
            summaryView.backgroundColor = .white

            summaryView.backgroundColor = .white
            summaryView.layer.cornerRadius = 3
            summaryView.clipsToBounds = true
            summaryView.translatesAutoresizingMaskIntoConstraints = false
            
            summaryView.activityIndicatorView.isHidden = true
            
            summaryView.leftAnchor.constraint(equalTo: window.leftAnchor, constant: 20).isActive = true
            summaryView.rightAnchor.constraint(equalTo: window.rightAnchor, constant: -20).isActive = true
            summaryView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            summaryView.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: -20).isActive = true
            
            showCardBrand()
            
            summaryView.dismissButton.addTarget(self, action: #selector(handleSummaryDismiss), for: .touchUpInside)
            
            summaryView.backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
            
            summaryView.chargeCardButton.addTarget(self, action: #selector(handlePayment), for: .touchUpInside)
        }
    }
    
    private func showCardBrand(){
        if let number = cardParams.number {
            let cardBrand = STPCardValidator.brand(forNumber: number)
            let cardImage = STPImageLibrary.brandImage(for: cardBrand)
            summaryView.logoImageView.image = cardImage
        }
   
    }
    
    @objc func handleSummaryDismiss(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            self.blackView.removeFromSuperview()
            self.summaryView.removeFromSuperview()
        }) { (completed: Bool) in
        }
    }
    
    @objc func backPressed(){
        self.summaryView.removeFromSuperview()
        if let window  = UIApplication.shared.keyWindow {
            window.addSubview(cardView)
           
        cardView.translatesAutoresizingMaskIntoConstraints = false
            cardView.leftAnchor.constraint(equalTo: window.leftAnchor, constant: 20).isActive = true
            cardView.rightAnchor.constraint(equalTo: window.rightAnchor, constant: -20).isActive = true
            cardView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            cardView.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: -20).isActive = true
            cardView.heightAnchor.isEqual(550)
            
        }
    }
    
    @objc func handlePayment(){
        summaryView.chargeCardButton.titleLabel?.text = ""
        summaryView.chargeCardButton.isEnabled = false
        summaryView.activityIndicatorView.isHidden = false
        summaryView.backButton.isEnabled = false
        accountVC?.handlePaymentWithPaystack(cardParams: cardParams, completed: {
            self.summaryView.chargeCardButton.isEnabled = true
            self.summaryView.backButton.isEnabled = true
            self.cardView.cardNumberTextField.text = ""
            self.cardView.cvvNumberTextField.text = ""
            self.cardView.expiryDateTextField.text = ""
            self.handleSummaryDismiss()
        })
    }
}
