//
//  UIButton+Utils.swift
//  ZZBitRate
//
//  Created by oren shalev on 14/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import UIKit

 extension UIButton {

    func underlineTextButton(title: String?, forState state: UIControlState)
    {
        self.setTitle(title, for: .normal)
        self.setAttributedTitle(self.attributedString(), for: .normal)
    }

    private func attributedString() -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: titleLabel!.text!)
        attributedString.setAttributes([.underlineStyle: 1], range: NSMakeRange(0, attributedString.length))

        return attributedString
    }
}
