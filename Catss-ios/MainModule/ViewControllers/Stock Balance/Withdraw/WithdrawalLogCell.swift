//
//  WithdrawalLogCell.swift
//  Catss-ios
//
//  Created by Tejumola David on 2/26/19.
//  Copyright © 2019 Tejumola David. All rights reserved.
//


import UIKit
import RxSwift


class WithdrawalLogCell: UITableViewCell {
    
    @IBOutlet weak var requestedDate: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var releasedDate: UILabel!
    @IBOutlet weak var status : UILabel!
    
    static let Indentifier = "WithdrawLogCell"
    
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configureWithdrawLog(with withDrawLog: WithdrawLog){
        
        if let date = withDrawLog.createdAt.toDate(){
            requestedDate.text =  DateUtils.relativePast(for: date)
        }
        
        if let date = withDrawLog.updatedAt.toDate(){
            releasedDate.text =  DateUtils.relativePast(for: date)
        }
        
        amount.text = withDrawLog.amount.nairaEquivalent
        
        switch withDrawLog.status {
        case "0":
            status.text = "Processing"
            status.textColor = Color.alertColor
        case "1":
            status.text = "Approved"
            status.textColor = Color.successColor
        default:
            return
        }
        
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
}

