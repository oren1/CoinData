//
//  EditProtfolioTableViewCell.swift
//  ZZBitRate
//
//  Created by avi zazati on 07/09/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import UIKit

protocol EditProtfolioTableViewCellDelegate: class {
    
    func didClickDeleteButton(indexPath : IndexPath)
    func didClickEditButton(indexPath : IndexPath)

}

class EditProtfolioTableViewCell: UITableViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    weak var delegate: EditProtfolioTableViewCellDelegate?

    var indexPath : IndexPath!

    @IBOutlet weak var coinAmountLabel: UILabel!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func EditButtonTapped(_ sender: UIButton) {
        self.delegate?.didClickEditButton(indexPath: self.indexPath)
    }
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.delegate?.didClickDeleteButton(indexPath: self.indexPath)

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    
}
