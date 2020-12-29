//
//  FetchSettingsTest.swift
//  ZZBitRateTests
//
//  Created by oren shalev on 17/12/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import XCTest
@testable import ZZBitRate
import RealmSwift

class FetchSettingsTest: XCTestCase {

    var realm: Realm!
    
    override func setUp() {
        MockUserDataManager.settingsJSON = nil
        // Put setup code here. This method is called before the invocation of each test method in the class.
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

    
    func testSettings_NotExists() {
        XCTAssertTrue(MockUserDataManager.manager.needToFetchAllData())
    }
    
    func testSettings_DontNeedToFetch() {
        MockUserDataManager.settingsJSON = ["success":true,
                "message": "message",
                "data":[
                    "maxAmountOfIntervalNotification": 2,
                    "maxAmountOfLimitNotification":3,
                    "maxAmountOfPortfolios":3,
                    "fetchDataTimeInMiliSeconds": (Date().timeIntervalSince1970 + (1000 * 60 * 5)) * 1000
                ]
        ] as [String: Any]
        
        XCTAssertFalse(MockUserDataManager.manager.needToFetchAllData())
    }
    
    func testSettings_NeedToFetch() {
        MockUserDataManager.settingsJSON = ["success":true,
                "message": "message",
                "data":[
                    "maxAmountOfIntervalNotification": 2,
                    "maxAmountOfLimitNotification":3,
                    "maxAmountOfPortfolios":3,
                    "fetchDataTimeInMiliSeconds": (Date().timeIntervalSince1970 - (1000 * 60 * 5)) * 1000
                ]
        ] as [String: Any]
        
        XCTAssertTrue(MockUserDataManager.manager.needToFetchAllData())
    }
}


class MockUserDataManager: UserDataManager {
     static let manager = MockUserDataManager()
    
    static var settingsJSON: [String: Any]?
    override var settings: Settings? {
            if let json = MockUserDataManager.settingsJSON {
                let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TestRealm"))
                let data = try! JSONSerialization.data(withJSONObject: json, options: [])
                try! parsingManager.shared.parseSettings(data: data, realm: realm)
                
                let settings = realm.objects(Settings.self)
                
                return settings[0]
            }
            else {
                return nil
            }
        
    }
}
