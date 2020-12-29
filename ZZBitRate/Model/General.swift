//
//  General.swift
//  ZZBitRate
//
//  Created by oren shalev on 26/11/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import RealmSwift

class General: Object {
    @objc dynamic var imagesDicData: Data? = nil
    @objc dynamic var allCoinsData: Data? = nil
    
    static func general() -> General {
        let realm = try! Realm()
        let objects = realm.objects(General.self) //Only on 'General' instance in the app
        if objects.count > 0 {
            return objects[0]
        }
        
        let general = General()
        try! realm.write {
            realm.add(general)
        }
        return general
    }
}
