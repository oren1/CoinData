//
//  StringProtocol+Utils.swift
//  ZZBitRate
//
//  Created by oren shalev on 11/11/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
