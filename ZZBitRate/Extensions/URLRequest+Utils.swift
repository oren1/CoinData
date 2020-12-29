//
//  URLRequest+Utils.swift
//  ZZBitRate
//
//  Created by oren shalev on 12/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation

extension URLRequest {
    mutating func encodeBodyParameters(parameters: [String : Any]) {
        
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(value)"
        }
        
        httpBody = parameterArray.joined(separator: "&").data(using: .utf8)
    }
}
