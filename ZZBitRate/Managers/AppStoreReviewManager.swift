//
//  AppStoreReviewManager.swift
//  ZZBitRate
//
//  Created by avi zazati on 08/10/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation

import StoreKit

enum AppStoreReviewManager {
    
  static let minimumReviewWorthyActionCount = 1

  static func requestReviewIfAppropriate() {
    // Add Refresh Control to Table View
     if #available(iOS 10.3, *) {
         //SKStoreReviewController.requestReview()
        
        let defaults = UserDefaults.standard
        let bundle = Bundle.main

        // 2.
        var actionCount = defaults.integer(forKey: "reviewWorthyActionCount")

        // 3.
        actionCount += 1

        // 4.
        defaults.set(actionCount, forKey: "reviewWorthyActionCount")

        // 5.
        guard actionCount >= minimumReviewWorthyActionCount else {
          return
        }

        // 6.
        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: "lastReviewRequestAppVersion")

        // 7.
        /*
         Read the current bundle version and the last bundle version used during the last prompt (if any).
         Check if this is the first request for this version of the app before continuing.
         **/
        
        guard lastVersion == nil || lastVersion != currentVersion else {
          return
        }

        // 8.
        //this line will pop the rate us alert
        SKStoreReviewController.requestReview()

        // 9.
        defaults.set(0, forKey: "reviewWorthyActionCount")
        defaults.set(currentVersion, forKey: "lastReviewRequestAppVersion")

     }
  }
}

/*
 
 Note: The Submit button will appear grayed out since you are in development mode. It will appear enabled for users using your app through the App Store.
 
 Apple does enforce certain limitations on how you use this API:

 No matter how many times you request the review prompt, the system will show the prompt a maximum of three times in a 365-day period.
 Calling the method is not a guarantee that the prompt will display. This means that it’s not appropriate to call the API in response to a button tap or other user action.
 The system must not have shown the prompt for a version of the app bundle that matches the current bundle version. This ensures that the user is not asked to review the same version of your app multiple times.
 Note: The review prompt will behave differently depending on the type of build that you are running:
 Development: Shown every time the you request the prompt.
 Test Flight: Prompt is never shown.
 App Store: Shown with the limitations described above.
 
 */
