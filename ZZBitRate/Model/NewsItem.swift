//
//  NewsItem.swift
//  ZZBitRate
//
//  Created by aviza on 12/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation

struct NewsItem {
    
    let author    : String
    let description     : String
    let publishedAt     : String
    let title     : String
    let urlString    : String
    let urlToImage     : String
    let source     : [String : Any]

}

extension NewsItem {
    init?(json: [String: Any]) {

        let author = json["author"] as? String
        let description = json["description"] as? String
        let publishedAt = json["publishedAt"] as? String
        let title = json["title"] as? String
        let urlString = json["url"] as? String
        let urlToImage = json["urlToImage"] as? String
        let source = json["source"] as? [String : Any]

        
        self.author      = author ?? ""
        self.description = description ?? ""
        self.publishedAt = publishedAt ?? ""
        self.title       = title ?? ""
        self.urlString   = urlString ?? ""
        self.urlToImage  = urlToImage ?? ""
        self.source      = source ?? ["":""]

    }
}
