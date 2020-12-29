//
//  TradeCell.swift
//  ZZBitRate
//
//  Created by aviza on 19/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit

class TradeCell: UITableViewCell {

 //   @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var labelPrice: UILabel!
    //@IBOutlet weak var labelTransactionId: UILabel!
    @IBOutlet weak var labelBuy: UILabel!
    
    @IBOutlet weak var labelQuantity: UILabel!
   // @IBOutlet weak var labelMarket: UILabel!
    
    @IBOutlet weak var labelTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.labelBuy.textColor = .darkGray
            self.labelQuantity.textColor = .darkGray
            self.labelTotal.textColor = .darkGray
            self.labelPrice.textColor = .darkGray
        }

    }

}
