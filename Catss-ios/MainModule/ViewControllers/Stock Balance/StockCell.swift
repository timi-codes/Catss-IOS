//
//  StockCell.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/21/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class StockCell : UITableViewCell {
    
    @IBOutlet weak var stockNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    static let Identifier = "StockCell"
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureStockBalanceCell(stockBalance: StockBalance){
        stockNameLabel.text = stockBalance.name
        priceLabel.text = stockBalance.price.nairaEquivalent
        quantityLabel.text = stockBalance.qty
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
