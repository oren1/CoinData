//
//  ValidateAppleReceiptTest.swift
//  ZZBitRateTests
//
//  Created by oren shalev on 30/11/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import XCTest
@testable import ZZBitRate

class ValidateAppleReceiptTest: XCTestCase {
    var userDefaults: UserDefaults!

    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        userDefaults = UserDefaults(suiteName: "AppleReceiptTest")!
        userDefaults.removePersistentDomain(forName: "AppleReceiptTest")

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    

    func test_ValidateReceiptProduct_IsValid_OnProduction() {
        
        let tomorrow = Date().timeIntervalSince1970 + (1000 * 60 * 60 * 24)
        let yesterday = Date().timeIntervalSince1970 - (1000 * 60 * 60 * 24)

        let receipt = [
            "latest_receipt_info": [
                    
                        ["product_id": CoinDataProducts.everyMonthSubscription,
                         "expires_date_ms": String(yesterday * 1000)],
                        
                        ["product_id": CoinDataProducts.everyMonthSubscription,
                         "expires_date_ms": String(tomorrow * 1000)]
                    
                ]
        ]
        
        self.userDefaults.set(true, forKey: CoinDataProducts.everyMonthSubscription)
        MockNetworkManager.receipt = receipt
        MockNetworkManager.shared.validateAppleReceiptsAndUpdateUserDefaults(userDefaults: userDefaults) {
            let productValid = self.userDefaults.bool(forKey: CoinDataProducts.everyMonthSubscription)
            
            XCTAssertEqual(productValid, true)
        }
        
    }
    
    func test_ValidateReceiptProduct_NotValid_OnProduction() {
        
        let yesterday = Date().timeIntervalSince1970 - (1000 * 60 * 60 * 24)

         let receipt = [
             "latest_receipt_info": [
                     
                         ["product_id": CoinDataProducts.everyMonthSubscription,
                          "expires_date_ms": String(yesterday * 1000)],
                         
                         ["product_id": CoinDataProducts.everyMonthSubscription,
                          "expires_date_ms": String(yesterday * 1000)]
                     
                 ]
         ]
        
        self.userDefaults.set(true, forKey: CoinDataProducts.everyMonthSubscription)
        MockNetworkManager.receipt = receipt
        MockNetworkManager.shared.validateAppleReceiptsAndUpdateUserDefaults(userDefaults: userDefaults) {
            let productValid = self.userDefaults.bool(forKey: CoinDataProducts.everyMonthSubscription)
            
            XCTAssertEqual(productValid, false)
        }
        
    }
    
    
}


class MockNetworkManager: NetworkManager {
    
    static var receipt: [String: Any]!
    
    override func validateReceipts(withUrl url: URL, completion: @escaping ([String : Any]) -> ()) {

        
        let data = try! JSONSerialization.data(withJSONObject: MockNetworkManager.receipt, options: [])
        
        //2. Send it to the parser
        parsingManager.shared.parseValidateReceipt(data: data) { (success, dictionary) in
            completion(dictionary!)
        }
    }
}
