//
//  ExpiryDateTextDelegate.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/22/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import UIKit

class ExpiryDateTextDelegate: NSObject, UITextFieldDelegate {
    
    var isDelete = false
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText =  textField.text! as NSString
        var newText = oldText.replacingCharacters(in: range, with: string)
        var newTextString = String(newText)
        
        if textField.text!.count > newTextString.count {
            isDelete = true
        }
        
        if newTextString.count == 3 {
            if isDelete {
                newTextString.remove(at: newTextString.index(newTextString.startIndex, offsetBy: 2))
            }else{
                newTextString.insert("/", at: newTextString.index(newTextString.startIndex, offsetBy: 2))
                newText = newTextString
            }
        }
        
        isDelete = false
        if newTextString.count <= 5 {
            textField.text = newTextString
        }
        
        return false
    }
    
}
