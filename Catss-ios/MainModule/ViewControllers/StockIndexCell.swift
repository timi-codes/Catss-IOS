//
//  StockIndexCell.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/20/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift

class StockIndexCell : UICollectionViewCell {

    @IBOutlet weak var assetName: UILabel!
    
    @IBOutlet weak var currentPrice: UILabel!
    
    @IBOutlet weak var pAndL: UILabel!
    
    static let Indentifier = "StockIndexCell"
    
    private(set) var disposeBag = DisposeBag()

    
    func configureStockindexCollectionView(with stockIndex: StockIndex){
        assetName.text = stockIndex.pairs
        currentPrice.text = stockIndex.stockIndexOpen
        
        if stockIndex.percentile > 0 {
            self.pAndL.text = String(format:"+%.3f%%", stockIndex.percentile)
            self.pAndL.textColor = Color.successColor
        }else if stockIndex.percentile < 0 {
            self.pAndL.text = String(format:"%.3f%%", stockIndex.percentile)
            self.pAndL.textColor = Color.warningColor
        }else{
            self.pAndL.text = String(format:"%.3f%", stockIndex.percentile)
            self.pAndL.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        }
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

}
