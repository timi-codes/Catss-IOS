//
//  MarketViewCell.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/21/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift

class MarketViewCell: UITableViewCell {
    
    @IBOutlet weak var securityNameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var newPriceLabel: UILabel!
    
    @IBOutlet weak var changePriceLabel: UILabel!
    
    @IBOutlet weak var percentageChangeLabel: UIButton!
    
    static let Identifier = "MarketViewCell"
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureMarketCell(with marketItem : MarketSecurity){
        securityNameLabel.text = marketItem.securityName
        
        statusLabel.text = marketItem.status
        
        
        if let newPrice = marketItem.newPrice {
            if let  changePrice = marketItem.changePrice {
                
                changePriceLabel.text = String(format: "%.4f", changePrice)
                
                newPriceLabel.text = String(format: "%.4f", newPrice)
                
                let percentageChange = (changePrice / newPrice) * 100
                
                percentageChangeLabel.setTitle(String(format: "%.3f%%", percentageChange), for: .normal)
                
                switch percentageChange {
                case 1...:
                    percentageChangeLabel.backgroundColor = Color.successColor
                    break
                case 0.0:
                    percentageChangeLabel.backgroundColor = Color.tabItemTintColor
                    break
                case ..<0.0:
                    percentageChangeLabel.backgroundColor = Color.warningColor
                    break
                default :
                    print("\(percentageChange)")
                }
            }
        }
        
        
        if let price = marketItem.price {
             newPriceLabel.text = price
        }

        if let gap = marketItem.gap {
            statusLabel.text = ("GAP \(gap)")
        }
        
        if let trade = marketItem.trade {
            percentageChangeLabel.setTitle("\(trade)", for: .normal)
            percentageChangeLabel.backgroundColor = Color.tabItemTintColor
        }
        
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
