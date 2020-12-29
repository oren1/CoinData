//
//  CoinVC.swift
//  ZZBitRate
//
//  Created by aviza on 13/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit
import SwiftChart

class CoinVC: UIViewController,ChartDelegate {
    
    var coin : ZZCoinRate?
    
    var selctedCoinHistory : CoinHistory?
    
    var dateFormatter = DateFormatter()
    
    var onlyTimeDateFormatter = DateFormatter()
    var daysDateFormatter = DateFormatter()

    @IBOutlet weak var percent_1w_Label: UILabel!
    @IBOutlet weak var percent_24h_Label: UILabel!
    @IBOutlet weak var percent_1h_Label: UILabel!
    @IBOutlet weak var vol24Label: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var askLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var marketCupLabel: UILabel!
    @IBOutlet weak var timeSegmented: UISegmentedControl!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var availiableSupplyLabel: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    
    @IBOutlet weak var getInfoButton: UIButton!
    @IBOutlet weak var AddToFavoriesButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var chartContainer: UIView!
    
    @IBOutlet weak var watchLiveButton: UIButton!
    @IBOutlet weak var getNewsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let coin = coin {
            self.title = "\(coin.name) (\(coin.nameID))"
            
            let imageUrl = UserDataManager.shared.imagesDict[coin.nameID]
            if let imageUrl = imageUrl {
                let url = URL(string: imageUrl)
                coinImage.kf.setImage(with: url)
            }
            priceLabel.text = coin.price_usd
            
            setLabels()
            
            setTimeSegmentedUI()
            
            timeSegmented.selectedSegmentIndex = 1
            
            NetworkManager.shared.getHistory(apiName:"histominute",fsym: coin.nameID, tsym: "USD", limit: 24 * 60, aggregate: 1 , exchange: "CCCAGG", onCompletion: { [weak self](coinHistory) in
                self?.selctedCoinHistory = coinHistory
                DispatchQueue.main.async {
                    self?.builedChartFromCoinHistory(coinHistory)
                    
                    //set ask bid labels
                    let histoItem = coinHistory.arr.last
                    if let histo = histoItem {
                        //high
                        self?.highLabel.text = "$\(histo.high)"
                        //low
                        self?.lowLabel.text = "$\(histo.low)"
                        //ask
                        self?.askLabel.text = "$\(histo.open)"
                        //bid
                        self?.bidLabel.text = "$\(histo.close)"
                    }
                }
            })
        
            
            
        }
        
        dateFormatter = DateFormatter()
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM dd, HH:mm" //Specify your format that you want
        
       
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        setLabels()
        
