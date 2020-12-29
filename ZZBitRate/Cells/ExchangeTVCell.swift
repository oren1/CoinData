//
//  ExchangeTVCell.swift
//  ZZBitRate
//
//  Created by oren shalev on 13/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit

class ExchangeTVCell: UITableViewCell {

    @IBOutlet weak var exchangeLogoImageView: UIImageView!
    @IBOutlet weak var exchangeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
