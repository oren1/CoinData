//
//  chaceManager.swift
//  ZZBitRate
//
//  Created by aviza on 13/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation

class chaceManager {
    static let shared = chaceManager()
    
    private init() {
    }
    
    var imagesChaceDict : [String : Data] = [:]
    
    var allCoinArray : Array<ZZCoinRate> = []

    var allCoins: [ZZCoin] = []
    
}
