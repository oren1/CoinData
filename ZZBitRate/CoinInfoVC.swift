//
//  CoinInfoVC.swift
//  ZZBitRate
//
//  Created by aviza on 31/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit

//import Fuzi

class CoinInfoVC: BannerViewController,UIWebViewDelegate {
    @IBOutlet weak var infoWebViewContainer: UIView!
    
    var coin : ZZCoinRate?
    
    @IBOutlet weak var CoinNameLabel: UILabel!
    @IBOutlet weak var coinImageView: UIImageView!
    
    var urlString : String?
    // @IBOutlet weak var webview: UIWebView!
    var webview: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview    = UIWebView()
        
        if let coin = coin {
            
            let imageUrl = UserDataManager.shared.imagesDict[coin.nameID]
            if let imageUrl = imageUrl {
                let url = URL(string: imageUrl)
                coinImageView.kf.setImage(with: url)
            }
            
            CoinNameLabel.text = "\(coin.name) (\(coin.nameID))"
            
            
            urlString = "https://www.cryptocompare.com/coins/" +
                "\(coin.nameID)" + "/overview"
            
            if let webview = webview {
                webview.delegate = self
                webview.tag = 123456
                if let urlString = urlString {
                    
                    self.showLoading()
                    let url = URL(string: urlString)
                    let request = URLRequest(url: url!)
                    webview.loadRequest(request)
                }
            }
        }
        
    }
    
    func getText() {
        //
        //        if let myString = String(data: data!, encoding: usedEncoding) {
        //            do {
        //                let doc = try HTMLDocument(string: HTML_FILE, encoding: NSUTF8StringEncoding)
        //
        //                for link in doc.css(".lyric-body") {
        //                    print(link.strigValue)
        //                }
        //
        //
        //            } catch let error {
        //                print(error)
        //            }
        //        } else {
        //            print("failed to decode data")
        //        }
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
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        print("webViewDidFinishLoad tag : \(webView.tag)")
        if webView.tag == 123456 {
            self.hideLoading()
            let coin_description = webView.stringByEvaluatingJavaScript(from: "document.getElementsByClassName('coin-description ng-binding')[0].innerHTML;")
            
            
            //print(coin_description!)
            
            if let coin_description = coin_description {
                
                if coin_description.count > 10 {
                    
                    let webV: UIWebView = UIWebView(frame:CGRect(x:0,
                                                                 y:0,
                                                                 width :(self.infoWebViewContainer.frame.size.width),
                                                                 height:(self.infoWebViewContainer.frame.size.height)))
                    
                    webV.loadHTMLString("\(String(describing: coin_description))", baseURL: nil)
                    webV.tag = 007
                    // webV.delegate = self;
                    self.infoWebViewContainer.addSubview(webV)
                    
                }
                else {
                   // showNoDataLabel()
                }
            }
      
            
        }
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        print("didFailLoadWithError tag : \(webView.tag)")
        
        self.hideLoading()
        //show error
        
       // showNoDataLabel()
        
    }
    
    func showNoDataLabel() {
        let noDataLabel = UILabel()
        noDataLabel.text = "Data not available."
        noDataLabel.textColor = .gray
        noDataLabel.textAlignment = .center
        noDataLabel.frame = CGRect(x:0,
                                   y:0,
                                   width :self.infoWebViewContainer.frame.size.width,
                                   height:self.infoWebViewContainer.frame.size.height)
        self.infoWebViewContainer.addSubview(noDataLabel)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        // let text = webView.stringByEvaluatingJavaScript(from: "document.getElementById('coin-description ng-binding').textContent=''")
        
        print("webViewDidStartLoad tag : \(webView.tag)")
        
        
    }
    
}

