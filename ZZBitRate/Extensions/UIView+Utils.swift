//
//  UIView+Utils.swift
//  ZZBitRate
//
//  Created by oren shalev on 12/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
    
    func makeRoundEdges() {
        self.layer.cornerRadius = self.bounds.size.height / 6
        self.clipsToBounds = true
            self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func makeCircle() {
        self.layer.cornerRadius = self.bounds.size.height / 2
        self.clipsToBounds = true
            self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
