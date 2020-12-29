//
//  Results+Utils.swift
//  ZZBitRate
//
//  Created by oren shalev on 02/12/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    func toArray<T>() -> [T] {
        var array = [T]()
        for result in self {
            array.append(result as! T)
        }
        return array
    }
}
