//
//  Portfolio.swift
//  ZZBitRate
//
//  Created by oren shalev on 30/09/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import RealmSwift

enum PortfolioType: String {
    case Manual = "manual"
    case Exchange = "exchange"
}

class Portfolio: Object, NSCopying {
    @objc dynamic var _id = ""
    @objc dynamic var __t = ""
    @objc dynamic var userId = ""
    @objc dynamic var type = ""
    @objc dynamic var name = ""
    @objc dynamic var exchangeName = ""
    @objc dynamic var token = ""
    @objc dynamic var dateCreated = 0
    dynamic var balance = List<CoinBalance>()
    
    override static func primaryKey() -> String? {
      return "_id"
    }
    
    
    func fetchCoin(symbol: String) -> CoinBalance? {
        for coinBalance in balance {
            if coinBalance.symbol == symbol {
                return coinBalance
            }
        }
        return nil
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Portfolio()
        copy._id = _id
        copy.__t = __t
        copy.userId = userId
        copy.type = type
        copy.name = name
        copy.exchangeName = exchangeName
        copy.token = token
        copy.dateCreated = dateCreated
        copy.balance = balance
        
        return copy
    }
}

class CoinBalance: Object {
    @objc dynamic var _id = ""
    @objc dynamic var symbol = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var usdTotal = ""
}
