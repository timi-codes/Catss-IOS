//
//  OpenOrderCell.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/16/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift


class OpenOrderCell: UITableViewCell {

    @IBOutlet weak var securityNameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var quantityLabel: UILabel!

    @IBOutlet weak var typeLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!
    
    static let Indentifier = "OpenOrderCell"
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureOpenOrder(with order: Order){
        securityNameLabel.text = order.asset
        priceLabel.text = order.price
        quantityLabel.text = order.qty
        
        switch order.type {
        case "buy" : typeLabel.textColor = Color.successColor
        case "sell": typeLabel.textColor = Color.warningColor
        default: return
        }
        
        typeLabel.text = order.type
        dateLabel.text = order.date
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

}
