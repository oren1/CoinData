//
//  BannerViewController.swift
//  ZZBitRate
//
//  Created by aviza on 03/01/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import UIKit

import GoogleMobileAds


class BannerViewController: UIViewController, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    @IBOutlet weak var bannerContainerView: UIView!
    @IBOutlet weak var BannerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDataManager.shared.ad_Banner_on == true {
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-1322650429791760/1747143862"
        bannerView.rootViewController = self
        addBannerViewToView(bannerView)
        let request = GADRequest()
        //request.testDevices = ["9ae9935b6671e4c340f4c8929f83c8ad3c207cb2","df3fa193117750f0704f04679ee80e20","85631549b891bb61fca715fac477ad6eb8df8253"]
        bannerView.load(request)
        bannerView.delegate = self
        }

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDataManager.shared.ad_Banner_on == false {
            BannerHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        else {
            BannerHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Ad mob
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerContainerView.addSubview(bannerView)
        
        
        self.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self.bannerContainerView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: self.bannerContainerView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }

}
