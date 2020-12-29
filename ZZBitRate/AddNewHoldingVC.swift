//
//  AddNewHoldingVC.swift
//  ZZBitRate
//
//  Created by avi zazati on 31/08/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


protocol AddNewHoldingDelegate: class {
    func doneEditing()
}

class AddNewHoldingVC: UIViewController,UITextFieldDelegate {

    var coinNameID: String?
    var coinName: String?
    var portfolio: Portfolio!
    weak var addNewHoldingDelegate: AddNewHoldingDelegate?
    weak var delegate: ChooceCoinTVCDelegate?

    @IBOutlet weak var massageLabel1: UILabel!
    @IBOutlet weak var massageLabel2: UILabel!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.amountTextField.delegate = self
        
        if let nameID = coinNameID ,let name = coinName {
            
            self.title = "\(nameID)"
            
            //self.title = "\(coin.name) (\(coin.nameID))"
            self.massageLabel1.text = "Add \(name) to your Portfolio"
            self.massageLabel2.text = "How much ?"


            let imageUrl = UserDataManager.shared.imagesDict[nameID]
            if let imageUrl = imageUrl {
                let url = URL(string: imageUrl)
                coinImage.kf.setImage(with: url)
            }
            
            if let existingCoin = portfolio.fetchCoin(symbol: nameID) {
                print("existingCoin \(existingCoin)")

               // self.massageLabel1.text = "You have \(existingCoin.amount) of \(existingCoin.coinName)"
                
                self.massageLabel2.text = "New balance: ?"
                
                self.amountTextField.placeholder = "\(existingCoin.amount)"
            }
            else {
              print("No coin")
            }
            
        }
        

        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        customView.backgroundColor = UIColor.red
        let doneButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 100, y: 10, width: 100, height: 24))
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(didSelectAmount), for: .touchUpInside)
        customView.addSubview(doneButton)
        
        let cancelButton = UIButton(frame: CGRect(x: 8, y: 10, width: 80, height: 24))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        customView.addSubview(cancelButton)

        amountTextField.inputAccessoryView = customView
    }
    
    

    @IBAction func deleteButtonTapped(_ sender: Any) {
        if let nameID = coinNameID ,let name = coinName {

        let title = "\(nameID)"
        let message = "Are you sure you want to delete \(name) from your protfolio?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .blue
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
            
            DispatchQueue.main.async {
                CoreDataManager.shared.deleteUserHoldingWith(coinNameId: nameID)
                self.dismiss(animated: true, completion: nil)
             
            }
        }))
        
        self.present(alert, animated: true)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.amountTextField.becomeFirstResponder()
    }
    
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func didSelectAmount() {
        
        //self.amountTextField.resignFirstResponder()
        
        if let isnumberordouble = self.amountTextField.text?.isnumberordouble {
            if isnumberordouble {
                if let amount = Double(amountTextField.text!) {
                    
                    guard amount > 0.0 else {return}
                    if let nameID = coinNameID ,let _ = coinName {
                        // self.delegate?.didChooseCoinAndAmount(coin, amount: amount)
                        showActivityIndicarot()
                        if let _ = portfolio.fetchCoin(symbol: nameID) {
                            NetworkManager.shared.updateCoinBalance(portfolioId: portfolio._id, symbol: nameID, amount: amount) { [weak self] (error) in
                                self?.hideActivityIndicator()
                                if error != nil {
                                    self?.showmessage(message: error!.localizedDescription)
                                }
                                else {
                                    self?.addNewHoldingDelegate?.doneEditing()
                                }
                            }
                        }
                        else {
                            NetworkManager.shared.addCoinBalance(portfolioId: portfolio._id, symbol: nameID, amount: amount) { [weak self] (error) in
                                self?.hideActivityIndicator()
                                if error != nil {
                                    self?.showmessage(message: error!.localizedDescription)
                                }
                                else {
                                    self?.addNewHoldingDelegate?.doneEditing()
                                }
                            }
                        }
//                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else {
                
            }
        }
        
    }
    
    
    func showmessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    func showActivityIndicarot() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controlle
        
        if segue.identifier == "ChooesCoinPopOverSegue" {
            //performSegue(withIdentifier:"Popover", sender: self)
            let nav =  segue.destination as! UINavigationController

            
           // let vc = nav.viewControllers.first as! ChooceCoinTVC
            

        }
    }
    
    
    func didChooseCoin(_ coin : ZZCoinRate) {
        print(coin.nameID)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("string = \(string)")
        
        if string == "." {
            if (self.amountTextField.text?.contains("."))! {
                return false
            }
        }
        
        return true
    }

}

extension String  {
    var isnumberordouble: Bool { return Double(self) != nil }
}
