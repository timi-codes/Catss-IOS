//
//  RankingCell.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/13/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import RxSwift

class RankingCell: UITableViewCell {
    
    static let Identifier = "RankingCell"
    
    @IBOutlet weak var serialNumber: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var pAndL: UIButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureRankCell(index: Int, rankUser: Rank){
        serialNumber.text = "\(index+1)"
        userName.text = rankUser.userName
        let profitOrLoss = String(format:"%.0f%", rankUser.pAndL)
        pAndL.setTitle(profitOrLoss.nairaEquivalent, for: .normal)
        
        switch rankUser.pAndL {
        case 1...:
            pAndL.backgroundColor = Color.successColor
            break
        case 0:
            pAndL.backgroundColor = Color.tabItemTintColor
            break
        case ..<0:
            pAndL.backgroundColor = Color.warningColor
            break
        default :
            fatalError()
        }
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
}
