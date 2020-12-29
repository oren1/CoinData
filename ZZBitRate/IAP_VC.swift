//
//  IAP_VC.swift
//  ZZBitRate
//
//  Created by avi zazati on 31/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import StoreKit

class MyButton: UIButton {
    var myProduct: SKProduct?
}

class IAP_VC: UIViewController {

    @IBOutlet weak var popupView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
     func viewDidSetup() {
        
        
        // delegate?.willStartLongProcess()
      
//         IAPManager.shared.getProducts { (result) in
//
//             DispatchQueue.main.async {
//                // self.delegate?.didFinishLongProcess()
//
//
//                 switch result {
//                 case .success(let products): self.setupUI(products: products)
//                 case .failure(let error): print(error.errorDescription ?? "products error")
//                 }
//
//
//                 print("------------------myProducts")
//
//
//
//
//             }
//         }
     }
    
    func setupUI(products: [SKProduct]) {

//        for (index, p) in products.enumerated() {
//                        print("-------------  \(p.localizedTitle) --------------")
//                        print(p.localizedDescription)
//                        print(p.price)
//                        print(p.productIdentifier)
//                        print(IAPManager.shared.getPriceFormatted(for: p)!)
//                        print("---------------------------")
//
//
//
//            let button = MyButton(frame: CGRect(x: 10, y:100 + index * 100, width: 300, height: 80))
//            button.myProduct = p
//            let priceStr = IAPManager.shared.getPriceFormatted(for: p)
//            button.setTitle(p.localizedTitle + " " + priceStr! , for: .normal)
//            button.backgroundColor = UIColor.gray
//            button.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
//            self.popupView.addSubview(button)
//        }
        
        
    }
    
    @objc func pressButton(button: MyButton) {
        
        if let product = button.myProduct {
            showBuyAlert(product: product)
        }
        
    }
     
     
     func showBuyAlert(product: SKProduct) {
        
//        guard let price = IAPManager.shared.getPriceFormatted(for: product) else { return }
//           let alertController = UIAlertController(title: product.localizedTitle,
//                                                   message: product.localizedDescription,
//                                                   preferredStyle: .alert)
//
//           alertController.addAction(UIAlertAction(title: "Buy now for \(price)", style: .default, handler: { (_) in
//               // TODO: Initiate Purchase!
//            self.purchase(product: product)
//           }))
//
//           alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//           self.present(alertController, animated: true, completion: nil)
        
        


     }
    

//   func purchase(product: SKProduct) -> Bool {
////        if !IAPManager.shared.canMakePayments() {
////            return false
////        } else {
////
////            self.showLoading()
////            IAPManager.shared.buy(product: product) { (result) in
////                DispatchQueue.main.async {
////                    self.hideLoading()
////                    switch result {
////                    case .success(_): self.userJustMadePurchaseWithSuccess(product)
////                    case .failure(let error): self.showErrorPurchaseAlert(error)
////                    }
////                }
////            }
////
////        }
////
////        return true
//    }
    
    func userJustMadePurchaseWithSuccess(_ product:SKProduct) {
        //TODO:
        print("User just made a success purchase: \(product.productIdentifier) ")
        
    }
    
    func showErrorPurchaseAlert(_ error: Error) {
        let alertController = UIAlertController(title: "Error",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        
        
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
