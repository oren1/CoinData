//
//  CoinHistory.swift
//  ZZBitRate
//
//  Created by aviza on 14/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation

class CoinHistory {
    
    var timeTo       : Double = 0
    var timeFrom       : Double = 0
    var arr : Array<HistoryItem> = []
    
    init?(timeTo : Double, timeFrom : Double, arr : Array<HistoryItem> ){
        self.timeTo = timeTo
        self.timeFrom = timeFrom
        self.arr = arr
    }
}

//extension CoinHistory {
//
//}

