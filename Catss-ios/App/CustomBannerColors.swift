//
//  CustomBannerColors.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/28/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class CustomBannerColors: BannerColorsProtocol {

    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:   return color(for: style)
        case .info:     return color(for: style)
        case .none:     return color(for: style)
        case .success:  return color(for: style)
        case .warning:  return Color.accentColor
        }
    }
}
