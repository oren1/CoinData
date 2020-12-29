//
//  Double+Utils.swift
//  ZZBitRate
//
//  Created by oren shalev on 11/11/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation

extension Double {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: NSNumber(value:self))!
    }
    
    func priceFormamtWithCurrencySign() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesSignificantDigits = false
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        
        let currencySign = "$"
        return currencySign + numberFormatter.string(from: NSNumber(value: self))!
    }
    
    func priceFormat() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesSignificantDigits = false
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    func priceFormamtWithNoFractionLimit() -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesSignificantDigits = false
        
        let currencySign = "$"
        return currencySign + numberFormatter.string(from: NSNumber(value: self))!
    }
}
