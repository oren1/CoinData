//
//  UserHolding.swift
//  ZZBitRate
//
//  Created by avi zazati on 30/08/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import Foundation
import RealmSwift

//// Define your models like regular Swift classes
//class Dog: Object {
//    @objc dynamic var name = ""
//    @objc dynamic var age = 0
//}
//class Person: Object {
//    @objc dynamic var name = ""
//    @objc dynamic var picture: Data? = nil // optionals supported
//    let dogs = List<Dog>()
//}

// Define your models like regular Swift classes
class UserHolding: Object {
    @objc dynamic var amount = 0.0
    @objc dynamic var coinName = ""
    @objc dynamic var coinNameId = ""
    @objc dynamic var priceForOneCoin = 0.0
    @objc dynamic var totalUSD = 0.0

}
