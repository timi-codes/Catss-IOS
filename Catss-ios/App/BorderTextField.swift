//
//  CustomTextField.swift
//  Catss-ios
//
//  Created by Tejumola David on 11/21/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit

@IBDesignable
class BorderTextField : UITextField {
    
    @IBInspectable var paddingY : CGFloat = 0 ;
    
    @IBInspectable var paddingX : CGFloat = 0 ;
    
    @IBInspectable var borderColor : UIColor? {
        didSet{
            refreshBorder(color: borderColor?.cgColor)
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet{
            refreshBorder(width: borderWidth)
        }
    }
    

    
    override init(frame: CGRect) {
        super.init(frame:frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    
    func sharedInit(){
        refreshBorder(color: borderColor?.cgColor)
        refreshBorder(width: borderWidth)
    }
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: paddingX, dy: paddingY)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: paddingX, dy: paddingY)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: paddingX, dy: paddingY)
    }
    
    
    
    func refreshBorder(width: CGFloat){
        layer.borderWidth = width
    }
    
    func refreshBorder(color: CGColor?){
        layer.borderColor = color
    }
    
}
