//
//  TransLogCellTableViewCell.swift
//  Catss-ios
//
//  Created by Tejumola David on 1/30/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//


import UIKit
import RxSwift


class TransLogCell: UITableViewCell {
    
    @IBOutlet weak var securityNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    static let Indentifier = "TransLogCell"
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureTransLog(with transactionLog: TransactionLog){
        securityNameLabel.text = transactionLog.name
        priceLabel.text = transactionLog.unit
        quantityLabel.text = transactionLog.qty
        
        switch transactionLog.trade {
        case "buy" : typeLabel.textColor = Color.successColor
        case "sell": typeLabel.textColor = Color.warningColor
        default: return
        }
        
        typeLabel.text = transactionLog.trade
        dateLabel.text = transactionLog.date
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
}
