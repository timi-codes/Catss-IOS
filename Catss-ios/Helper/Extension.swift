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
import Paystack


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


// MARK - UIImageTintColor
extension UIImageView {
    @IBInspectable var imageColor: UIColor! {
        set {
            self.image = self.image?.withRenderingMode(.alwaysTemplate)
            
            super.tintColor = newValue
        }
        get {
            return super.tintColor
        }
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
        let banner = NotificationBanner(title: "", subtitle: subtitle, style: style, colors: CustomBannerColors())
        banner.show()
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.autoDismiss = true
    }
    
    func setDefaultNavigationBar(){
        if let nav = self.navigationController {
            nav.navigationItem.setRightBarButtonItems(nil, animated: true)
            
            nav.navigationBar.topItem?.rightBarButtonItems = []
        self.tabBarController?.navigationItem.titleView?.isHidden = true
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
    
    mutating func insert(string:String,ind:Int) {
        self.insert(contentsOf: string, at:string.index(string.startIndex, offsetBy: ind) )
    }
    
    
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss.SSS")-> Date?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "Africa/Lagos")
        dateFormatter.locale = Locale(identifier: "en_NG")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let date = dateFormatter.date(from: self)
        return date

        
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


extension UILabel{
    
    func addImageWith(name: String, behindText: Bool) {
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: name)

        let attachmentString = NSAttributedString(attachment: attachment)
        
        guard let txt = self.text else {
            return
        }
        
        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }
    
    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}


extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}


// MARK : - Add Border Layer View
extension UITextField {
    
    enum Position {
        case up, bottom, right, left
    }
    
    //  MARK: - Add Single Line Layer
    func addLayer(_ position: Position) -> UITextField {
        
        // bottom layer
        let bottomLayer = CALayer()
        // set width
        let height = CGFloat(1.0)
        bottomLayer.borderWidth = height
        // set color
        bottomLayer.borderColor = UIColor.white.cgColor
        // set frame
        // y position changes according to the position
        let yOrigin = position == .up ? 0.0 : frame.size.height - height
        bottomLayer.frame = CGRect.init(x: 0, y: yOrigin, width: frame.size.width, height: height)
        layer.addSublayer(bottomLayer)
        layer.masksToBounds = true
        
        return self
    }
    
    func removeLayer(){
        self.layer.sublayers?.first?.removeFromSuperlayer()
    }
    
    // Add right/left padding view in textfield
    func addPadding(_ position: Position, withImage image: UIImage? = nil) {
        let paddingHeight = frame.size.height
        let paddingViewFrame = CGRect.init(x: 0.0, y: 0.0, width: paddingHeight * 0.6, height: paddingHeight)
        let paddingImageView = UIImageView.init(frame: paddingViewFrame)
        paddingImageView.contentMode = .scaleAspectFit
        
        if let paddingImage = image {
            paddingImageView.image = paddingImage
        }
        
        // Add Left/Right view mode
        switch position {
        case .left:
            leftView        = paddingImageView
            leftViewMode    = .always
        case .right:
            rightView       = paddingImageView
            rightViewMode    = .always
        default:
            break
        }
    }
}
