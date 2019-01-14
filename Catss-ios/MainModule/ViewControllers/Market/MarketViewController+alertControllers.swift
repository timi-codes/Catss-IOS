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
        
        let addToWatchlistAction = UIAlertAction(title: "Add to watchlist", style: .default) { (UIAlertAction) in
            self.marketModel?.addToWatchList(userId: userid, securityId: secid, completion: { message in
                guard let message = message else{
                    return
                }
                self.showBanner(subtitle: message, style: .success)
            })
        }
        
        let setPriceAlertAction = UIAlertAction(title: "Set price alert", style: .default) { (UIAlertAction) in
            self.showPriceAlertDialog(name: name,  secid: secid,price: price)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addToWatchlistAction)
        alertController.addAction(setPriceAlertAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated:true, completion:nil)
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
                self.showBanner(subtitle: message, style: .danger)
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(removeSecurityAction)
        
        self.present(alertController, animated:true, completion:nil)
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
        self.present(customAlert, animated: true, completion: nil)
        
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
        self.present(customAlert, animated: true, completion: nil)
    }
    

    
    func didSetPrice(secId: Int, price: Double) {
        marketModel?.setPriceAlert(secId: secId, price: price, completion: { message in
            guard let message = message else{
                //hide progress
                return
            }
            //hide progress
            self.showBanner(subtitle: message, style: .danger)
        })
    }
    
    func didSelectBuy(secId: Int, quantity: Int) {
        marketModel?.buyOrder(secId: secId, quantity: quantity, completion: { message in
            guard let message = message else{
                //hide progress
                return
            }
            //hide progress
            self.showBanner(subtitle: message, style: .danger)
        })
    }
    
    func didSelectSell(secId: Int, quantity: Int) {
        marketModel?.sellOrder(secId: secId, quantity: quantity, completion: { message in
            guard let message = message else{
                //hide progress
                return
            }
            //hide progress
            self.showBanner(subtitle: message, style: .danger)
        })
    }
    
}
