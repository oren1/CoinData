//
//  LiveMonitorVC.swift
//  ZZBitRate
//
//  Created by aviza on 19/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit


class LiveMonitorVC: BannerViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource, SocketIOManagerDelegate {
    
    @IBOutlet weak var pauseImage: UIImageView!

    @IBOutlet weak var pauseButtonBorderView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSource : Array<TradeItem> = []
    var selectedCoin : ZZCoinRate?
    var subs : [String] = []
    var selctedSub : [String] = ["0~Bitstamp~BTC~USD"]
    
    var selectedExchangeIndex = 0

    
    var isFreeze = false
    //let subs =  ["0~Bitstamp~BTC~USD","0~OKCoin~BTC~USD","0~Coinbase~BTC~USD","0~Cexio~BTC~USD"]
    
    var fsym = "BTC"

    
    @IBOutlet weak var freezeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Trade (\(fsym))"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("applicationDidBecomeActive"), object: nil)


        
        pauseButtonBorderView.backgroundColor = .clear
        pauseButtonBorderView.layer.cornerRadius = 2
        pauseButtonBorderView.layer.borderWidth = 0.5
        pauseButtonBorderView.layer.borderColor = UIColor.orange.cgColor


        showLoading()
//        NetworkManager.shared.getExchagesFor(fsym: fsym, tsym: "USD") { [weak self] (subsArray) in
//            self?.subs = subsArray
//            DispatchQueue.main.async {
//                self?.hideLoading()
//                self?.collectionView.reloadData()
//                // let firstSub = [self?.subs.first] as? [String]
//                //if let firstSub = firstSub {
//                self?.selctedSub = subsArray
//                SocketIOManager.shared.killSoucktAndOpenNewOne(strArray: subsArray)
//            }
//        }
 
        
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //SocketIOManager.shared.addSubsToSocket(strArray: subs)
        
        SocketIOManager.shared.delegate = self
        NetworkManager.shared.getExchagesFor(fsym: fsym, tsym: "USD") { [weak self] (subsArray) in
            self?.subs = subsArray
            DispatchQueue.main.async {
                self?.hideLoading()
                self?.collectionView.reloadData()
                // let firstSub = [self?.subs.first] as? [String]
                //if let firstSub = firstSub {
                self?.selctedSub = subsArray
                SocketIOManager.shared.killSoucktAndOpenNewOne(strArray: subsArray){finish in
                }
            }
        }
        
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification){
        if notification.name.rawValue == "applicationDidBecomeActive" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                print("self.selctedSub : \(self.selctedSub)")

                SocketIOManager.shared.killSoucktAndOpenNewOne(strArray: self.selctedSub){finish in
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        print("viewDidAppear")

 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketIOManager.shared.removeSubs(strArray: subs)
        SocketIOManager.shared.closeConnection()
        //NotificationCenter.default.removeObserver(self)
    }
    
    //this is dealloc
    deinit {
        //remove observer
        NotificationCenter.default.removeObserver(self,name: Notification.Name("applicationDidBecomeActive"),object: nil)
    }
    
    @IBAction func freezeButtonTapped(_ sender: Any) {
        if isFreeze == false {
            isFreeze = true
            pauseImage.image = #imageLiteral(resourceName: "playIcon")
        }
        else {
            isFreeze = false
            pauseImage.image = #imageLiteral(resourceName: "pauseIcon")
        }
    }
    
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: collection view

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
         selectedExchangeIndex = indexPath.row
         collectionView.reloadData()
        
        //reload the table view
        dataSource = []
        tableView.reloadData()
        // stop freeze
        isFreeze = false
        pauseImage.image = #imageLiteral(resourceName: "pauseIcon")
        
//        //remove old
//        SocketIOManager.shared.removeSubs(strArray: selctedSub)
//
//        //add new
//        selctedSub = [subs[indexPath.row]]
//        SocketIOManager.shared.addSubsToSocket(strArray: selctedSub)

        if indexPath.row == 0 {
            selctedSub = subs
        }
        else {
            selctedSub = [subs[indexPath.row - 1]]
        }
        
        showLoading()
        SocketIOManager.shared.killSoucktAndOpenNewOne(strArray: selctedSub){[weak self] (finish) in
            self?.hideLoading()
        }


        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subs.count + 1
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExtangeCollectionCell", for: indexPath as IndexPath) as! ExtangeCollectionCell
  
        if indexPath.row == 0  {
            cell.exchangeLabel.text = "ALL"
        }
        else {
            let sub = subs[indexPath.row - 1]
            let name = parsingManager.shared.getExchangeNameFromSub(str: sub)
            cell.exchangeLabel.text = name
        }

        //cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        if indexPath.row == selectedExchangeIndex {
            cell.exchangeLabel.textColor = .orange
        }
        else {
            cell.exchangeLabel.textColor = .gray
        }
        
        return cell
    }
    
    
    //MARK: table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let green : UIColor = UIColor(red:0/255.0, green:225/255.0, blue:0/255.0, alpha: 1.0)
        let red : UIColor = UIColor(red:255/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0)
        let white : UIColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0)
        
        var cellColor : UIColor = white
        let tradeItem = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradeCell") as! TradeCell
        
        
        var typeStr = ""
            if tradeItem.flag == "1" {
                cellColor = green
                typeStr = "BUY"
            }
            else if tradeItem.flag == "2" {
                cellColor = red
                typeStr = "SELL"
            }
            else {
                cellColor = white
                typeStr = "UNKNOWN"
            }
        
           cell.labelBuy.text = "\(typeStr) \(tradeItem.currencySymbolFrom) \(tradeItem.exchangeName)"
            
            cell.labelBuy.textColor = cellColor
            cell.labelPrice.textColor = cellColor
            cell.labelTotal.textColor = cellColor
            cell.labelQuantity.textColor = cellColor
            //cell.labelMarket.textColor = cellColor

        
            cell.labelPrice.text = "$\(tradeItem.price)"
            cell.labelQuantity.text = tradeItem.quantity
            //cell.labelMarket.text = tradeItem.exchangeName

        
        let myFloat = (tradeItem.total as NSString).floatValue
        let twoDecimalPlaces = String(format: "%.2f", myFloat)

        cell.labelTotal.text = "$\(twoDecimalPlaces)"

        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.tableView.deselectRow(at: indexPath, animated: false)
        
        //freeze
        isFreeze = true
        pauseImage.image = #imageLiteral(resourceName: "playIcon")

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
        
        if isFreeze == false {
            
            if let tradeItem = TradeItem(str:str) {
                var newArray : Array<TradeItem> = []
                newArray.append(tradeItem)
                newArray.append(contentsOf: dataSource)
                if newArray.count >= 1000 {
                    newArray.remove(at: 999)
                }
                
                print("arr count ---- \(newArray.count)")
                
                dataSource = newArray
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
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

