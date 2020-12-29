//
//  ShareItem.swift
//  ZZBitRate
//
//  Created by aviza on 09/02/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import UIKit

class ShareItem: UIView {
    @IBOutlet weak var CoinImageView: UIImageView!
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rowView: UIView!
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var volLabel: UILabel!
    @IBOutlet weak var capLabel: UILabel!
    @IBOutlet weak var presentLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ShareItemView", owner: self, options: nil)
        addSubview(ContentView)
        ContentView.frame = self.frame
        ContentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
}
