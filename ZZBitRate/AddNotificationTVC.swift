//
//  AddNotificationTVC.swift
//  ZZBitRate
//
//  Created by oren shalev on 13/09/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

enum ScreenState: Int {
    case add = 0, edit
}

enum AddNotificationRow: Int {
    case coin = 0, exchangeAndPair, currentPrice, intervalOptions, limitDirectionOptions, editLimitPrice, summary
}

enum IntervalSegmentedState: Int {
    case oneMinute = 0, fiveMinutes, fiftinMinutes, thirtyMinutes, oneHour, twoHours
}

class AddNotificationTVC: UITableViewController, UITextFieldDelegate {

    var intervalNotification: IntervalNotification?
    var limitNotification: LimitNotification?
    var notificationType: NotificationType = .IntervalNotification
    var screenState: ScreenState = .add
    var activityIndicatorView : NVActivityIndicatorView!
    let intervalSegmentedValues = [1000 * 60 * 1,
                                   1000 * 60 * 5,
                                   1000 * 60 * 15,
                                   1000 * 60 * 30,
                                   1000 * 60 * 60,
                                   1000 * 60 * 120]
    
    @IBOutlet weak var intervalSegmentedControl: UISegmentedControl!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var exchangeAndPairLabel: UILabel!
    @IBOutlet weak var priceDescriptionLabel: UILabel!
    @IBOutlet weak var priceLimitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var enterAmountTextField: UITextField!
    
    @IBOutlet weak var exchangeAndPairCell: UITableViewCell!
    @IBOutlet weak var intervalOptionsCell: UITableViewCell!
    @IBOutlet weak var limitDirectionOptionsCell: UITableViewCell!
    @IBOutlet weak var enterAmountCell: UITableViewCell!
    @IBOutlet weak var descriptionActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = addButton()
        
        setIntervalSegmentedControlUI()
        setPriceLimitSegmentedControlUI()
        
        enterAmountTextField.attributedPlaceholder = NSAttributedString(string: "Enter Amount",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        enterAmountTextField.delegate = self
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 400) , type: .ballClipRotateMultiple, color: .white, padding: 140)
        
        
        if let intervalNotification = intervalNotification {
            
            coinNameLabel.text = intervalNotification.name
            intervalSegmentedControl.selectedSegmentIndex = intervalSegmentedValues.index(of: intervalNotification.interval)!
            summaryLabel.text = intervalNotification.notificationDescription()
            
            NetworkManager.shared.getPriceFor(fsym: intervalNotification.fsym, tsym: intervalNotification.tsym) { [unowned self] (price)  in
                
                self.descriptionActivityIndicator.stopAnimating()
                self.priceDescriptionLabel!.text = "1 \(intervalNotification.fsym) is now worth \(price.priceFormat()) \(intervalNotification.tsym) on Global Average"
                
            }
        }
        else if let limitNotification = limitNotification {
            coinNameLabel.text = limitNotification.name
            enterAmountTextField.text = screenState == .add ? "" : String(limitNotification.limit)
            summaryLabel.text = limitNotification.notificationDescription()
            
            if limitNotification.direction == "biggerThan" {
                priceLimitSegmentedControl.selectedSegmentIndex = 0
            }
            else {
                priceLimitSegmentedControl.selectedSegmentIndex = 1
            }
                
            NetworkManager.shared.getPriceFor(fsym: limitNotification.fsym, tsym: limitNotification.tsym) { [unowned self] (price)  in
                
                self.descriptionActivityIndicator.stopAnimating()
                self.priceDescriptionLabel!.text = "1 \(limitNotification.fsym) is now worth \(price.priceFormat()) \(limitNotification.tsym) on Global Average"
                
            }
        }

    }

    // MARK: GUI
    func setIntervalSegmentedControlUI() {
        intervalSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        intervalSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
    }
    func setPriceLimitSegmentedControlUI() {
        priceLimitSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        priceLimitSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if (cell == exchangeAndPairCell) {
                showExchangeAnPairAlert()
        }
    }
    
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {

        let addNotificationRow = AddNotificationRow(rawValue: indexPath.row)

        if (notificationType == .IntervalNotification) {
            switch addNotificationRow {
            case .limitDirectionOptions, .editLimitPrice:
                return 0
            case .summary:
                return 80
            default:
               return 54
            }
        }
        else {
            switch addNotificationRow {
            case .intervalOptions:
                return 0
            case .summary:
                return 80
            default:
               return 54
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    
    func showExchangeAnPairAlert() {
        let alert = UIAlertController(title: "Exchange & Pair Selection", message: "Exchange & Pair selection will be available in the next few updates", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    func addButton() -> UIButton {
        // Create UIButton
        let addButton = UIButton(type: .system)
        addButton.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50)
        addButton.backgroundColor = UIColor.orange
        let title = screenState == .add ? "Add Alert" : "Update Alert"
        addButton.setTitle(title, for: .normal)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)

        addButton.addTarget(self, action: #selector(addNotification), for: .touchUpInside)
        
        return addButton
    }
    
    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == enterAmountTextField) {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }

            // add their new text to the existing text
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            if let number = Double(updatedText) {
                limitNotification!.limit = number
            }
            else {
                limitNotification!.limit = 0
            }
            
            summaryLabel.text = limitNotification?.notificationDescription()

        }
        
        return true
    }
    
    @objc func addNotification() {
        
        // Make sure there is amount in the textField in case of LimitNotification
        if notificationType == .LimitNotification {
            if enterAmountTextField.text?.count == 0 {
                let alert = UIAlertController(title: "Please Enter Amount", message:"" , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                
                return
            }
        }
        
        showActivityIndicator()

        if screenState == .add {
            
            NetworkManager.shared.createNotification(intervalNotification:
                intervalNotification, limitNotification: limitNotification,
            onSuccess: { (successMessage) in
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.navigationController?.popViewController(animated: true)
                    self.hideActivityIndicator()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    let alert = UIAlertController(title: "Create Notification", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }

            }
        }
        
        else if screenState == .edit {
            NetworkManager.shared.updateNotification(intervalNotification:
                intervalNotification, limitNotification: limitNotification,
            onSuccess: { (successMessage) in
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.navigationController?.popViewController(animated: true)
                    self.hideActivityIndicator()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    let alert = UIAlertController(title: "Create Notification", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }

            }
        }

    }

    

    
    // MARK: - IBActions
    @IBAction func intervalSegmentedControlValueChanged(_ sender: Any) {
        
        let segmentedControl = sender as! UISegmentedControl
        intervalNotification!.interval = intervalSegmentedValues[segmentedControl.selectedSegmentIndex]
        summaryLabel.text = intervalNotification?.notificationDescription()
        
        print("intervalNotification?.interval \(intervalNotification!.interval)")
        
    }
    @IBAction func limitDirectionSegmentedControlValueChanged(_ sender: Any) {
       
        let segmentedControl = sender as! UISegmentedControl
        
        if segmentedControl.selectedSegmentIndex == 0 {
            limitNotification?.direction = "biggerThan"
        }
        else {
            limitNotification?.direction = "smallerThan"
        }
        
        summaryLabel.text = limitNotification?.notificationDescription()
        print("limitNotification?.direction = \(limitNotification!.direction)")
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

