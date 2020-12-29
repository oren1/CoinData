//
//  AppDelegate.swift
//  ZZBitRate
//
//  Created by aviza on 11/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import FBSDKCoreKit
import UserNotifications
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
//running on my minimac
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
        schemaVersion: 2,
        migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
                migration.renameProperty(onType: PermissionKey.className(), from: "supportsQR", to: "supportQR")
            }
            if (oldSchemaVersion < 2) {
                
            }
        })
        
        createUserIfNotExists()

        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(0, forKey: "NumberOfLaunching")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            
            
//            CoreDataManager.shared.createNewHolding(amount: 1.0, coinName: "Bitcoin", coinNameId: "BTC")
//            CoreDataManager.shared.createNewHolding(amount: 20.0, coinName: "Ethereum", coinNameId: "ETH")
//            CoreDataManager.shared.createNewHolding(amount: 15.0, coinName: "Litecoin", coinNameId: "LTC")

        }
      

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        window?.tintColor = .orange
        
        //FireBase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        //Ad mob
        //App ID: ca-app-pub-1322650429791760~7388808193
        
        //banner ca-app-pub-1322650429791760/1747143862
        
        //intertitial ca-app-pub-1322650429791760/1063072996
        
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1322650429791760~7388808193")

        
        registerForPushNotifications()

        
        // Handle push notification
        let center  = UNUserNotificationCenter.current()
        center.delegate = self

        let notificationOption = launchOptions?[.remoteNotification]

        if let notification = notificationOption as? [String: AnyObject],
          let aps = notification["aps"] as? [String: AnyObject] {
          
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
        
        
        // 
//        IAPManager.shared.startObserving()



        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
      print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
       print("app state: applicationDidEnterBackground")
        
         NotificationCenter.default.post(name: Notification.Name("applicationDidEnterBackground"), object: nil)
        
        SocketIOManager.shared.closeConnection()
        
        let defaults = UserDefaults.standard
        defaults.set(UserDataManager.shared.timeFromLastAd, forKey: "timeFromLastAd")
        print("applicationDidEnterBackground : timeFromLastAd = \(UserDataManager.shared.timeFromLastAd)")

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("app state: applicationWillEnterForeground")
        // If the user didn't approve notification in the first time then he will not have a 'token'.
        // if he dont have a token then always check if he changed hes settings to allow it.
        // and when he allows it request a token from apple and sent it to CoinData Server.
        if User.user()?.token.count == 0 {
            getNotificationSettings()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        
        print("app state: applicationDidBecomeActive")

        
        let defaults = UserDefaults.standard
        var launching = defaults.integer(forKey: "NumberOfLaunching")
        launching += 1
        defaults.set(launching, forKey: "NumberOfLaunching")
        print("launching : \(launching)")
        
        let s = defaults.integer(forKey: "timeFromLastAd")
        UserDataManager.shared.timeFromLastAd = s
                print("applicationDidBecomeActive : timeFromLastAd = \(s)")

 
        
        NotificationCenter.default.post(name: Notification.Name("applicationDidBecomeActive"), object: nil)


       // SocketIOManager.shared.establishConnection()
        
        AppEvents.activateApp()

    }
    
 

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let defaults = UserDefaults.standard
        defaults.set(UserDataManager.shared.timeFromLastAd, forKey: "timeFromLastAd")
        print("applicationWillTerminate : timeFromLastAd = \(UserDataManager.shared.timeFromLastAd)")
        
        //CoreDataManager.shared.saveContext()
        
//        IAPManager.shared.stopObserving()


    }
    

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    
    func hardeCodedImagesDict() {

    }
    
    func createUserIfNotExists() {
        
        if (User.user() == nil) {
            NetworkManager.shared.createUserSync {}
        }
    }

}

// MARK: Push Notification Logic
extension AppDelegate {
    

     func registerForPushNotifications() {
       UNUserNotificationCenter.current()
         .requestAuthorization(options: [.alert, .sound, .badge]) {
           [weak self] granted, error in
             
           print("Permission granted: \(granted)")
           guard granted else { return }
           self?.getNotificationSettings()
       }

     }

     func getNotificationSettings() {
       UNUserNotificationCenter.current().getNotificationSettings { settings in
         
         print("Notification settings: \(settings)")
         guard settings.authorizationStatus == .authorized else { return }
         DispatchQueue.main.async {
           UIApplication.shared.registerForRemoteNotifications()
         }

       }
     }

     
     // MARK: Push Notification Delegate
     func application(
       _ application: UIApplication,
       didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
     ) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
         
         if let user = User.user() {
             print("user: \(user)")
             NetworkManager.shared.updateUserToken(userId: user.userId, token: token)
         }
         
        print("Device Token: \(token)")
     }

     func application(
       _ application: UIApplication,
       didFailToRegisterForRemoteNotificationsWithError error: Error) {
       print("Failed to register: \(error)")
     }

    
     func application(
       _ application: UIApplication,
       didReceiveRemoteNotification userInfo: [AnyHashable: Any],
       fetchCompletionHandler completionHandler:
       @escaping (UIBackgroundFetchResult) -> Void
     )
     {
        print("didReceiveRemoteNotification")
       guard let aps = userInfo["aps"] as? [String: AnyObject] else {
         completionHandler(.failed)
         return
       }

            if (application.applicationState == .active) {
                if let user = User.user() {
                    NetworkManager.shared.getNotifications(userId: user.userId)
                }
            }
        
        if let alert = aps["alert"] as? String {
            let alert = UIAlertController(title: alert, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.window?.rootViewController?.present(alert, animated: true, completion: {
            })
        }

         if aps["content-available"] as? Int == 1 {

             // Fetch the new content and finish with the completion handler
             completionHandler(.newData)
             
         } else  {
             
             completionHandler(.newData)
         }

     }
    
}

// MARK: Firebase Messaging Delegate
extension AppDelegate : MessagingDelegate {

    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print("Firebase registration token: \(fcmToken)")

      let dataDict:[String: String] = ["token": fcmToken]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      
        // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
}


