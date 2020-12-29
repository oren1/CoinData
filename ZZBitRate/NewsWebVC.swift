//
//  NewsWebVC.swift
//  ZZBitRate
//
//  Created by aviza on 13/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import UIKit


class NewsWebVC: BannerViewController ,UIWebViewDelegate{
 

    var urlString : String?

    @IBOutlet weak var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
        if let urlString = urlString {
            
            self.showLoading()
            let url = URL(string: urlString);
            let request = URLRequest(url: url!);
            webview.loadRequest(request);
        }
 
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideLoading()
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
        self.hideLoading()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.hideLoading()
    }
    
   

}
