//
//  ChooceCoinTVC.swift
//  ZZBitRate
//
//  Created by avi zazati on 31/08/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import UIKit

protocol ChooceCoinTVCDelegate: class {
    
    func didChooseCoinAndAmount(_ coin : ZZCoinRate,amount: Double)
    func didChooseCoin(_ coin : ZZCoin)

}
extension ChooceCoinTVCDelegate {
    func didChooseCoinAndAmount(_ coin : ZZCoinRate,amount: Double) {
        
    }
    func didChooseCoin(_ coin : ZZCoin) {
        
    }
}


class ChooceCoinTVC: UITableViewController, UISearchResultsUpdating {
    
    weak var delegate: ChooceCoinTVCDelegate?
    

    var allCoinsArray : Array<ZZCoin>?
    var filteredCoinArray : Array<ZZCoin>?
    
    var selectedCoin : ZZCoin?

    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Choose Coin"

        allCoinsArray = chaceManager.shared.allCoins
        filteredCoinArray = allCoinsArray
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
       // searchController.searchBar.barTintColor = .black
        

        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = filteredCoinArray else {
            return 0
        }
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseCoinTableViewCell", for: indexPath) as! ChooseCoinTableViewCell
        
        if let filteredCoins = filteredCoinArray {
            let coin = filteredCoins[indexPath.row]
            
            let imageUrl = UserDataManager.shared.imagesDict[coin.symbol]
            if let imageUrl = imageUrl {
                let url = URL(string: imageUrl)
                cell.coinImageView.kf.setImage(with: url)
                cell.coinImageView.makeRoundCorners()
            }
            
            cell.nameLabel.text = "\(coin.fullName)"
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath, animated: true)
        
        if let filteredCoins = filteredCoinArray {
            let coin = filteredCoins[indexPath.row]
            
            selectedCoin = coin
            if let delegate = self.delegate, let _ = selectedCoin  {
                searchController.isActive = false
                delegate.didChooseCoin(selectedCoin!)
            }
            else {
                performSegue(withIdentifier: "addAmountSegue", sender: coin)
            }
            
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = self.searchController.searchBar.text, !searchText.isEmpty {
            filteredCoinArray = allCoinsArray!.sorted(by: { (coin1, coin2) -> Bool in
                return  coin1.fullName < coin2.fullName
            }).filter { coin in
                return coin.fullName.lowercased().hasPrefix(searchText.lowercased()) ||
                coin.fullName.lowercased().hasSuffix("(\(searchText.lowercased()))")
            }
            
        } else {
            filteredCoinArray = allCoinsArray
        }
        
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "addAmountSegue" {
            
            let coin = sender as? ZZCoin
            let vc = segue.destination as! AddNewHoldingVC
            vc.coinName = coin?.fullName
            vc.coinNameID = coin?.symbol
            
            vc.delegate = self.delegate
            //performSegue(withIdentifier:"Popover", sender: self)
       
            
            
        }
    }

}