        setFavoritesButtonTitle()
    }
    

    func setLabels() {
        
        if let coin = coin {
            
            let marketCapFloat = Float(coin.market_cap_usd)
            if let marketCapFloat = marketCapFloat {
                let marketCap = Int(marketCapFloat)
                marketCupLabel.text = "$\(marketCap.withCommas())"
            }
            
//            let volFloat = Float(coin.one_day_volume_usd)
//            if let volFloat = volFloat {
//                let vol = Int(volFloat)
//                vol24Label.text = "$\(vol.withCommas())"
//            }
            
            
            let supllyFloat = Float(coin.available_supply)
            if let supllyFloat = supllyFloat {
                let suplly = Int(supllyFloat)
                availiableSupplyLabel.text = "\(suplly.withCommas())"
            }

//            //should this be a float with commas????
//            let totalSupllyFloat = coin.total_supply
//           // if let totalSupllyFloat = totalSupllyFloat {
//                let totalSuplly = Int(totalSupllyFloat)
//                totalSupplyLabel.text = "\(totalSuplly.withCommas())"
//           // }
            
    
            
            percent_1w_Label.text = ""
//            if let presnt_1w = Float(coin.percent_change_7d) {
//                if presnt_1w >= 0.0 {
//                    //green
//                    percent_1w_Label.textColor = .green
//                }
//                else {
//                    //red
//                    percent_1w_Label.textColor = .red
//                }
//            }
            
            percent_1h_Label.text = "\(coin.percent_change_1h)%"
            if let presnt_1h = Float(coin.percent_change_1h) {
                if presnt_1h >= 0.0 {
                    //green
                    percent_1h_Label.textColor = .green
                }
                else {
                    //red
                    percent_1h_Label.textColor = .red
                }
            }
            
            percent_24h_Label.text = "\(coin.percent_change_24h)%"
            if let presnt_24h = Float(coin.percent_change_24h) {
                if presnt_24h >= 0.0 {
                    //green
                    percent_24h_Label.textColor = .green
                }
                else {
                    //red
                    percent_24h_Label.textColor = .red
                }
            }
        }
        
        getNewsButton.layer.borderWidth = 2
        getNewsButton.layer.borderColor = UIColor.orange.cgColor

        AddToFavoriesButton.layer.borderWidth = 2
        AddToFavoriesButton.layer.borderColor = UIColor.orange.cgColor

        watchLiveButton.layer.borderWidth = 2
        watchLiveButton.layer.borderColor = UIColor.orange.cgColor
        
        getInfoButton.layer.borderWidth = 2
        getInfoButton.layer.borderColor = UIColor.orange.cgColor
        
        
        let date = Date()
        let strDate = dateFormatter.string(from: date)
        dateLabel.text = strDate
        
        
        onlyTimeDateFormatter = DateFormatter()
        onlyTimeDateFormatter.locale = NSLocale.current
        onlyTimeDateFormatter.dateFormat = "HH:mm"
        
        
        daysDateFormatter = DateFormatter()
        daysDateFormatter.locale = NSLocale.current
        daysDateFormatter.dateFormat = "MMM dd"

    }
    //MARK: Buttons
    @IBAction func getInfoButtonTapped(_ sender: Any) {
        //getInfoSegue
     self.performSegue(withIdentifier: "getInfoSegue", sender: self)
        
    }
    
    @IBAction func getNewsButtonTapped(_ sender: Any) {
        //getNewsSegue
        self.performSegue(withIdentifier: "cryptoPanicNewsSegue", sender: self)

    }
    //    func setTitleView(coin : ZZCoinRate) {
    //        // Only execute the code if there's a navigation controller
    //        if self.navigationController == nil {
    //            return
    //        }
    //
    //        // Create a navView to add to the navigation bar
    //        let navView = UIView()
    //
    //        // Create the label
    //        let label = UILabel()
    //        label.text = "\(coin.name) (\(coin.nameID))"
    //        label.textColor = .orange
    //        label.sizeToFit()
    //        label.center = navView.center
    //        label.textAlignment = .center
    //
    //        navView.addSubview(label)
    //
    //        // Create the image view
    //
    //        let imageUrl = UserDataManager.shared.imagesDict[coin.nameID]
    //        if let imageUrl = imageUrl {
    //           // coinImage.downloadedFrom(link: imageUrl)
    //
    //        let image = UIImageView()
    //            image.frame = CGRect(x: label.frame.origin.x - 50.0, y: label.frame.origin.y, width: 50.0, height: 50)
    //        image.downloadedFrom(link: imageUrl)
    //        // To maintain the image's aspect ratio:
    //        //let imageAspect = image.image!.size.width/image.image!.size.height
    //        // Setting the image frame so that it's immediately before the text:
    ////        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
    //        image.contentMode = UIViewContentMode.scaleAspectFit
    //
    //        // Add both the label and image view to the navView
    //        navView.addSubview(image)
    //
    //        }
    //
    //        // Set the navigation bar's navigation item's titleView to the navView
    //        self.navigationItem.titleView = navView
    //
    //        // Set the navView's frame to fit within the titleView
    //        navView.sizeToFit()
    //    }
    //
    //
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //
    //        setFavoritesButtonTitle()
    //
    //    }
    
    
    @IBAction func goToTradeScreenButtonTapped(_ sender: Any) {
        
        //LiveMonitorSegue
        self.performSegue(withIdentifier: "LiveMonitorSegue", sender: self)
        
    }
    
  
    
    @IBAction func AddToVaforiesButtonTapped(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        var favArray = defaults.object(forKey: "fav_array") as? [String] ?? [String]()
        
        if let coin = coin {
            if favArray.contains(coin.nameID) {
                //Remove new
                for (index,val) in favArray.enumerated() {
                    if val == coin.nameID {
                        favArray.remove(at: index)
                    }
                    AddToFavoriesButton.setTitle("ADD TO FAVORITES", for: .normal)
                    AddToFavoriesButton.setTitleColor(.orange, for: .normal)
                }
            }
            else {
                //Add new
                favArray.append(coin.nameID)
                AddToFavoriesButton.setTitle("Remove From Favorites", for: .normal)
                AddToFavoriesButton.setTitleColor(.red, for: .normal)

                
            }
            //save
            defaults.set(favArray, forKey: "fav_array")
        }
        
        
        
    }
    
    func setFavoritesButtonTitle () {
        
        let defaults = UserDefaults.standard
        let favArray = defaults.object(forKey: "fav_array") as? [String] ?? [String]()
        
        if let coin = coin {
            if favArray.contains(coin.nameID) {
                AddToFavoriesButton.setTitle("Remove From Favorites", for: .normal)
                AddToFavoriesButton.setTitleColor(.red, for: .normal)

            }
            else {
                AddToFavoriesButton.setTitle("ADD TO FAVORITES", for: .normal)
                AddToFavoriesButton.setTitleColor(.orange, for: .normal)

            }
        }
        
        //print
        print("favorites Array is : \(favArray)")
    }
    
    
    func setTimeSegmentedUI() {
        timeSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        timeSegmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
    }
    
    @IBAction func timeSegmentedValueChange(_ sender: Any) {
        let seg = sender as! UISegmentedControl
        
        switch seg.selectedSegmentIndex {
        case 0:
            show_3h()
        case 1:
            show_1D()
        case 2:
            show_1W()
        case 3:
            show_1M()
        case 4:
            show_3M()
        case 5:
            show_Y1()
            
            
        default:
            print("error")
        }
        
    }
    
    
    
    
    func show_1h() {
        if let coin = coin {
            
            NetworkManager.shared.getHistory(apiName:"histominute",fsym: coin.nameID, tsym: "USD", limit: 60, aggregate: 1, exchange: "CCCAGG", onCompletion: { [weak self](coinHistory) in
                self?.selctedCoinHistory = coinHistory
                DispatchQueue.main.async {
                    self?.builedChartFromCoinHistory(coinHistory)
                }
            })
        }
    }
    
    func show_3h() {
        if let coin = coin {
            NetworkManager.shared.getHistory(apiName:"histominute",fsym: coin.nameID, tsym: "USD", limit: 3 * 60, aggregate: 1, exchange: "CCCAGG", onCompletion: { [weak self](coinHistory) in
                self?.selctedCoinHistory = coinHistory
                DispatchQueue.main.async {
                    self?.builedChartFromCoinHistory(coinHistory)
                }
            })
        }
    }
    
    func show_1D() {
        if let coin = coin {
            
            NetworkManager.shared.getHistory(apiName:"histominute",fsym: coin.nameID, tsym: "USD", limit: 24 * 60, aggregate: 1 , exchange: "CCCAGG", onCompletion: { [weak self](coinHistory) in
                self?.selctedCoinHistory = coinHistory
                DispatchQueue.main.async {
                    self?.builedChartFromCoinHistory(coinHistory)
                }
            })
        }
    }
    
    func show_1W() {
        if let coin = coin {
            
            NetworkManager.shared.getHistory(apiName:"histohour",fsym: coin.nameID, tsym: "USD", limit: 7 * 24, aggregate: 1, exchange: "CCCAGG", onCompletion: { [weak self](coinHistory) in
                self?.selctedCoinHistory = coinHistory
                DispatchQueue.main.async {
                    self?.builedChartFromCoinHistory(coinHistory)
                }
            })
        }
    }
    func show_1M() {
        if let coin = coin {
            
            NetworkManager.shared.getHistory(apiName:"histoday",fsym: coin.nameID, tsym: "USD", limit: 30, aggregate: 1, exchange: "CCCAGG", onCompletion: { [weak self](coinHistory) in
                self?.selctedCoinHistory = coinHistory
                DispatchQueue.main.async {
                    self?.builedChartFromCoinHistory(coinHistory)
                }
            })
        }
    }
    
    func show_3M() {
        if let coin = coin {
            
            NetworkManager.shared.getHistory(apiName:"histoday",fsym: coin.nameID, tsym: "USD", limit: 90, aggregate:1, exchange: "CCCAGG", onCompletion: { [weak self](coinHistory) in
                self?.selctedCoinHistory = coinHistory
                DispatchQueue.main.async {
                    self?.builedChartFromCoinHistory(coinHistory)
                }
            })
        }
    }
    
    func show_Y1() {
        
        if let coin = coin {
            
            NetworkManager.shared.getHistory(apiName:"histoday",fsym: coin.nameID, tsym: "USD", limit: 395, aggregate:1, exchange: "CCCAGG", onCompletion: { [weak self](coinHistory) in
                self?.selctedCoinHistory = coinHistory
                DispatchQueue.main.async {
                    self?.builedChartFromCoinHistory(coinHistory)
                }
            })
        }
    }
    
    func builedChartFromCoinHistory(_ coinHistory : CoinHistory) {
        
        //Before reload first clear old content
        for v in self.chartContainer.subviews {
            if v is Chart {
                v.removeFromSuperview()
            }
            
            if v is UILabel {
                v.removeFromSuperview()
            }
        }
        
        
        //show Data not available if needed
        guard coinHistory.arr.count > 0 ,
            coinHistory.timeFrom > 0 ,
            coinHistory.timeTo > 0 else {
                
                let noDataLabel = UILabel()
                noDataLabel.text = "Data not available."
                noDataLabel.textColor = .white
                noDataLabel.textAlignment = .center
                noDataLabel.frame = CGRect(x:0,
                                           y:0,
                                           width :self.chartContainer.frame.size.width,
                                           height:self.chartContainer.frame.size.height)
                self.chartContainer.addSubview(noDataLabel)
                
                return
        }
        
        let chart = Chart(frame: CGRect(x: 0, y: 0, width: self.chartContainer.frame.width, height: self.chartContainer.frame.height ))
        chart.delegate = self
        self.chartContainer.addSubview(chart)
        
        print("coinHistory.arr count\(coinHistory.arr.count)")
        
        var dataArray: [(x: Float, y: Float)] = []
        for item in coinHistory.arr {
            dataArray += [(x: Float(item.time), y: Float(item.high))]
        }
        
        //        let data = [(x: 0.0, y: 0),
        //                    (x: 3, y: 4.5),
        //                    (x: 4, y: 2.0035),
        //                    (x: 5, y: 2.3),
        //                    (x: 7, y: 3.7464),
        //                    (x: 8, y: 2.2),
        //                    (x: 9, y: 2.5),
        //                    (x: 11, y: 10.7),
        //                    (x: 12, y: 7),
        //                    (x: 13, y: 9.2),
        //                    (x: 14, y: 5.2),
        //                    (x: 15, y: 7.2),
        //                    (x: 16, y: 6.5676),
        //                    (x: 17, y: 7.455),
        //                    (x: 20, y: 7.455)
        //        ]
        
        let series = ChartSeries(data: dataArray)
        series.area = true
        
        //Use the chart.xLabels property to make the x-axis wider than the actual data
        //chart.xLabels = [0, 3, 6, 9, 12, 15, 18, 21, 24]
        
        
        let timeJumps = (Float(coinHistory.timeTo) - Float(coinHistory.timeFrom)) / 3
        
        chart.xLabels =  [Float(coinHistory.timeFrom),
                          Float(coinHistory.timeFrom) + timeJumps,
                          Float(coinHistory.timeFrom) + (2 * timeJumps),
                          Float(coinHistory.timeTo)]
        //chart.axesColor = .orange
        chart.gridColor = .gray
        chart.highlightLineColor = .orange
        //chart.tintColor = .orange
        chart.labelColor = .gray
        // chart.xLabelsFormatter = { String(Int(round($1))) + "h" }
        
        if timeSegmented.selectedSegmentIndex <= 2 {
            chart.xLabelsFormatter = { (index,val) in self.onlyTimeDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(val)))
            }
        }
        else {
            chart.xLabelsFormatter = { (index,val) in self.daysDateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(val)))
            }
        }

        chart.add(series)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
     // MARK: - Navigation
     
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LiveMonitorSegue" {
            let vc = segue.destination as! LiveMonitorVC
            if let coin = coin {
                vc.fsym = coin.nameID
            }
        }
        if segue.identifier == "getNewsSegue" {
            let vc = segue.destination as! NewsVC
            if let coin = coin {
                vc.searchString = "+\(coin.name) AND cryptocurrncy NOT Bitcoin"
            }
        }
        if segue.identifier == "cryptoPanicNewsSegue" {
            let vc = segue.destination as! CryptoPanicNewsVC
            if let coin = coin {
                vc.currencyString = coin.nameID
                
            }
        }
        
        if segue.identifier == "cryptoPanicNewsSegue" {
            let vc = segue.destination as! CryptoPanicNewsVC
            if let coin = coin {
                vc.currencyString = coin.nameID
                
            }
        }
        
        if segue.identifier == "getInfoSegue" {
            let vc = segue.destination as! CoinInfoVC
            if let coin = coin {
                vc.coin = coin
                
            }
        }
        
        
    }
    
    //MARK: Chart delegate
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        // Do something on touch
        
        for (serieIndex, dataIndex) in indexes.enumerated() {
            if dataIndex != nil {
                // The series at serieIndex has been touched
                let value = chart.valueForSeries(serieIndex, atIndex: dataIndex)
                if let val = value {
                    priceLabel.text = "$\(val)"
                }
                
                //time
                if let time = selctedCoinHistory?.arr[dataIndex!].time {
                    let date = Date(timeIntervalSince1970: time)
                    let strDate = dateFormatter.string(from: date)
                    dateLabel.text = strDate
                }
                
                //high
                if let high = selctedCoinHistory?.arr[dataIndex!].high {
                    highLabel.text = "$\(high)"
                }
                
                //low
                if let low = selctedCoinHistory?.arr[dataIndex!].low {
                    lowLabel.text = "$\(low)"
                }
                
                //ask
                if let ask = selctedCoinHistory?.arr[dataIndex!].open {
                    askLabel.text = "$\(ask)"
                }
                
                //bid
                if let bid = selctedCoinHistory?.arr[dataIndex!].close {
                    bidLabel.text = "$\(bid)"
                }
                
                
            }
        }
        
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        // Do something when finished
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        // Do something when ending touching chart
    }
    
}

