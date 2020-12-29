//
//  EditPortfoliosTVC.swift
//  ZZBitRate
//
//  Created by oren shalev on 28/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import RealmSwift
import NVActivityIndicatorView


class EditPortfoliosTVC: UITableViewController {

    var portfoliosResults: Results<Portfolio>!
    var activityIndicatorView : NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 400) , type: .ballClipRotateMultiple, color: .white, padding: 140)
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return portfoliosResults!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let portfolio = portfoliosResults[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.textColor = UIColor.lightGray
        cell.textLabel?.text = portfolio.name

        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
                let deleteAction = UIContextualAction(style: .normal, title: "Delete",
                  handler: { [weak self] (action, view, completionHandler) in
                    guard let portfolio = self?.portfoliosResults[indexPath.row] else { return }
                    
                    self?.showActivityIndicator()
                    NetworkManager.shared.deletePortfolio(portfolioId: portfolio._id, onSuccess: { (successMessage) in
                        self?.hideActivityIndicator()
                        self?.navigationController?.popViewController(animated: true)
                    }) { [weak self] (error) in
                        self?.hideActivityIndicator()
                        self?.showError(error: error)
                    }
                    
                    completionHandler(true)
                })
        deleteAction.image = UIImage(named: "trash32")
        deleteAction.backgroundColor = UIColor.red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])

        return configuration
        
    }
    
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showActivityIndicator() {
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
    }

}
