//
//  Settings.swift
//  ZZBitRate
//
//  Created by oren shalev on 22/11/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import RealmSwift

class Settings: Object {
   @objc dynamic var maxAmountOfIntervalNotifications: Int = 2
   @objc dynamic var maxAmountOfLimitNotifications: Int = 3
   @objc dynamic var maxAmountOfPortfolios: Int = 3
   @objc dynamic var fetchDataTimeInSeconds: Double = 0
}
