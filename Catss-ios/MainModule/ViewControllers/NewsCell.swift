//
//  NewsCell.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/18/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class NewsCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    
    static let Identifier = "NewsCell"
    
    private(set) var disposeBag = DisposeBag()

    
    
    func configureNewsCollectionView(newsItem: FinancialNews){
        newsTitle.text = newsItem.title
        newsDescription.text = newsItem.description
        imageView.kf.setImage(with: newsItem.imageUrl)
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
}
