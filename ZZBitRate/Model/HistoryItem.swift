//
//  HistoryItem.swift
//  ZZBitRate
//
//  Created by aviza on 14/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation


struct HistoryItem {
    
    let time       : Double
    let close      : Double
    let high       : Double
    let low        : Double
    let open       : Double
    let volumefrom : Double
    let volumeto   : Double
    
}

extension HistoryItem {
    init?(json: [String: Any]) {
        
               //{"time":1513237680,"close":720.26,"high":724.5,"low":720.17,"open":724.5,"volumefrom":16.549999999999997,"volumeto":11948.029999999999},
        
        let time = json["time"] as? Double
        let close = json["close"] as? Double
        let high = json["high"] as? Double
        let low = json["low"] as? Double
        let open = json["open"] as? Double
        let volumefrom = json["volumefrom"] as? Double
        let volumeto = json["volumeto"] as? Double
        
        self.time         = time ?? 0.0
        self.close        = close ?? 0.0
        self.high         = high ?? 0.0
        self.low          = low ?? 0.0
        self.open         = open ?? 0.0
        self.volumefrom   = volumefrom ?? 0.0
        self.volumeto     = volumeto ?? 0.0

    }
}
