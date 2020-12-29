//
//  NewsItemCell.swift
//  ZZBitRate
//
//  Created by aviza on 12/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit

class NewsItemCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
