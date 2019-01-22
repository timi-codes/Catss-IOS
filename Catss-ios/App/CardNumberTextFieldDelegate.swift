//
//  CardNumberTextFieldDelegate.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/22/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import Foundation
import UIKit

class CardNumberTextFieldDelegate : NSObject, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string).replacingOccurrences(of: " ", with: "")
        var separatedText = ""
        
        newText.enumerated().forEach { index, character in
            if index != 0 && index % 4 == 0 {
                separatedText.append(" ")
            }
            separatedText.append(String(character))
        }
        
        textField.text = separatedText
        return false
    }
}
