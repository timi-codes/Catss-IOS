//
//  FinancialNews.swift
//  Catss-ios
//
//  Created by Tejumola David on 12/14/18.
//  Copyright © 2018 Tejumola David. All rights reserved.
//

import Foundation

struct FinancialNews: Codable {
    let title: String?
    let description: String?
    let url: String?
    let urlToImage : String?
    
    var imageUrl : URL? {
        if let url = urlToImage{
            return URL(string: url)
        }
        return nil
    }

    var linkToNews : URL?{
        if let link = url{
            return URL(string: link)
        }
        return nil
    }
}


