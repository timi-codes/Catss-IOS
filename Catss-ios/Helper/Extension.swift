//
//  Extension.swift
//  Catss-ios
//
//  Created by Tejumola David on 11/23/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import JGProgressHUD
import NotificationBannerSwift


// MARK - Keyboard helper method
extension UIViewController {
    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat{
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}


// MARK - View related helpers
extension UIViewController {
    
    func showProgress(message: String){
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = message
        hud.show(in: self.view, animated: true)
    }
    
    func hideProgress(){
    JGProgressHUD.allProgressHUDs(in: self.view).forEach { (JGProgressHUD) in
            JGProgressHUD.dismiss()
        }
    }
    
    func showBanner(subtitle: String, style:BannerStyle){
        let banner = NotificationBanner(title: "", subtitle: subtitle, style: style)
        banner.show()
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.autoDismiss = true
    }
    
    func setDefaultNavigationBar(){
        if let nav = self.navigationController {
            nav.navigationItem.setRightBarButtonItems(nil, animated: true)
            nav.navigationBar.topItem?.rightBarButtonItems = []
        }
    }
    
    func setUpNavBarItem(){
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CATSS", style: .done, target: self, action: nil)
        self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor :UIColor.white,NSAttributedString.Key.font:UIFont.setLightFont(of:14)], for: .normal )
        self.tabBarController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor :UIColor.white,NSAttributedString.Key.font:UIFont.setLightFont(of:14)], for: .selected )
    }
    
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func hideContentController(content: UIViewController) {
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
    }
}


extension UIFont {
    
    class func setBoldFont(of size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica-Bold", size: size)!
    }
    
    class func setFont(of size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size)!
    }
    
    class func setMediumFont(of size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
    
    class func setLightItalicFont(of size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Italic", size: size)!
    }
    
    class func setBoldItalicFont(of size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-BoldItalic", size: size)!
    }
    
    class func setLightFont(of size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }
    
    class func setItalicFont(of size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Italic", size: size)!
    }
    
    class func setExtraboldFont(of size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Extrabold", size: size)!
    }
    
}

extension String {
    var nairaEquivalent: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "en_NG")
        
        guard let doubleValue = Double(self) else {
            return "\(self)"
        }
        
        let convertedValue = doubleValue
        guard let value = currencyFormatter.string(from: NSNumber(value: convertedValue)) else{
            return self
        }
        return value
    }
    
    var toDouble: Double {
        return Double(self) ?? 0.00
    }
}

extension Double {
    func toString() -> String {
        return String(format: "%.2f",self)
    }
}

extension UIStoryboard {
    func controllerFor(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    func onBoardControllerFor(identifier: String) -> UIViewController {
        return UIStoryboard(name: "onBoard", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    func dialogControllerFor(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Dialog", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}
