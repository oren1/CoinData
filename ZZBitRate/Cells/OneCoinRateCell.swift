//
//  OneCoinRateCell.swift
//  ZZBitRate
//
//  Created by aviza on 11/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit

class OneCoinRateCell: UITableViewCell {

    @IBOutlet weak var priceBGView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var presentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    
    let green : UIColor = UIColor(red:0/255.0, green:225/255.0, blue:0/255.0, alpha: 1.0)
    let red : UIColor = UIColor(red:255/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0)
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    
    func configureCell(coin: ZZCoin, rank:Int) {
        
    }
    public func configureCell(coinRate: ZZCoinRate, rank:Int) {
           self.rankLabel.text = "\(rank)"
                  //cell.iconImage.downloadedFrom(link: oneCoin.imageUrl)
                  self.nameLabel.text = coinRate.name
                  self.priceLabel.text = coinRate.price_usd
                  
                 // cell.iconImage.image = nil
                  let imageUrl = UserDataManager.shared.imagesDict[coinRate.nameID]
                  if let imageUrl = imageUrl {
                      let url = URL(string: imageUrl)
                      self.iconImage.kf.setImage(with: url)
                      self.iconImage.makeRoundCorners()
                  }
                  
                  self.priceBGView.layer.cornerRadius = 2
                  self.presentLabel.text = "\(coinRate.percent_change_24h)%"

                  if let presnt = Float(coinRate.percent_change_24h) {
                      if presnt >= 0.0 {
                          //green
                          self.priceBGView.backgroundColor = green
                          self.presentLabel.textColor = green
                          self.priceLabel.textColor = .black
                          self.priceLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
                      }else {
                          //red
                          self.priceBGView.backgroundColor = red
                          self.presentLabel.textColor = red
                          self.priceLabel.textColor = .white
                          //cell.priceBGView.layer.borderColor = red.cgColor
                      }
                  }
    }

}
