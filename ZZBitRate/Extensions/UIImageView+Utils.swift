//
//  UIImageView+Utils.swift
//  ZZBitRate
//
//  Created by oren shalev on 11/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func makeRoundCorners() {
        self.layer.cornerRadius = self.bounds.size.height / 2
        self.clipsToBounds = true
//        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
