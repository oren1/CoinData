//
//  RatesVC.swift
//  ZZBitRate
//
//  Created by aviza on 11/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit

import SocketIO

import Kingfisher

import Starscream

import RealmSwift

import StoreKit

class RatesVC: BannerViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,ChooceCoinTVCDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalVolLabel: UILabel!
    @IBOutlet weak var totalMarketCapLabel: UILabel!
    var selectedCoin : ZZCoinRate? 
    
    var dataSource : Array<ZZCoinRate> = []
    var filteredData : Array<ZZCoin> = []

    
    var timer : Timer?
    
    private let refreshControl = UIRefreshControl()
    private var pageIndex = 0
    
    var searchBar:UISearchBar = UISearchBar(frame : CGRect(x:0,y:0, width:200, height:21))

    var socket: WebSocket!
    var socket2: WebSocket!

    func showInAppPurchasesVC() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IAP_VC") as! IAP_VC
               vc.modalPresentationStyle = .overCurrentContext
               self.present(vc, animated: true, completion: nil)
    }


    override func viewDidLoad() {
                        
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        setNavToNonSearchMode()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("applicationDidBecomeActive"), object: nil)
        

        fetchData()

        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged)

        
//        WSManager.shared.subscribe(subs: ["5~CCCAGG~BTC~USD","5~CCCAGG~ETH~USD"])
    }
    
    func fetchData() {
        
        if UserDataManager.shared.needToFetchAllData() {
            
                AppStoreReceiptManager.shared.verifyReceipt {
                    if !UserDataManager.shared.purchasedProVersion() {
                        UserDataManager.shared.deleteAllExceeingNotificationsAndPortfolios()
                    }
                }
                
                getAllPlatformData()
        }
        else {
            self.showLoading()
            if let allCoinsData = General.general().allCoinsData,
                let imagesDicData = General.general().imagesDicData {
                
                let allCoins = parsingManager.shared.parseAllCoins(data: allCoinsData)
                chaceManager.shared.allCoins = allCoins
                
                let imagesDict = parsingManager.shared.parseAllCoinsImagesFromCryptoCompareRequest(data: imagesDicData)
                UserDataManager.shared.imagesDict = imagesDict

            }
            
            self.getFirstPageOfCoinsAndStartTimer()
        }
        
    }
    
    
    
    func getAllPlatformData()  {
            
            showLoading()
        
            let downloadGroup = DispatchGroup()
            downloadGroup.enter()
            NetworkManager.shared.getSettings { (error) in
                downloadGroup.leave()
            }
            downloadGroup.enter()
            NetworkManager.shared.getSupportedExchanges { (error) in
                downloadGroup.leave()
            }
            
            downloadGroup.enter()
            NetworkManager.shared.builedImagesDictFromCryptoCompere { (dict) in
                UserDataManager.shared.imagesDict = dict
                downloadGroup.leave()
            }
            
            downloadGroup.enter()
            NetworkManager.shared.getAllCoins(onCompletion: { (allCoins) in
                chaceManager.shared.allCoins = allCoins
                downloadGroup.leave()
            }) { (error) in
                print(error)
                downloadGroup.leave()
            }
            
            downloadGroup.notify(queue: DispatchQueue.main) { [weak self] in
                self?.hideLoading()
                self?.getFirstPageOfCoinsAndStartTimer()
            }
    }
    
    func getFirstPageOfCoinsAndStartTimer() {
          lastRefreshDate = Date()
          getCoinsDataAndReloadTable(page: 0)
    }
    
    func startTick() {
           timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.tik), userInfo: nil, repeats: true)
        print("startTick")
    }
    
    func stopTick() {
        timer?.invalidate()
        print("stopTick")
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          startTick()
    }
    
    
    
     override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
