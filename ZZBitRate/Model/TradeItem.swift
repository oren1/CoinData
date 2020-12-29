//
//  TradeItem.swift
//  ZZBitRate
//
//  Created by aviza on 19/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation

//The response will have the following format:
//
//'{SubscriptionId}~{ExchangeName}~{CurrencySymbol}~{CurrencySymbol}~{Flag}~{TradeId}~{TimeStamp}~{Quantity}~{Price}~{Total}'
//
//
//
//Flag    Description
//1    Buy
//2    Sell
//4    Unknown

struct TradeItem {
    
    let subscriptionId        : String
    let exchangeName        : String
    let currencySymbolFrom     : String
    let currencySymbolTo     : String
    let flag     : String
    let TradeId     : String
    let timeStamp           : String
    let quantity             : String
    let price               : String
    let total                : String

}

extension TradeItem {
    init?(str : String) {
        
        var myStringArr = str.components(separatedBy: "~")
        if myStringArr.count >= 10 {
            self.subscriptionId      = myStringArr[0]
            self.exchangeName        = myStringArr[1]
            self.currencySymbolFrom  = myStringArr[2]
            self.currencySymbolTo    = myStringArr[3]
            self.flag                = myStringArr[4]
            self.TradeId             = myStringArr[5]
            self.timeStamp           = myStringArr[6]
            self.quantity            = myStringArr[7]
            self.price               = myStringArr[8]
            self.total               = myStringArr[9]
        }
        else {
         return nil
        }
        
    }
}
