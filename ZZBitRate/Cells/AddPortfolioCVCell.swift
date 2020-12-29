//
//  AddPortfolioCVCell.swift
//  ZZBitRate
//
//  Created by oren shalev on 01/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit

class AddPortfolioCVCell: UICollectionViewCell {
    
    @IBAction func addPortfolioButtonTapped(_ sender: Any) {
        if let portfolioCVC = self.findViewController() as? PortfoliosCVC {
            portfolioCVC.addButtonTapped()
        }
    }
    
}
