//
//  Notification+Names.swift
//  ZZBitRate
//
//  Created by oren shalev on 07/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let invalidateRatesTimer = Notification.Name(rawValue: "invalidateRatesTimer")
    static let fireRatesTimer = Notification.Name(rawValue: "fireRatesTimer")
}
