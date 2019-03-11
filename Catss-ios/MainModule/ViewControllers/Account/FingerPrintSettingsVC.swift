//
//  FingerPrintSettingsVC.swift
//  Catss-ios
//
//  Created by Tejumola David on 3/11/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import KeychainAccess

class FingerPrintSettingsVC: UIViewController {
    
    @IBOutlet weak var fingerPrintSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(UserKeychainAccess.isFingerPrintEnabled())")
        fingerPrintSwitch.isOn = UserKeychainAccess.isFingerPrintEnabled()
    }

    @IBAction func switchStateDidChange(_ sender: UISwitch) {
        if sender.isOn {
            UserKeychainAccess.setFingerPrintEnabled(true)
        }else{
            UserKeychainAccess.setFingerPrintEnabled(false)
        }
        print(UserKeychainAccess.isFingerPrintEnabled())
    }
}
