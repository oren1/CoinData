//
//  String+Utils.swift
//  ZZBitRate
//
//  Created by oren shalev on 29/11/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
extension String {
  func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
    
    public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String? {
      let unreserved = "*-._"
      let allowed = NSMutableCharacterSet.alphanumeric()
      allowed.addCharacters(in: unreserved)

      if plusForSpace {
        allowed.addCharacters(in: " ")
      }

      var encoded = addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
      if plusForSpace {
        encoded = encoded?.replacingOccurrences(of: " ", with: "+")
      }
      return encoded
    }
}
