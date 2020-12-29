//
//  FavoriesVC.swift
//  ZZBitRate
//
//  Created by aviza on 18/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit


class FavoriesVC: BannerViewController, UITableViewDelegate, UITableViewDataSource, SocketIOManagerDelegate {
    
    
    @IBOutlet weak var massageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource : Array<ZZCoinRate> = []
    var selectedCoin : ZZCoinRate?


    //let arrStr = ["5~CCCAGG~BTC~USD"]
    private let refreshControl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Favorites"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("applicationDidBecomeActive"), object: nil)

        
        self.tableView.tableFooterView = UIView()

       // SocketIOManager.shared.delegate = self
        
        
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // SocketIOManager.shared.addSubsToSocket(strArray: arrStr)
        lastRefreshDate = Date()
        getCoinsDataAndReloadTable()
        
        
        //show massage if no items
        massageLabel.alpha = 0
        let defaults = UserDefaults.standard
        let favArray = defaults.object(forKey: "fav_array") as? [String] ?? [String]()
        
        if favArray.count == 0 {
            massageLabel.alpha = 1
        }

        
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // SocketIOManager.shared.removeSubs(strArray: arrStr)
 
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        if notification.name.rawValue == "applicationDidBecomeActive" {
            print("$$$$$$ applicationDidBecomeActive ")
            getCoinsDataAndReloadTable()
        }
        else if notification.name.rawValue == "applicationDidEnterBackground" {
            print("$$$$$$ applicationDidEnterBackground")
            
        }
    }
    
    
    func getCoinsDataAndReloadTable() {
        
        let favArray = UserDefaults.standard.object(forKey: "fav_array") as? [String] ?? [String]()
        let coinsString = (favArray.map{String($0)}).joined(separator: ",")
        NetworkManager.shared.getCoinsByNames(fsyms: coinsString) { [weak self] arr in
            self?.dataSource = arr
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.hideLoading()
            }
        }
    }
    

    //MARK: table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let green : UIColor = UIColor(red:0/255.0, green:225/255.0, blue:0/255.0, alpha: 1.0)
        let red : UIColor = UIColor(red:255/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0)
        
        let oneCoin = self.dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneCoinRateCell") as! OneCoinRateCell
        
 
        cell.selectionStyle = .none
        cell.rankLabel.text = "\(indexPath.row + 1)"
        //cell.iconImage.downloadedFrom(link: oneCoin.imageUrl)
        cell.nameLabel.text = oneCoin.name
        cell.priceLabel.text = oneCoin.price_usd
        
        let imageUrl = UserDataManager.shared.imagesDict[oneCoin.nameID]
        if let imageUrl = imageUrl {
            let url = URL(string: imageUrl)
            cell.iconImage.kf.setImage(with: url)
        }
        
        cell.priceBGView.layer.cornerRadius = 2
        cell.presentLabel.text = "\(oneCoin.percent_change_24h)%"
        
        if let presnt = Float(oneCoin.percent_change_24h) {
            
            if presnt >= 0.0 {
                //green
                cell.priceBGView.backgroundColor = green
                cell.presentLabel.textColor = green
                cell.priceLabel.textColor = .black
                cell.priceLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
                
            }
            else {
                //red
                cell.priceBGView.backgroundColor = red
                
                cell.presentLabel.textColor = red
                cell.priceLabel.textColor = .white
                //cell.priceBGView.layer.borderColor = red.cgColor
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        selectedCoin = dataSource[indexPath.row]
        self.performSegue(withIdentifier: "CoinVCSegue", sender: self)
    }
    
    var lastRefreshDate : Date?
    @objc private func refreshControlValueChanged(_ sender: Any) {
        //this is fake where not gonna do a server request
        
        if let date = lastRefreshDate {
            let date1 = date.addingTimeInterval(15)
            let date2 = Date()

            if date1 < date2 {
                getCoinsDataAndReloadTable()
                lastRefreshDate = Date()

            }
            
        }else {
            //should not happed
            lastRefreshDate = Date()
            getCoinsDataAndReloadTable()
        }
        
           DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.refreshControl.endRefreshing()
            //self?.activityIndicatorView.stopAnimating()
        }
    }
    
    //MARK:Edit
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: editActionsForRowAt) as! OneCoinRateCell
        let green : UIColor = UIColor(red:0/255.0, green:225/255.0, blue:0/255.0, alpha: 1.0)
        let red : UIColor = UIColor(red:255/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0)
        var oneCoin = self.dataSource[editActionsForRowAt.row]
        
        var bgImage = UIImage()
        let random =  Int(arc4random_uniform(5)) //values from 0..4
        
        switch random {
        case 0:
            bgImage = #imageLiteral(resourceName: "shareBg")
        case 1:
            bgImage = #imageLiteral(resourceName: "ShareBG3-1")
        case 2:
            bgImage = #imageLiteral(resourceName: "ShareBG2")
        case 3:
            bgImage = #imageLiteral(resourceName: "ShareBg3")
        case 4:
            bgImage = #imageLiteral(resourceName: "ShareBG7")
        default:
            bgImage = #imageLiteral(resourceName: "shareBg")
        }
        
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { [weak self]action, index in
            print("share button tapped")
            
            let w = 600
            let h = 400
            let v = ShareItem(frame :CGRect(x: 0, y: 0, width: w, height: h))
            
            v.bgImage.image = bgImage
            
            v.nameLabel.text = oneCoin.name
            v.CoinImageView.image = cell.iconImage.image
            v.priceLabel.text = "$\(oneCoin.price_usd.priceFormat)"
            v.priceView.backgroundColor = red
            v.priceView.layer.cornerRadius = 6
            //v.priceView.layer.borderWidth = 4
            
            let marketCapFloat = Float(oneCoin.market_cap_usd)
            if let marketCapFloat = marketCapFloat {
                let marketCap = Int(marketCapFloat)
                v.capLabel.text = "$\(marketCap.withCommas())"
            }
            
            let volFloat = Float(oneCoin.one_day_volume_usd)
            if let volFloat = volFloat {
                let vol = Int(volFloat)
                v.volLabel.text = "$\(vol.withCommas())"
            }
            
            v.rowView.layer.cornerRadius = 10
            v.rowView.layer.borderWidth = 10
            v.presentLabel.text = "\(oneCoin.percent_change_24h)%"
            
            if let presnt = Float(oneCoin.percent_change_24h) {
                
                if presnt >= 0.0 {
                    //green
                    v.priceView.backgroundColor = green
                    v.presentLabel.textColor = green
                    v.priceLabel.textColor = .black
                    //v.priceLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
                    v.arrowImageView.image = #imageLiteral(resourceName: "arrow_up")
                    v.rowView.layer.borderColor = green.cgColor
                }
                else {
                    //red
                    v.priceView.backgroundColor = red
                    v.presentLabel.textColor = red
                    v.priceLabel.textColor = .white
                    //cell.priceBGView.layer.borderColor = red.cgColor
                    v.arrowImageView.image = #imageLiteral(resourceName: "arrow_down")
                    v.rowView.layer.borderColor = red.cgColor
                }
            }
            
            v.layoutSubviews()
            //create an image from the big view
            let shareImage = UIImage(view: v)
            // let shareText = "#CoinData"
            
            
            //Share
            let activityViewController = UIActivityViewController(activityItems: [MyStringItemSource("my custom text"),shareImage], applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.print,
                UIActivityType.addToReadingList,
                UIActivityType.saveToCameraRoll,
                UIActivityType.openInIBooks,
                UIActivityType.mail,
                UIActivityType.copyToPasteboard
            ]
            
            self?.present(activityViewController, animated: true, completion: nil)
        }
        share.backgroundColor = .blue
        
        return [share]
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CoinVCSegue" {
            let vc = segue.destination as! CoinVC
            if let coin = selectedCoin {
                vc.coin = coin
            }
            else {
                //error
            }
        }
        
    }
    
    //Socket Delegate
      func socketAnswer(str : String) {
        var myStringArr = str.components(separatedBy: "~")
        print("*********")
        
        if myStringArr[4] == "4" {
            print("Updated **** items :\(myStringArr.count) \(myStringArr[4])  (price = same) \(myStringArr[6]) \(myStringArr[7]) \(myStringArr[8]) \(myStringArr[9])  *******")
        }
        else {
               print("Updated ****  items : \(myStringArr.count) \(myStringArr[4])  (price = \(myStringArr[5])) \(myStringArr[6]) \(myStringArr[7]) \(myStringArr[8]) \(myStringArr[9])  *******")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
  
}
