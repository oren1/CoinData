//
//  AddExchangeTVC.swift
//  ZZBitRate
//
//  Created by oren shalev on 14/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import RealmSwift
import NVActivityIndicatorView

enum AddPortfolioRow: Int {
    case portfolioName = 0, exchangeName, description, userId, apiKey, apiSecret
}

class AddPortfolioTVC: UITableViewController, ScannerVCDelegate {

    @IBOutlet weak var portfolioNameTextField: UITextField!
    @IBOutlet weak var exchangeNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var instructionsButton: UIButton!
    @IBOutlet weak var descriptionTVCell: UITableViewCell!
    
    // MARK: UserId Permission Key
    @IBOutlet weak var userIdTVCell: UITableViewCell!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var userIdQRButton: UIButton!
    
    //MARK: ApiKey Permission Key
    @IBOutlet weak var apiKeyTVCell: UITableViewCell!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var apiKeyQRButton: UIButton!
    
    // MARK: ApiSecret Permission Key
    @IBOutlet weak var apiSecretTVCell: UITableViewCell!
    @IBOutlet weak var apiSecretTextField: UITextField!
    @IBOutlet weak var apiSecretQRButton: UIButton!
    
    var activityIndicatorView : NVActivityIndicatorView!

    
    var exchange: Exchange!
    weak var delegate: AddExchangeDelegeate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 400) , type: .ballClipRotateMultiple, color: .white, padding: 140)
        
        let whitePlaceholderText = NSAttributedString(string: "Enter Portfolio Name",
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray.withAlphaComponent(0.6)])
        portfolioNameTextField.attributedPlaceholder = whitePlaceholderText
        exchangeNameLabel.text = exchange.name
        let attributedTitleString = NSAttributedString(string: "Instructions to create \(exchange.name) keys", attributes: [NSAttributedString.Key.underlineColor: UIColor.orange, NSAttributedString.Key.underlineStyle: 1])
        instructionsButton.setAttributedTitle(attributedTitleString, for: .normal)
        setPermissionKeyCells()
    }

    // MARK: - Custom Logic
    func appendPermissionKeys(permissionKeys: [String:String]){
        if let _ = exchange.getPermissionKeyObjectForKey(keyType: .userId) {
            let userId = permissionKeys["userId"]
            userIdTextField.text = userId
        }
        
        if let _ = exchange.getPermissionKeyObjectForKey(keyType: .apiKey) {
            let apiKey = permissionKeys["apiKey"]
            apiKeyTextField.text = apiKey
        }
        
        if let _ = exchange.getPermissionKeyObjectForKey(keyType: .apiSecret) {
            let apiSecret = permissionKeys["apiSecret"]
            apiSecretTextField.text = apiSecret
        }
    }
    
    func validateParams() throws {
        if portfolioNameTextField.text?.count == 0 {
            throw NSError(domain: "validationError", code: 0, userInfo: [NSLocalizedDescriptionKey:"Portfolio name missing"])
        }
        
        if let _ = exchange.getPermissionKeyObjectForKey(keyType: .userId) {
            if userIdTextField.text?.count == 0 {
            throw NSError(domain: "validationError", code: 0, userInfo: [NSLocalizedDescriptionKey:"User id missing"])
            }
        }
        
        if let _ = exchange.getPermissionKeyObjectForKey(keyType: .apiKey) {
            if apiKeyTextField.text?.count == 0 {
            throw NSError(domain: "validationError", code: 0, userInfo: [NSLocalizedDescriptionKey:"Api Key missing"])
            }
        }
        
        if let _ = exchange.getPermissionKeyObjectForKey(keyType: .apiSecret) {
            if apiSecretTextField.text?.count == 0 {
            throw NSError(domain: "validationError", code: 0, userInfo: [NSLocalizedDescriptionKey:"Api Secret missing"])
            }
        }
    }
    
    func sendAddPortfolioRequest() {
        do {
            try validateParams()
            if let userId = User.user()?.userId {
                var params = [
                    "type": "exchange",
                    "userId": userId,
                    "name": portfolioNameTextField.text!,
                    "exchangeName": exchange.keyName,
                ]
                if let _ = exchange.getPermissionKeyObjectForKey(keyType: .userId) {
                    params["apiUserId"] = userIdTextField.text!
                }
                
                if let _ = exchange.getPermissionKeyObjectForKey(keyType: .apiKey) {
                    params["apiKey"] = apiKeyTextField.text!
                }
                
                if let _ = exchange.getPermissionKeyObjectForKey(keyType: .apiSecret) {
                    params["apiSecret"] = apiSecretTextField.text!
                }
                
                showActivityIndicator()
                NetworkManager.shared.addPortfolio(params: params) { [weak self] (error, successMessage) in
                    self?.hideActivityIndicator()
                    if let error = error {
                        self?.showError(error: error)
                    }
                    else {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }

                }
            }

            
        } catch {
            showError(error: error)
        }
    }
    
    
    // MARK: - UI
    func setPermissionKeyCells() {
        if let userIdPermission = exchange.getPermissionKeyObjectForKey(keyType: .userId) {
            let userIdPlaceHolder = NSAttributedString(string: userIdPermission.keyTitle,
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray.withAlphaComponent(0.6)])
            userIdTextField.attributedPlaceholder = userIdPlaceHolder
            userIdQRButton.isHidden = userIdPermission.supportQR ? false : true
        }
        
        if let apiKeyPermission = exchange.getPermissionKeyObjectForKey(keyType: .apiKey) {
            let apiKeyPlaceHolder = NSAttributedString(string: apiKeyPermission.keyTitle,
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray.withAlphaComponent(0.6)])
            apiKeyTextField.attributedPlaceholder = apiKeyPlaceHolder
            apiKeyQRButton.isHidden = apiKeyPermission.supportQR ? false : true
        }
        
        if let apiSecretPermission = exchange.getPermissionKeyObjectForKey(keyType: .apiSecret) {
            let apiSecretPlaceHolder = NSAttributedString(string: apiSecretPermission.keyTitle,
                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray.withAlphaComponent(0.6)])
            apiSecretTextField.attributedPlaceholder = apiSecretPlaceHolder
            apiSecretQRButton.isHidden = apiSecretPermission.supportQR ? false : true
        }
    }
    
    func showActivityIndicator() {
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
    }
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        let portfolioRow = AddPortfolioRow(rawValue: indexPath.row)
        
        switch portfolioRow {
        case .description:
            return 100
        case .userId:
            if let _ = exchange.getPermissionKeyObjectForKey(keyType: .userId) {
                return 54
            }
            return 0
        case .apiKey:
            if let _ = exchange.getPermissionKeyObjectForKey(keyType: .apiKey) {
                return 54
            }
            return 0
        case .apiSecret:
            if let _ = exchange.getPermissionKeyObjectForKey(keyType: .apiSecret) {
                return 54
            }
            return 0
        default:
            return 54
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func didEndScannongWithCode(code: String) {
        print("code: \(code)")
        NetworkManager.shared.parseQRCode(exchangeName: exchange.keyName, code: code, onSuccess: { [weak self] (keysDic) in
            self?.dismiss(animated: true, completion: nil)
            self?.appendPermissionKeys(permissionKeys: keysDic)
        }) { [weak self] (error) in
            self?.dismiss(animated: true, completion: nil)
            self?.showError(error: error)
        }
    }

    // MARK: IBAction
    @IBAction func qrCodeButtonTaped(_ sender: Any) {
        let scannerVC = ScannerViewController(nibName: nil, bundle: nil)
        scannerVC.view.frame = self.view.bounds
        scannerVC.delegate = self
        present(scannerVC, animated: true)
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        sendAddPortfolioRequest()
    }
    
    @IBAction func instructionsButtonTapped(_ sender: Any) {
        
        let instructionsString = exchange.instructions.joined(separator: "")
        let attributedString = NSAttributedString(string: instructionsString, attributes: [NSAttributedStringKey.font:  UIFont.boldSystemFont(ofSize: 18)])

        let alert = UIAlertController(title: "Instructions", message: "attributedString", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        alert.setValue(attributedString, forKey: "attributedMessage")
        present(alert, animated: true)
        
        
    }

    


}
