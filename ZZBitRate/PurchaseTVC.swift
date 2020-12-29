//
//  PurchaseTVC.swift
//  ZZBitRate
//
//  Created by oren shalev on 18/11/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import StoreKit
import NVActivityIndicatorView

class PurchaseTVC: UITableViewController {

    
    @IBOutlet weak var billedMonthlyView: UIView!
    @IBOutlet weak var billedYearlyView: UIView!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var purchaseDescriptionLabel: UILabel!
    @IBOutlet weak var purchaseDescriptionView: UIView!
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Get Pro Version"
        billedMonthlyView.makeRoundEdges()
        billedYearlyView.makeRoundEdges()
        discountView.makeCircle()
        
        setRestoreAttributedText()
        setPurchaseDescriptionText()
        
        
        activityIndicatorView = NVActivityIndicatorView(frame: (self.tabBarController?.view.bounds)!, type: .ballClipRotateMultiple, color: UIColor.white, padding: 150)
        activityIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseCompleted), name: .IAPManagerPurchaseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreCompleted), name: .IAPManagerRestoreNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: .IAPManagerPurchaseFailedNotification, object: nil)

        
    }


    // MARK: UI
    func setPurchaseDescriptionText() {
        
        purchaseDescriptionView.sizeToFit()
        purchaseDescriptionLabel.sizeToFit()
        purchaseDescriptionLabel.text = "Your iTunes Account wll be charged once you confirm your payment. Your subscription automatically renews. When this happens, the same iTunes Account as the initial purchase will be charged again with the same amount at the end of your current subscription period unless auto-renew have been turned off in your Apple ID Account settings at least 24 hours before the end of the current period. In case of a price increase, yout subscription will not automatically renew and you'll be notified via your Apple ID Account email address to opt-in for this increase. In case of a price decrease your subscription will still automatically renew unless specified otherwise in your Apple ID Account settings. turning off auto-renew or managing it, can be done at any time after purchase via your Apple ID Account settings."

    }
    
    func setRestoreAttributedText() {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle,
        ]
        
        let restoreText = "If you already purchased restore here"
        let attributedText = NSMutableAttributedString(string: restoreText, attributes: attributes)
        
        attributedText.addAttributes([NSAttributedString.Key.underlineStyle:1,
                                    NSAttributedString.Key.underlineColor: UIColor.white],
                                    range:NSRange(location: 0, length: restoreText.count))
        
        
        restoreButton.setAttributedTitle(attributedText, for: .normal)
    }
    
    // MARK: CustomLogic
    func getProductforIdentifier(products: [SKProduct], productIndentifier: ProductIdentifier) -> SKProduct? {
        for product in products {
            if product.productIdentifier == productIndentifier {
                return product
            }
        }
        return nil
    }
    
    func disableAds() {
        UserDataManager.shared.ad_intersial_on = false
        UserDataManager.shared.ad_Banner_on = false
        let tabBarVC = self.tabBarController as! ZZTabBarVC
        tabBarVC.stopTimer() // This is the timer that counts the seconds between every interstitial ad and when needed is showing the interstitial ad. stopping it means disabling interstitial ads.
    }
    
    // MARK: - IBActions
    @IBAction func monthlySubscriptionViewTap(_ sender: Any) {
        if CoinDataProducts.store.canMakePayments() {
           
            showActivityIndicator()
            CoinDataProducts.store.requestProducts { [weak self] (success, products) in
                if success {
                    guard let product = self?.getProductforIdentifier(products: products!, productIndentifier: CoinDataProducts.everyMonthSubscription) else {return}
                    
                    CoinDataProducts.store.buyProduct(product)
                }
                else {
                    self?.showProductRequestErrorAlert()
                }
            }
        }
        else {
            showCantMakePaymentAlert()
        }
    }
    
    @IBAction func yearlySubscriptionViewTap(_ sender: Any) {
        if CoinDataProducts.store.canMakePayments() {
            
            showActivityIndicator()
            CoinDataProducts.store.requestProducts { [weak self] (success, products) in
                if success {
                    guard let product = self?.getProductforIdentifier(products: products!, productIndentifier: CoinDataProducts.everyYearSubscription) else {return}
                    
                    CoinDataProducts.store.buyProduct(product)
                }
                else {
                    self?.showProductRequestErrorAlert()
                }
            }
            
        }
        else {
            showCantMakePaymentAlert()
        }
    }
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        showActivityIndicator()
        CoinDataProducts.store.restorePurchases()
    }
    
    func showCantMakePaymentAlert() {
        let alertController = UIAlertController(title: "Error", message: "Payment Not Available", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
    func showProductRequestErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Network Error try again later", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
 
    // MARK: - NotificationCenter Selectors
    @objc func purchaseCompleted(notification: Notification) {
        hideActivityIndicatorView()
        disableAds()
        let alertController = UIAlertController(title: "Purchase completed successfuly", message: "To enjoy pro version close and restart the app", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

    @objc func restoreCompleted(notification: Notification) {
        hideActivityIndicatorView()
        disableAds()
        let alertController = UIAlertController(title: "Restore completed successfuly", message: "To enjoy pro version close and restart the app", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func purchaseFailed(notification: Notification) {
        if let text = notification.object as? String {
            let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
        hideActivityIndicatorView()
    }
    
    // MARK: - ActivityIndicator
    func showActivityIndicator() {
        self.tabBarController?.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicatorView() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
    }
}