//        showInAppPurchasesVC()
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTick()
//        WSManager.shared.unSubscribe(subs: ["5~CCCAGG~BTC~USD","5~CCCAGG~ETH~USD"])

    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        if notification.name.rawValue == "applicationDidBecomeActive" {
            print("$$$$$$ applicationDidBecomeActive ")
        }
        else if notification.name.rawValue == "applicationDidEnterBackground" {
            print("$$$$$$ applicationDidEnterBackground")
        }
    }
    
    func getCoinsDataAndReloadTable(page : Int) {
        
        NetworkManager.shared.getTopList(page : page) { [weak self] arr in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                if page == 0 {
                    self.dataSource =  arr
                }
                else {
                    let newArray = self.dataSource + arr
                    self.dataSource =  newArray
                }
                
             
                
                chaceManager.shared.allCoinArray = self.dataSource // i will use this in other controllers
                
                self.hideLoading()
                
                let marketCap = Int(UserDataManager.shared.totalMarketCap)
                let vol = Int(UserDataManager.shared.totalVol)
                self.totalMarketCapLabel.text = "$\(marketCap.withCommas())"
                self.totalVolLabel.text = "$\(vol.withCommas())"
                
                
                
                //reload tableView only when search not actice
                    if self.searchActive == false {
                        self.tableView.reloadData()
                        self.isLoadingPage = false
                    }
                
            }
        }
    }
    
    @objc func tik() {
        print("rates VC tik")
        if(!tableView.isDecelerating) { // Makes sure that the tableView is not in moving state
            updatePricesForVisibleCells()
        }
    }
    
    func updatePricesForVisibleCells() {

        let fsymbols = fromSymbolsAsCommsSeperatedString()
        
        if fsymbols.count > 0 {
            NetworkManager.shared.getPricesFor(fsyms: fsymbols, tsym: "USD") { [weak self] (prices, error) in
                if error == nil {
                    guard let dataSource = self?.dataSource else { return }
                    var indexPathsToUpdate: [IndexPath] = []
                    
                    for  (index, coinRate) in dataSource.enumerated() { // Looping trough all the dataSource to find the specifice objects that needs to be updated with the new price
                        
                        if let newPrice = prices[coinRate.nameID] {
//                            let newPriceString = String(newPrice)
                            let newPriceString = newPrice.priceFormamtWithNoFractionLimit()

                            if (coinRate.price_usd != newPriceString) {
                                self?.dataSource[index].updatePriceUSD(priceUsd: newPriceString)
                                indexPathsToUpdate.append(IndexPath(row: index, section: 0))
                            }
                            
                        }
                    }
                    
                    self?.tableView.reloadRows(at: indexPathsToUpdate, with: .fade)
                }
                
            }
        }

        
    }
    
    func fromSymbolsAsCommsSeperatedString() -> String {
        
        var fsymbols = ""
        let visibleCells = tableView.visibleCells

        for (index,cell) in visibleCells.enumerated() {
            if let indexPath = tableView.indexPath(for: cell) {
                
                let coinRate = dataSource[indexPath.row]
                if index == 0 { // First object
                    fsymbols.append(contentsOf: coinRate.nameID)
                }
                else {
                    fsymbols.append(contentsOf: ",\(coinRate.nameID)")
                }
                
            }
        }
        
        return fsymbols
    }
    
    //MARK: table view

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return filteredData.count
        }
        
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let green : UIColor = UIColor(red:0/255.0, green:225/255.0, blue:0/255.0, alpha: 1.0)
        let red : UIColor = UIColor(red:255/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0)
        
     
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OneCoinRateCell") as! OneCoinRateCell
        if(searchActive) {
            let oneCoin = self.filteredData[indexPath.row]
            cell.configureCell(coin: oneCoin,rank: indexPath.row + 1)
        }
        else {
            let oneCoinRate = self.dataSource[indexPath.row]
            cell.configureCell(coinRate: oneCoinRate,rank: indexPath.row + 1)

        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "OneCoinRateCell") as! OneCoinRateCell
