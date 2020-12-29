//
//  PortfolioCoinTVCell.swift
//  ZZBitRate
//
//  Created by oren shalev on 06/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit

class PortfolioCoinTVCell: UITableViewCell {

    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
