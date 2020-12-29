//
//  AppStoreReceiptManager.swift
//  ZZBitRate
//
//  Created by oren shalev on 13/12/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import StoreKit

typealias VerifyReceiptCompletion = () -> ()

class AppStoreReceiptManager: NSObject, SKRequestDelegate {

    static let shared = AppStoreReceiptManager()
    private var request: SKReceiptRefreshRequest?
    var verifyReceiptCompletion: VerifyReceiptCompletion?
    
    
    func verifyReceipt(verifyReceiptCompletion: @escaping VerifyReceiptCompletion) {
        request?.cancel()
        self.verifyReceiptCompletion = verifyReceiptCompletion
        request = SKReceiptRefreshRequest()
        request!.delegate = self
        request!.start()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("App Store Receipt Updated!")
        NetworkManager.shared.validateAppleReceiptsAndUpdateUserDefaults(userDefaults: UserDefaults.standard) { [weak self] in
            self?.verifyReceiptCompletion?()
        }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("App Store Receipt Error: \(error)")
    }
}
