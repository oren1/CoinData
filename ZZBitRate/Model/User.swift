//
//  User.swift
//  ZZBitRate
//
//  Created by oren shalev on 06/09/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    @objc dynamic var userId = ""
    @objc dynamic var token = ""
    
    static func user() -> User? {
        
        let realm = try! Realm()
        
        let users = realm.objects(User.self)
        if (users.count == 0) {
            return nil
        }
        return users[0]
    }
    

}
