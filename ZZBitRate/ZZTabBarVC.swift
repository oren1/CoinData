//
//  ZZTabBarVC.swift
//  ZZBitRate
//
//  Created by aviza on 21/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase


class ZZTabBarVC: UITabBarController, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    let remoteConfig = RemoteConfig.remoteConfig()
    
    var adsRate = 150
    //var timer : Timer?

    var timer : Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("coinDataServiceUrl = \(NetworkManager.shared.coinDataServiceUrl)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("applicationDidBecomeActive"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("applicationDidEnterBackground"), object: nil)

        
//        //debug mode this
//        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
//        remoteConfig.configSettings = remoteConfigSettings!

         let defaultValues = ["adsRateInSeconeds": 150 as NSObject]
         remoteConfig.setDefaults(defaultValues)
        
        fatchRemoteValuesForFireBase()
        
        makeAdsLogicIfAdsAllowed()

    }
    
    func fatchRemoteValuesForFireBase() {
        remoteConfig.fetch() {[weak self] (status,error) in
            guard error == nil else {
                print("error fatchRemoteValuesForFireBase")
                return
            }

            print("Yay!!!   fatchRemoteValuesForFireBase")
            self?.remoteConfig.activateFetched()

            if let adsRateInSeconeds = self?.remoteConfig.configValue(forKey: "adsRateInSeconeds").numberValue?.floatValue {
                self?.adsRate = Int(adsRateInSeconeds)
            }
        }
        
        //debug mode
//        remoteConfig.fetch(withExpirationDuration: 0) { [weak self] (status, error) -> Void in
//            if status == .success {
//                print("Config fetched!")
//                self.remoteConfig.activateFetched()
//            } else {
//                print("Config not fetched")
//                print("Error: \(error?.localizedDescription ?? "No error available.")")
//            }
//
//
//            if let adsRateInSeconeds = self?.remoteConfig.configValue(forKey: "adsRateInSeconeds").numberValue?.floatValue {
//                self?.adsRate = Int(adsRateInSeconeds)
//                // print("adsRate = \(self?.adsRate)")
//            }
//        }
    }
    
    func startTimer () {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.tik), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
      timer = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
 
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        timer = nil
        
    }
    
    func showError(errorDescription: String)  {
        let alert = UIAlertController(title: "verifyReceipt", message: errorDescription, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "OK", style: .default, handler: nil) )
        present(alert, animated: true, completion: nil)
    }
    
    @objc func tik() {
        
        if UserDataManager.shared.timeFromLastAd >= adsRate {
            print("Ads Timer : Show time     adsRate = \(adsRate)")
           UserDataManager.shared.timeFromLastAd = 0
           showTime()
        }
        else {
 
            UserDataManager.shared.timeFromLastAd += 2
            print("Ads Timer , timeFromLastAd = \(UserDataManager.shared.timeFromLastAd)    adsRate = \(adsRate)")
        }
      
        
    }
    
    func showTime() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func methodOfReceivedNotification(notification: Notification){
        if notification.name.rawValue == "applicationDidBecomeActive" {
            print("$$$$$$ applicationDidBecomeActive ")
            
            makeAdsLogicIfAdsAllowed()

        }
        else if notification.name.rawValue == "applicationDidEnterBackground" {
            stopTimer()
            print("$$$$$$ applicationDidEnterBackground")
        }
    }
    
    func makeAdsLogicIfAdsAllowed() {
        let defaults = UserDefaults.standard
        let launching = defaults.integer(forKey: "NumberOfLaunching")
        print("did Received Notification launching : \(launching)")
        
        if !UserDataManager.shared.purchasedProVersion() {
            if launching > 5 {
                UserDataManager.shared.ad_intersial_on = true
            }

            if launching > 2 {
                UserDataManager.shared.ad_Banner_on = true
            }

            if UserDataManager.shared.ad_intersial_on == true {
                createAndLoadInterstitial()
                startTimer()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func createAndLoadInterstitial()  {
        
         interstitial = GADInterstitial(adUnitID: "ca-app-pub-1322650429791760/1063072996")
        // Do any additional setup after loading the view.
        
        let request = GADRequest()
       // request.testDevices = ["9ae9935b6671e4c340f4c8929f83c8ad3c207cb2","df3fa193117750f0704f04679ee80e20","85631549b891bb61fca715fac477ad6eb8df8253"]

        interstitial.load(request)
        interstitial.delegate = self
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
    
        UserDataManager.shared.timeFromLastAd = 0
        
        createAndLoadInterstitial()

    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }

}
