//
//  Notification.swift
//  ZZBitRate
//
//  Created by oren shalev on 08/09/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import RealmSwift

enum NotificationType: Int {
    case IntervalNotification = 0, LimitNotification
}

enum NotificationDirection: String {
    case biggerThan = "biggerThan", smallerThan = "smallerThan"
}

enum NotificationInterval: Int {
    case fiveMinutes = 5000,
     fifthinMinutes = 15000,
     thirtyMinutes = 30000,
     oneHour = 60000,
     twoHours = 120000
}

class CryptoNotification: Object {
    @objc dynamic var _id = ""
    @objc dynamic var __t = ""
    @objc dynamic var userId = ""
    @objc dynamic var exchange = ""
    @objc dynamic var name = ""
    @objc dynamic var fsym = ""
    @objc dynamic var tsym = ""
    @objc dynamic var status = 0
    @objc dynamic var dateCreated = ""
    @objc dynamic var dateCreatedInMiliseconds = 0
    
    override static func primaryKey() -> String? {
      return "_id"
    }
}


class LimitNotification: CryptoNotification, NSCopying {
    @objc dynamic var limit: Double = 0.0
    @objc dynamic var direction = ""
    @objc dynamic var repeated = false
    @objc dynamic var repeatedState = ""
    
    func notificationDescription() -> String {
        
        let exchange = self.exchange == "CCCAGG" ? "Global Average" : self.exchange
        let direction =  self.direction == "biggerThan" ? "more" : "less"
        
        return "Notify when \(fsym)/\(tsym) on \(exchange) is \(direction) than \(self.limit)"
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LimitNotification()
        copy._id = _id
        copy.exchange = exchange
        copy.fsym = fsym
        copy.tsym = tsym
        copy.name = name
        copy.limit = limit
        copy.direction = direction
        copy.repeated = repeated
        
        return copy
    }
    
}

class IntervalNotification: CryptoNotification, NSCopying {
    @objc dynamic var startTime = 0
    @objc dynamic var interval = 0
    

    func notificationDescription() -> String {
        
        let exchange = self.exchange == "CCCAGG" ? "Global Average" : self.exchange
        
        return "Notify \(fsym)/\(tsym) price on \(exchange) every \(interval/1000/60) minutes"
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = IntervalNotification()
        copy._id = _id
        copy.exchange = exchange
        copy.fsym = fsym
        copy.tsym = tsym
        copy.name = name
        copy.interval = interval
        
        return copy
    }
}
