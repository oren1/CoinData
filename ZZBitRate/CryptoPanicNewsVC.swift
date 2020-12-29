//
//  CryptoPanicNewsVC.swift
//  ZZBitRate
//
//  Created by aviza on 31/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit
import GoogleMobileAds


class CryptoPanicNewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource , GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    @IBOutlet weak var bannerContainerView: UIView!
    
    var dataSource : Array<CryptoPanicNewsItem> = []
    var selectedNewsItem : CryptoPanicNewsItem?
    var loadingData = false
    
    var currencyString = "BTC"
    
    var dateFormatter = DateFormatter()
    var displayDateFormatter = DateFormatter()



    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.tableFooterView = UIView()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        displayDateFormatter.dateFormat = "MMM dd, HH:mm"


        // Do any additional setup after loading the view.
        refreshList()
        setBannerView()
    }
    
    func setBannerView() {
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-1322650429791760/1747143862"
        bannerView.rootViewController = self
        addBannerViewToView(bannerView)
        let request = GADRequest()
        //request.testDevices = ["9ae9935b6671e4c340f4c8929f83c8ad3c207cb2","df3fa193117750f0704f04679ee80e20","85631549b891bb61fca715fac477ad6eb8df8253"]

        bannerView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshList() {
        
        loadingData = true
        
          showLoading()
        NetworkManager.shared.getCryptoPanicPostsForCurrencyWithFilter(currency: currencyString, filter: "") { [weak self] (arr) in
            self?.dataSource = arr
            
            self?.dataSource += arr
            DispatchQueue.main.async {
                self?.tableView.reloadData()
               // self?.nextPage += 1
                self?.hideLoading()
                self?.loadingData = false
                
                
                if self?.dataSource.count == 0 {
                    let noDataLabel = UILabel()
                    noDataLabel.text = "No Results"
                    noDataLabel.tag = 7777
                    noDataLabel.textColor = .white
                    noDataLabel.textAlignment = .center
                    noDataLabel.frame = CGRect(x:0,
                                               y:0,
                                               width :(self?.view.frame.size.width)!,
                                               height:(self?.view.frame.size.height)!)
                    self?.view.addSubview(noDataLabel)
                }
                else {
                    let v = self?.view.viewWithTag(7777)
                    v?.removeFromSuperview()
                }
            }

        }

    }
    
    //MARK: Ad mob
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerContainerView.addSubview(bannerView)
        
        
        self.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self.bannerContainerView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: self.bannerContainerView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    

 
    
    //MARK: table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newsItem = self.dataSource[indexPath.row]
 
        let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoPanicNewsCell") as! CryptoPanicNewsCell
        
        cell.titleLabel.text = newsItem.title
        //cell.dateLabel.text = newsItem.publishedAt
        
        let date :Date? = dateFormatter.date(from: newsItem.publishedAt)
        if let date = date {
            cell.dateLabel.text = displayDateFormatter.string(from: date)
        }
        else {
           cell.dateLabel.text = ""
        }
        //cell.dateLabel.text = "" // save it for next version
        
        //cell.newsImageView.downloadedFrom(link: newsItem.urlToImage)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNewsItem = dataSource[indexPath.row]
        self.performSegue(withIdentifier: "NewsWebSegue", sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "NewsWebSegue" {
            let vc = segue.destination as! NewsWebVC
            if let newsItem = selectedNewsItem {
                vc.urlString = newsItem.urlString
            }
            else {
                //error
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