//        cell.iconImage.kf.cancelDownloadTask()
//
//    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        

        if searchActive {
           // selectedCoin = filteredData[indexPath.row]
        }
        else {
            selectedCoin = dataSource[indexPath.row]
        }
        self.performSegue(withIdentifier: "CoinVCSegue", sender: self)
        
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
        
        if(searchActive) {
           // oneCoin = self.filteredData[editActionsForRowAt.row]
        }
        
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
            let activity = UIActivityViewController(activityItems: [MyStringItemSource("my custom text"),shareImage], applicationActivities: nil)
            activity.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.print,
                UIActivityType.addToReadingList,
                UIActivityType.saveToCameraRoll,
                UIActivityType.openInIBooks,
                UIActivityType.mail,
                UIActivityType.copyToPasteboard
            ]
            
            activity.completionWithItemsHandler = { activity, success, items, error in
                print("activity: \(activity), success: \(success), items: \(items), error: \(error)")
                
                if (success) {
                    AppStoreReviewManager.requestReviewIfAppropriate()
                }
            }
            
            self?.present(activity, animated: true, completion: nil)
        }
        share.backgroundColor = .blue
        

        
        return [share]
    }
    
    
    var isLoadingPage = false
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //paging
        let lastElement = dataSource.count - 1
        if !isLoadingPage && indexPath.row == lastElement {
            // indicator.startAnimating()
            isLoadingPage = true
            
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
           // spinner.tintColor = .white
            spinner.color = .white
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
            
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            
            pageIndex += 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                if self.searchActive {
                    //??
                }
                else {
                   self.getCoinsDataAndReloadTable(page: self.pageIndex)
                }
                
            }
        }
    }
    
    var lastRefreshDate : Date?
    @objc private func refreshControlValueChanged(_ sender: Any) {
        
        if let date = lastRefreshDate {
            let date1 = date.addingTimeInterval(15)
            let date2 = Date()

            if date1 < date2 {
                getCoinsDataAndReloadTable(page:0)
                lastRefreshDate = Date()
            }
        }
        
           DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.refreshControl.endRefreshing()
            //self?.activityIndicatorView.stopAnimating()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
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
    

    //MARK: SearchBar
    var searchActive = false
    
    @objc func showSearchBar() {
        
        self.navigationItem.leftBarButtonItem = nil

        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = true
        searchBar.text = ""
        searchBar.delegate = self
        //let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        
        
    }
    
    func setNavToNonSearchMode() {
        
        self.navigationItem.titleView = nil
        self.navigationItem.title = "Market"
        let image = UIImage(named: "searchIcon")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: self, action:  #selector(showChooseCoinVC))
        
    }
    
    @objc func showChooseCoinVC() {
        
        let chooseCoinNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseCoinNavController") as! UINavigationController
        
        let chooseCoinTVC = chooseCoinNavController.viewControllers.first as! ChooceCoinTVC
        chooseCoinTVC.delegate = self
        
        self.present(chooseCoinNavController, animated: true, completion: nil)
    }
    
    func didChooseCoin(_ coin : ZZCoin) {
        print("did choose coin: \(coin.symbol)")
        
        NetworkManager.shared.getCoinsByNames(fsyms: coin.symbol) { (arr) in
            
            DispatchQueue.main.async {
                
                
                if let coinRate = arr.first {
                    
                    self.dismiss(animated: false, completion: nil)

                    
                    let coinVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoinVC") as! CoinVC
                    coinVC.coin = coinRate
                    self.navigationController?.pushViewController(coinVC, animated: true)
                }
                else {
                    //show error alert
                    self.dismiss(animated: false, completion: nil)
                    self.showNoDataError()
                }
            }
            
        }
    }

    func showNoDataError() {
        let alert = UIAlertController(title: "Error", message: "No Data", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           let delegate = UIApplication.shared.delegate as! AppDelegate
             delegate.window?.rootViewController?.present(alert, animated: true)
    }
    
    
  
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        print("searchBarCancelButtonClicked  searchActive:\(searchActive)")

        setNavToNonSearchMode()
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange : \(searchText)")

        
        if searchText == "" {
            searchActive = false;
        }
        else {
           
            searchActive = true
//            filteredData = filteredData.filter({ (coin) -> Bool in
//                let tmp: NSString = coin.name as NSString
//                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
//                return range.location != NSNotFound
//            })
        }
        
 
//        if(filteredData.count == 0){
//            searchActive = false;
//        } else {
//            searchActive = true;
//        }
        self.tableView.reloadData()
    }

}
extension UIViewController {
    
    func showLoading() {
  
        //remove old loading if there one
        hideLoading()
        
        //add new one
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        //loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        loadingIndicator.tag = 6666
        self.view.addSubview(loadingIndicator)
    }
    
    func hideLoading() {
        let loadingIndicator = self.view.viewWithTag(6666)
        if let loadingIndicator = loadingIndicator as? UIActivityIndicatorView {
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
        }
    }
}

extension String {
    var priceFormat: String {
        let floatVal =  (self as NSString).floatValue
        if floatVal > 10 {
            let arr = self.split(separator: ".")
            guard arr.count == 2 else {return self}
            let firstVal :String  = "\(arr.first ?? "0" )"
            let lastVal  :String  = String("\(arr.last ?? "0" )".prefix(2))
            
            return firstVal + "." + lastVal
        }
        
        return  self
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

//extension String {
//    func numberWithCommas() -> String {
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = NumberFormatter.Style.decimal
//        return numberFormatter.string(from: NSNumber(value:self))!
//    }
//}




