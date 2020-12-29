//
//  MyStringItemSource.swift
//  ZZBitRate
//
//  Created by aviza on 11/02/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import Foundation
import UIKit

class MyStringItemSource: NSObject, UIActivityItemSource {

    
    var text = ""
    
    init(_ text : String) {
        self.text = text
    }
    
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any
    {
        return ""
    }


    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any?
    {
//        if activityType == UIActivityType.message {
//            return self.text
//        } else if activityType == UIActivityType.postToTwitter {
//            return ""
//        }
//        else
        
        if activityType == UIActivityType.postToFacebook {
            return "#CoinData"
        }
        
        return ""
    }
    
//    public func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String
//    {
////        if activityType == UIActivityType.message {
////            return "Subject for message"
////        } else if activityType == UIActivityType.mail {
////            return "Subject for mail"
////        } else if activityType == UIActivityType.postToTwitter {
////            return "Subject for twitter"
////        } else if activityType == UIActivityType.postToFacebook {
////            return "Subject for facebook"
////        }
//        return ""
//    }
    
//    public func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivityType?, suggestedSize size: CGSize) -> UIImage?
//    {
//        if activityType == UIActivityType.message {
//            return UIImage(named: "thumbnail-for-message")
//        } else if activityType == UIActivityType.mail {
//            return UIImage(named: "thumbnail-for-mail")
//        } else if activityType == UIActivityType.postToTwitter {
//            return UIImage(named: "thumbnail-for-twitter")
//        } else if activityType == UIActivityType.postToFacebook {
//            return UIImage(named: "thumbnail-for-facebook")
//        }
//        return UIImage(named: "some-default-thumbnail")
//    }
}
