//
//  NewsVC.swift
//  ZZBitRate
//
//  Created by aviza on 11/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit


class NewsVC: BannerViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var nextPage = 1
    var selectedNewsItem : NewsItem?
    
    var loadingData = false
//    var searchString = "Bitcoin%20OR%20Litecoin%20OR%20Ethereum"
    var searchString = "cryptocurrency"

    var sortBy = "publishedAt"
    
    var dateFormatter = DateFormatter()
    var displayDateFormatter = DateFormatter()



    
    @IBOutlet weak var tableView: UITableView!
    var dataSource : Array<NewsItem> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "News"
        self.tableView.estimatedRowHeight = 120
        self.tableView.tableFooterView = UIView()
        
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        displayDateFormatter.dateFormat = "MMM dd, HH:mm" 

        
        
        self.showLoading()
        setTitleSegmented()
        refreshList()
        
    

    }
    
    func setTitleSegmented() {
        // Initialize
        let items = ["Latest", "Popular"]
        let customSC = UISegmentedControl(items: items)
        customSC.selectedSegmentIndex = 0
        
        // Set up Frame and SegmentedControl
        let bounds = UIScreen.main.bounds
        customSC.frame = CGRect(x:0,y:0,width:bounds.width - 40,height:28)
   
        customSC.tintColor = .orange
        // Add target action method
        
        customSC.addTarget(self, action: #selector(segmentedlValueChanged(_:)), for: .valueChanged)
        
        self.navigationItem.titleView = customSC
    }
    
    func refreshList() {
        
        loadingData = true
        
        NetworkManager.shared.getNews(page: nextPage, searchString: searchString, sortBy: sortBy) { [weak self] arr in
            self?.dataSource += arr
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.nextPage += 1
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
        
//        NetworkManager.shared.getNews(page: nextPage) { [weak self] arr in
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//                self?.nextPage += 1
//                self?.hideLoading()
//                self?.loadingData = false
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @objc private func segmentedlValueChanged(_ sender: Any) {
        
        dataSource = []
        tableView.reloadData()
       // showLoading()

        nextPage = 1
        
        let sc = sender as! UISegmentedControl
        switch sc.selectedSegmentIndex {
        case 0:
            sortBy = "publishedAt"
        case 1:
            sortBy = "popularity"
        default:
            print("error")
        }
        
        refreshList()

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newsItem = self.dataSource[indexPath.row]
        let Identifier = (indexPath.row % 5 == 4) ? "BigNewsItemCell" : "SmallNewsItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier) as! NewsItemCell

        cell.titleLabel.text = newsItem.title
        cell.descLabel.text = newsItem.description
//        cell.dateLabel.text = newsItem.publishedAt
        //cell.dateLabel.text = "" // save it for next version
        
        let date :Date? = dateFormatter.date(from: newsItem.publishedAt)
        if let date = date {
        cell.dateLabel.text = displayDateFormatter.string(from: date)
        }
        cell.authorLabel.text = newsItem.author
        
        let url = URL(string: newsItem.urlToImage)
        let placeHolder =  #imageLiteral(resourceName: "news-placeholder")
        cell.newsImageView.kf.setImage(with: url, placeholder:placeHolder)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNewsItem = dataSource[indexPath.row]
        self.performSegue(withIdentifier: "NewsWebSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if dataSource.count >= 20 { // to solve bug when theres only 1 item
            let lastElement = dataSource.count - 1
            
            if !loadingData && indexPath.row == lastElement {
                //indicator.startAnimating()
                loadingData = true
                refreshList()
            }
        }

    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
