//
//  AlertTableViewCell.swift
//  ZZBitRate
//
//  Created by oren shalev on 07/09/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit

class AlertTableViewCell: UITableViewCell {


    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func moreButtonTapped(_ sender: Any) {
        
    }
    
}
