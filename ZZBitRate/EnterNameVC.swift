//
//  EnterNameVC.swift
//  ZZBitRate
//
//  Created by oren shalev on 12/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class EnterNameVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    var activityIndicatorView : NVActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
        selector: #selector(handle(keyboardShowNotification:)),
        name: NSNotification.Name.UIKeyboardWillShow,
        object: nil)
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(handle(keyboardHideNotification:)),
        name: NSNotification.Name.UIKeyboardWillHide,
        object: nil)
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 400) , type: .ballClipRotateMultiple, color: .white, padding: 140)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
   

    @IBAction func addButtonTapped(_ sender: Any) {
        
        guard let name = nameTextField.text, name.count > 0 else {
            showError(error: "Please Enter Name")
            return
        }
        
        if let user = User.user() {
            
            let params = ["userId":user.userId, "type": PortfolioType.Manual.rawValue, "name": name]

            showActivityIndicator()
            
            NetworkManager.shared.addPortfolio(params: params) { [weak self] (error, successMessage) in
                self?.hideActivityIndicator()
                
                if let error = error {
                    self?.showError(error: error.localizedDescription)
                }
                else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    @objc private func handle(keyboardShowNotification notification: Notification) {

        if let userInfo = notification.userInfo,
            let keyboardRectangle = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            self.view.frame.size.height = self.view.frame.size.height - keyboardRectangle.height
            self.view.layoutIfNeeded()
        }
    }

    @objc private func handle(keyboardHideNotification notification: Notification) {

        if let userInfo = notification.userInfo,
            let keyboardRectangle = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            self.view.frame.size.height = self.view.frame.size.height + keyboardRectangle.height
            self.view.layoutIfNeeded()
        }
    }
    
    func showError(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
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
