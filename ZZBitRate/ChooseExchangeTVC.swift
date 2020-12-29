//
//  ChooseExchangeTVC.swift
//  ZZBitRate
//
//  Created by oren shalev on 13/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import MessageUI

protocol AddExchangeDelegeate: class {
    func exchangeAdded()
}

class ChooseExchangeTVC: UITableViewController, MFMailComposeViewControllerDelegate {

    var exchangesNotificationToken: NotificationToken? = nil
    var exchangesResults: Results<Exchange>?

    weak var delegate: AddExchangeDelegeate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setExchangeNotificationToken()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = exchangesResults {
            return results.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let exchange = exchangesResults![indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExchangeTVCell", for: indexPath) as! ExchangeTVCell
        
        cell.exchangeNameLabel.text = exchange.name
        let logoUrl = URL(string: exchange.logoUrl)
        cell.exchangeLogoImageView.kf.setImage(with: logoUrl)
        cell.exchangeLogoImageView.makeRoundCorners()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let addPortfolioTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPortfolioTVC") as! AddPortfolioTVC
        
        addPortfolioTVC.delegate = delegate
        addPortfolioTVC.exchange = exchangesResults?[indexPath.row]
        navigationController?.pushViewController(addPortfolioTVC, animated: true)
    }
    
    func setExchangeNotificationToken() {
        
        let realm = try! Realm()
        exchangesResults = realm.objects(Exchange.self)
        
        
        exchangesNotificationToken = exchangesResults?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                // Always apply updates in the following order: deletions, insertions, then modifications.
                // Handling insertions before deletions may result in unexpected behavior.
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
            
        }
        
    }
    
    
    // MARK: - IBAction
    @IBAction func requestExchangeButtonTapped(_ sender: Any) {
        openEmail()
    }
    
    func openEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Exchange Request")
            mail.setToRecipients(["coin.data.app@gmail.com"])
            mail.setMessageBody("<p>Which exchange would you like to add?</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true) {}
        
        if result == .sent {
            let alert = UIAlertController(title: "E-Mail Sent Successfuly", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    
    deinit {
        exchangesNotificationToken?.invalidate()
    }

    

    
}
