//
//  MarketViewController+alertControllers.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/11/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import UIKit

extension MarketViewController : SetPriceDialogDelegate, BuySellDialogDelegate{

    func createMarketActionAlertController(_ name: String, _ userid: Int, _ secid: Int, _ price: Double?){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.definesPresentationContext = true
        
        let addToWatchlistAction = UIAlertAction(title: "Add to watchlist", style: .default) { (UIAlertAction) in
            self.marketModel?.addToWatchList(userId: userid, securityId: secid, completion: { message in
                guard let message = message else{
                    return
                }
                self.showBanner(subtitle: message, style: .warning)
            })
        }
        
        let setPriceAlertAction = UIAlertAction(title: "Set price alert", style: .default) { (UIAlertAction) in
            self.showPriceAlertDialog(name: name,  secid: secid,price: price)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addToWatchlistAction)
        alertController.addAction(setPriceAlertAction)
        alertController.addAction(cancelAction)
        
        if presentedViewController == nil {
            self.present(alertController, animated:true, completion:nil)
        }
        
    }
    
     func createWatchListActionAlertController(_ userid: Int, _ secid: Int){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeSecurityAction = UIAlertAction(title: "Remove from watchlist", style: .default) { (UIAlertAction) in
            self.marketModel?.removeFromWatchList(userId: userid, securityId: secid, completion: { message in
                guard let message = message else{
                    //hide progress
                    return
                }
                //hide progress
                self.showBanner(subtitle: message, style: .warning)
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(removeSecurityAction)
        
        if presentedViewController == nil {
            self.present(alertController, animated:true, completion:nil)
        }
        
    }
    
    
    func showPriceAlertDialog(name:String, secid: Int, price : Double?){
        let customAlert = UIStoryboard().dialogControllerFor(identifier: "SetPriceAlertDialog") as! SetPriceAlertVC
        
        customAlert.securityName = name
        customAlert.securityMarketPrice = price
        customAlert.currentSecurityId = secid
        customAlert.delegate = self
        
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = .overCurrentContext
        customAlert.modalTransitionStyle = .crossDissolve
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.present(customAlert, animated: true, completion: nil)
        }
    }
    
    
     func showBuySellDialog(_ name: String, _ secid: Int, _ price : Double?){
        let customAlert = UIStoryboard().dialogControllerFor(identifier: "BuySellDialog") as! BuySellDialogVC

        customAlert.securityName = name
        customAlert.securityMarketPrice = price
        customAlert.currentSecurityId = secid
        customAlert.delegate = self
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = .overCurrentContext
        customAlert.modalTransitionStyle = .crossDissolve
        
       DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
            self.present(customAlert, animated: true, completion: nil)
        }
    }
    
    func didSetPrice(secId: Int, price: Double) {
        marketModel?.setPriceAlert(secId: secId, price: price, completion: { message in
            guard let message = message else{
                //hide progress
                return
            }
            //hide progress
            self.showBanner(subtitle: message, style: .warning)
        })
    }
    
    func didSelectBuy(secId: Int, quantity: Int) {
        marketModel?.buyOrder(secId: secId, quantity: quantity, completion: { message in
            guard let message = message else {
                //hide progress
                return
            }
            //hide progress
            self.showBanner(subtitle: message, style: .warning)
        })
    }
    
    func didSelectSell(secId: Int, quantity: Int) {
        marketModel?.sellOrder(secId: secId, quantity: quantity, completion: { message in
            guard let message = message else{
                //hide progress
                return
            }
            //hide progress
            self.showBanner(subtitle: message, style: .warning)
        })
    }
    
}
