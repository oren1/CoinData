//
//  Exchange.swift
//  ZZBitRate
//
//  Created by oren shalev on 13/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import RealmSwift

enum PermissionKeyType: String {
    case userId = "apiUserId"
    case apiKey = "apiKey"
    case apiSecret = "apiSecret"
}

class Exchange: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var keyName: String = ""
    @objc dynamic var logoUrl: String = ""
    dynamic var instructions = List<String>()
    dynamic var permissionKeys = List<PermissionKey>()
    
    override static func primaryKey() -> String? {
      return "keyName"
    }
    
    func getPermissionKeyObjectForKey(keyType: PermissionKeyType) -> PermissionKey? {
        let results = permissionKeys.filter("key = %@", keyType.rawValue)
          if results.count == 0 {
              return nil
          }
          return results[0]
    }
}

class PermissionKey: Object {
    @objc dynamic var key: String = ""
    @objc dynamic var keyTitle: String = ""
    @objc dynamic var supportQR: Bool = true
}
