//
//  CryptoPanicNewsItem.swift
//  ZZBitRate
//
//  Created by aviza on 29/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation

struct CryptoPanicNewsItem {
    
    let publishedAt     : String
    let title     : String
    let urlString    : String
    let source     : [String : Any]
    
}

extension CryptoPanicNewsItem {
    init?(json: [String: Any]) {
        
        let publishedAt = json["published_at"] as? String
        let title = json["title"] as? String
        let urlString = json["url"] as? String
        let source = json["source"] as? [String : Any]
        
        
        self.publishedAt = publishedAt ?? ""
        self.title       = title ?? ""
        self.urlString   = urlString ?? ""
        self.source      = source ?? ["":""]
        
    }
}
