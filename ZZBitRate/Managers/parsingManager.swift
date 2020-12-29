//
//  parsingManager.swift
//  ZZBitRate
//
//  Created by aviza on 12/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation
import RealmSwift

typealias ParseResult = (errorMessage: String?, successMessage: String?)

class parsingManager {
    static let shared = parsingManager()
    
    func parseTopListRequest(data : Data) -> Array<ZZCoinRate> {
        
        var arr : Array<ZZCoinRate> = []
        var totalMarketCup : Float64 = 0.0
        var totalVol : Float64 = 0.0
        
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            print(json)
            
            if let jsonArr = json["Data"] as? [Any] {
                
                //let baseImageUrl = json!["BaseImageUrl"] as? String
                
                for dict in jsonArr {
                    if let coinDict = dict as? [String: Any] {
                        if var coin = ZZCoinRate(json: coinDict) {
                            arr.append(coin)
                            
                            let capString = coin.market_cap_usd
                            let cap = (capString as NSString).doubleValue
                            totalMarketCup += cap
                            
                            let volString = coin.one_day_volume_usd
                            let vol = (volString as NSString).doubleValue
                            totalVol += vol
                        }
                    }
                    
                }
                
                // print("totalMarketCup : \(totalMarketCup)")
                
                UserDataManager.shared.totalMarketCap = totalMarketCup
                UserDataManager.shared.totalVol = totalVol
                
            }
            
        }
        
        return arr
    }
    
    func parseCoinsByNameListRequest(data : Data,namesArr: [String]) -> Array<ZZCoinRate> {
         
         var arr : Array<ZZCoinRate> = []
         
         if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
             print(json)
            
            if let rawJson = json["RAW"] as? [String: Any] {
                print(rawJson)

//                //looping the UserDefaults fav_array
//                let favArray = UserDefaults.standard.object(forKey: "fav_array") as? [String] ?? [String]()


                 for coinId in namesArr {

                    let RAW_SYMBOL_JSON : [String:Any] = rawJson[coinId] as? [String: Any] ?? [:]
                    let RAW_USD_JSON : [String:Any] = RAW_SYMBOL_JSON["USD"] as? [String: Any] ?? [:]

                    if let coin = ZZCoinRate(RAW_USD_JSON:RAW_USD_JSON ) {
                             arr.append(coin)
                         }
                 }
                
            }
        }
        
         
         return arr
     }
    
    func parseAllCoins(data : Data) -> Array<ZZCoin> {
        
        var coins: [ZZCoin] = []
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            
            let coinsDictionary = jsonObject["Data"] as! [String: [String: Any]]
            
            for (_, coin) in coinsDictionary {
                
                if let id = coin["Id"] as? String,
                    let imageUrl = coin["ImageUrl"] as? String,
                    let symbol = coin["Symbol"] as? String,
                    let fullName = coin["FullName"] as? String {
                    
                    let zzcoin = ZZCoin(id: id, imageUrl: imageUrl, symbol: symbol, fullName: fullName)
                    coins.append(zzcoin)
                }
                
                
            }
            
        }
        
        
        //sort the coins array
        //let names = ["BTC","ETH","XRP","CRO","BCH","XMR","TRX"]
        
        let sortCoins1  = makeFirst(name: "BTC",toIndex: 0,  arr: coins)
        let sortCoins2  = makeFirst(name: "ETH",toIndex: 1,  arr: sortCoins1)
        let sortCoins3  = makeFirst(name: "USDT",toIndex: 2,  arr: sortCoins2)
        let sortCoins4  = makeFirst(name: "XRP",toIndex: 3,  arr: sortCoins3)
        let sortCoins5  = makeFirst(name: "MXR",toIndex: 4,  arr: sortCoins4)
        let sortCoins6  = makeFirst(name: "BCH",toIndex: 5,  arr: sortCoins5)
        let sortCoins7  = makeFirst(name: "BNB",toIndex: 6,  arr: sortCoins6)
        let sortCoins8  = makeFirst(name: "LINK",toIndex: 7,  arr: sortCoins7)
        let sortCoins9  = makeFirst(name: "DOT",toIndex: 8,  arr: sortCoins8)
        let sortCoins10 = makeFirst(name: "ADA",toIndex: 9,  arr: sortCoins9)
        let sortCoins11 = makeFirst(name: "LTC",toIndex: 10, arr: sortCoins10)
        let sortCoins12 = makeFirst(name: "CRO",toIndex: 11, arr: sortCoins11)
        let sortCoins13 = makeFirst(name: "BSV",toIndex: 12, arr: sortCoins12)

        return sortCoins13
        
    }
    
    func makeFirst(name: String ,toIndex: Int, arr:[ZZCoin]) -> [ZZCoin] {
        var newArr = arr
        for (index,coin) in arr.enumerated() {
            if coin.symbol == name {
               newArr = rearrange(array: newArr, fromIndex: index, toIndex: toIndex)
            }
        }
        
        return newArr
    }
    
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)

        return arr
    }
    
    
    func parseFavoritesCoinsRequest(data : Data) -> Array<ZZCoinRate> {
        
        var arr : Array<ZZCoinRate> = []
        
        let defaults = UserDefaults.standard
        let favArray = defaults.object(forKey: "fav_array") as? [String] ?? [String]()
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            //print(json)
            
            let jsonArr = json["Data"] as! [Any]
            
            
            //let dict = json!["Data"] as? [String: Any]
            //let baseImageUrl = json!["BaseImageUrl"] as? String
            
            for dict in jsonArr {
                if let coinDict = dict as? [String: Any] {
                    if let coin = ZZCoinRate(json: coinDict) {
                        
                        if favArray.contains(coin.nameID) {
                            arr.append(coin)
                        }
                    }
                }
            }
        }
        
        
        
        return arr
    }
    
    func parseAllCoinsImagesFromCryptoCompareRequest(data : Data) -> [String:String] {
        
        var imagesDict : [String:String] = [:]
        
        do {
            let json = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            // print(json)
            
            let coinsDict = json!["Data"] as? [String: Any]
            let baseImageUrl = json!["BaseImageUrl"] as? String
            
            if let coinsDict = coinsDict {
                
                for (key, value) in coinsDict {
                    //imagesDict[key] = baseImageUrl
                    let coinDict = value as? [String: Any]
                    if let coinDict = coinDict {
                        
                        let imageUrl = coinDict["ImageUrl"] as? String
                        let name     = coinDict["Name"] as? String
                        
                        if let imageUrl = imageUrl,
                            let name = name ,
                            let baseImageUrl = baseImageUrl  {
                            imagesDict[name] = baseImageUrl + imageUrl
                            
                            //print the images json as a dict
                            //                            let q = "\""
                            //                            print(q +
                            //                                "\(name)" +
                            //                                q +
                            //                                ":" +
                            //                                q +
                            //                                "\(baseImageUrl + imageUrl)" +
                            //                                q +
                            //                                ",")
                        }
                        
                    }
                }
                
                
                
            }
            
            
        } catch {
            print(error)
        }
        
        
        
        return imagesDict
    }
    
    
    func parseAllNewsRequest(data : Data) -> Array<NewsItem> {
        
        var arr : Array<NewsItem> = []
        
        do {
            let json = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            //   print(json)
            
            if let dict = json!["articles"] as? [Any] {
                for item in dict {
                    if let newItemDict = item as? [String: Any] {
                        if let newsItem = NewsItem(json: newItemDict) {
                            arr.append(newsItem)
                        }
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        return arr
    }
    
    func parseCryptoPanicNews(data : Data) -> Array<CryptoPanicNewsItem> {
        
        var arr : Array<CryptoPanicNewsItem> = []
        
        do {
            let json = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            //  print(json)
            
            if let dict = json!["results"] as? [Any] {
                for item in dict {
                    if let newItemDict = item as? [String: Any] {
                        if let newsItem = CryptoPanicNewsItem(json: newItemDict) {
                            arr.append(newsItem)
                        }
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        return arr
    }
    
    
    func parseHistoryRequest(data : Data) -> CoinHistory {
        
        var arr : Array<HistoryItem> = []
        var from = 0.0
        var to = 0.0
        
        
        do {
            let JSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            //  print(JSON)
            
            if let json = JSON {
                
                if let timeFrom = json["TimeFrom"] as? Double {
                    from = timeFrom
                }
                
                if let timeTo = json["TimeTo"] as? Double {
                    to = timeTo
                }
                
                if let dict = json["Data"] as? [Any] {
                    for item in dict {
                        if let newItemDict = item as? [String: Any] {
                            if let historyItem = HistoryItem(json: newItemDict) {
                                arr.append(historyItem)
                            }
                        }
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        let coinHistory = CoinHistory(timeTo : to, timeFrom : from, arr : arr)
        return  coinHistory!
        
    }
    
    func parseExchagesRequest(data : Data,tsym: String) -> [String] {
        var arr : [String] = []
        
        do {
            let JSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            // print(JSON)
            
            if let json = JSON {
                
                if let dict = json[tsym] as? [String:Any] {
                    if  let subs = dict["TRADES"] as? [String] {
                        arr = subs
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        
        return  arr
    }
    
    func parsePriceRequest(data : Data) -> Double {
        do {
            let JSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let json = JSON {
                
                if let price = json["USD"] as? Double {
                    return price
                }
            }
            
        } catch {
            print(error)
        }
        
        return 0.0
    }
    
    func parsePricesRequest(data : Data) -> [String: Double]? {
        do {
            let JSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let json = JSON {
                var prices: [String: Double] = [:]
                for (key, value) in json {
                    if let rates = value as? [String: Double] {
                        prices[key] = rates["USD"]
                    }
                }
                
                return prices
                
            }
            
            return nil
            
        } catch {
            print(error)
            return nil
        }
        
    }
    
    func getExchangeNameFromSub(str : String) -> String {
        
        let myStringArr = str.components(separatedBy: "~")
        if myStringArr.count > 2 {
            return myStringArr[1]
        }
        else {
            return ""
        }
    }
    
    func parseUser(data: Data) {
        
        do {
            if let userJSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                if let id = userJSON["_id"] as? String {
                    
                    let user = User()
                    
                    let realm = try! Realm()
                    try! realm.write() {
                        
                        user.userId = id
                        realm.add(user)
                        print("user created")
                    }
                }
                
            }
            
        }
            
        catch let error as NSError {
            print("failed parsing JSON: \(error.localizedDescription)")
        }
        
        
    }
    
    func parseNotifications(data: Data) {
        
        do {
            if let notificationsJSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                
                if let notifications = notificationsJSON["notifications"] as? [[String: Any]] {
                    
                    let realm = try! Realm()
                    
                    try! realm.write() {
                        
                        // Delete all limit and interval notifications
                        let intervalNotificationResults = realm.objects(IntervalNotification.self)
                        let limitNotificationResults = realm.objects(LimitNotification.self)
                        realm.delete(intervalNotificationResults)
                        realm.delete(limitNotificationResults)
                        
                        for notification in notifications {
                            
                            let notificationType = notification["__t"] as! String
                            
                            if (notificationType == "LimitNotification") {
                                realm.create(LimitNotification.self, value: notification, update: .modified)
                            }
                            else if (notificationType == "IntervalNotification") {
                                realm.create(IntervalNotification.self, value: notification, update: .modified)
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    let LimitNotifications = realm.objects(LimitNotification.self)
                    let IntervalNotifications = realm.objects(IntervalNotification.self)
                    
                    print("LimitNotifications: \(LimitNotifications)")
                    print("IntervalNotifications: \(IntervalNotifications)")
                    
                }
                    
                else {
                    throw NSError(domain: "Api getNotifications", code: 0, userInfo: notificationsJSON)
                }
                
                
                
                
            }
            
        }
            
        catch let error as NSError {
            print("Failed parsing JSON: \(error)")
        }
        
    }
    
    func parseCreateNotification(data: Data) -> Bool{
        
        do {
            if let notificationJSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                
                if let notificationType = notificationJSON["__t"] as? String {
                    
                    let realm = try! Realm()
                    
                    try! realm.write() {
                        
                        if (notificationType == "LimitNotification") {
                            realm.create(LimitNotification.self, value: notificationJSON, update: .modified)
                        }
                        else if (notificationType == "IntervalNotification") {
                            realm.create(IntervalNotification.self, value: notificationJSON, update: .modified)
                        }
                    }
                }
                else {
                    return false
                }
                
                
            }
            
            return true
        }
            
        catch let error as NSError {
            print("Failed parsing JSON: \(error)")
            return false
        }
        
    }
    
    func parseUpdateNotification(data: Data) -> Bool{
        
        do {
            if let notificationJSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                if let notificationType = notificationJSON["__t"] as? String {
                    let realm = try! Realm()
                    try! realm.write() {
                        if (notificationType == "LimitNotification") {
                            realm.create(LimitNotification.self, value: notificationJSON, update: .modified)
                        }
                        else if (notificationType == "IntervalNotification") {
                            realm.create(IntervalNotification.self, value: notificationJSON, update: .modified)
                        }
                    }
                }
                else {
                    return false
                    
                }
            }
            
            return true
        }
            
        catch let error as NSError {
            print("Failed parsing JSON: \(error)")
            return false
        }
    }
    
    func parseUpdateNotificationStatus(data: Data) -> Bool{
        
        do {
            if let notificationJSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                if let notificationType = notificationJSON["__t"] as? String {
                    let realm = try! Realm()
                    try! realm.write() {
                        
                        if (notificationType == "LimitNotification") {
                            realm.create(LimitNotification.self, value: notificationJSON, update: .modified)
                        }
                        else if (notificationType == "IntervalNotification") {
                            realm.create(IntervalNotification.self, value: notificationJSON, update: .modified)
                        }
                    }
                }
                else {
                    return false
                }
                
            }
            
            return true
        }
            
        catch let error as NSError {
            print("Failed parsing JSON: \(error)")
            return false
        }
        
    }
    
    func parseDeleteNotification(data: Data) -> Bool{
        
        do {
            if let notificationJSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                
                if let notificationType = notificationJSON["__t"] as? String,
                    let notificationId = notificationJSON["_id"] as? String {
                    
                    let realm = try! Realm()
                    try! realm.write() {
                        
                        if (notificationType == "LimitNotification") {
                            let notifications = realm.objects(LimitNotification.self).filter("_id = %@", notificationId)
                            if notifications.count > 0 {
                                realm.delete(notifications[0])
                            }
                            
                        }
                        else if (notificationType == "IntervalNotification") {
                            let notifications = realm.objects(IntervalNotification.self).filter("_id = %@", notificationId)
                            if notifications.count > 0 {
                                realm.delete(notifications[0])
                            }
                        }
                        
                    }
                    
                    
                }
                else {
                    return false
                }
            }
            
            return true
        }
            
        catch let error as NSError {
            print("Failed parsing JSON: \(error)")
            return false
        }
        
    }
    
    
    func parsePortfolios(data: Data) -> Bool{
        
        do {
            if let portfoliosJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                
                if let error = portfoliosJSON["error"] as? [String: Any] {
                    print(error)
                    return false
                }
                
                if let errors = portfoliosJSON["errors"] as? [String: Any] {
                    print(errors)
                    return false
                }
                
                guard let portfolios = portfoliosJSON["portfolios"] as? [[String: Any]] else {
                    print("no portfolios found")
                    return false
                }
                
                let realm = try! Realm()
                try! realm.write({
                    
                    for portfolio in portfolios {
                        realm.create(Portfolio.self, value: portfolio, update: .modified)
                    }
                })
                
                let portf = realm.objects(Portfolio.self)
                print("portfolios = \(portf)")
                
            }
            
            return true
        }
            
        catch let error as NSError {
            print("Failed parsing JSON: \(error)")
            return false
        }
        
    }
    
    func parseDeletePortfolio(data: Data) -> Bool{
        
        do {
            if let portfolioJSON = try  JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                if let portfolioId = portfolioJSON["_id"] as? String {
                    
                        let realm = try! Realm()
                        try! realm.write() {
                            
                                let portfolios = realm.objects(Portfolio.self).filter("_id = %@", portfolioId)
                                if portfolios.count > 0 {
                                    realm.delete(portfolios[0])
                                }
                        }
                }
                else {
                    return false
                }
            }
            
            return true
        }
            
        catch let error as NSError {
            print("Failed parsing JSON: \(error)")
            return false
        }
        
    }
    
    func parseExchangeBalance(data: Data) -> [CoinBalance]? {
        
                do {
                if let balanceJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    
                    if let error = balanceJSON["error"] as? [String: Any] {
                        print(error)
                        return nil
                    }
                                if let errors = balanceJSON["errors"] as? [String: Any] {
                                    print(errors)
                                    return nil
                                }
                                
                                guard let balance = balanceJSON["balance"] as? [[String: Any]] else {
                                    print("no balance key found")
                                    return nil
                                }
                                
                                var coinBalanceArray: [CoinBalance] = []
                                for coin in balance {
                                    let coinBalance = CoinBalance()
                                    coinBalance.symbol = coin["symbol"] as! String
                                    coinBalance.amount = coin["amount"] as! Double
                                    coinBalanceArray.append(coinBalance)
                                }
                                
                                print("coinBalanceArray = \(coinBalanceArray)")
                                return coinBalanceArray
                                
                            }
                            
                            return nil
                        }
                        
                catch let error as NSError {
                    print("Failed parsing JSON: \(error)")
                    return nil
                }
                    
    }
    func parseQRCode(data: Data) -> [String: String]? {
                               
        do {
            if let qrJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                            
                                          
                if let error = qrJSON["error"] as? [String: Any] {
                    print(error)
                    return nil
                }
                                              
                if let errors = qrJSON["errors"] as? [String: Any] {
                    print(errors)
                    return nil
                }
                                              
                return qrJSON as! [String: String]
            }
                                  
            return nil
        }
                                        
        catch let error as NSError {
            print("Failed parsing JSON: \(error)")
            return nil
        }

    }
    func parseAddCoinBalance(data: Data) -> Bool {
             
              do {
                  if let portfolioJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                          
                        
                            if let error = portfolioJSON["error"] as? [String: Any] {
                                print(error)
                                return false
                            }
                            
                            if let errors = portfolioJSON["errors"] as? [String: Any] {
                                print(errors)
                                return false
                            }
                            
                            let realm = try! Realm()
                            try! realm.write({
                                    realm.create(Portfolio.self, value: portfolioJSON, update: .modified)
                            })
                            
                            return true
                    
                    }
                
                return false
              }
                      
              catch let error as NSError {
                print("Failed parsing JSON: \(error)")
                return false
              }

          }

    func parseUpdateCoinBalance(data: Data) -> Bool {
             
              do {
                  if let portfolioJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                          
                        
                            if let error = portfolioJSON["error"] as? [String: Any] {
                                print(error)
                                return false
                            }
                            
                            if let errors = portfolioJSON["errors"] as? [String: Any] {
                                print(errors)
                                return false
                            }
                            
                            let realm = try! Realm()
                            try! realm.write({
                                    realm.create(Portfolio.self, value: portfolioJSON, update: .modified)
                            })
                            
                            return true
                    
                    }
                
                return false
              }
                      
              catch let error as NSError {
                print("Failed parsing JSON: \(error)")
                return false
              }

    }

    func parseAddPortfolio(data: Data) -> ParseResult {
                     
              do {
                  if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                          
                            if let success = responseJSON["success"] as? Bool,
                                let message = responseJSON["message"] as? String {
                                
                                    if success == true {
                                        
                                            if let data = responseJSON["data"] as? [String: Any] {
                                                let realm = try! Realm()
                                                try! realm.write({
                                                        realm.create(Portfolio.self, value: data, update: .modified)
                                                })
                                                
                                                return (nil,message)
                                            }
                                            
                                            return (nil,"no 'message' found")

                                    }
                                    else {

                                            return (message,nil)
                                    }
                            }
                    
                        return ("params not found",nil)
                    
                    }
                
                return ("params error",nil)
                
              }
              catch let error as NSError {
                print("Failed parsing JSON: \(error)")
                return ("Failed parsing JSON: \(error)",nil)
              }
        
    }
    func parseSupportedExchanges(data: Data) -> Bool {
             
              do {
                  if let exchangesJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                          
                            if let error = exchangesJSON["error"] as? [String: Any] {
                                print(error)
                                return false
                            }
                            
                            if let errors = exchangesJSON["errors"] as? [String: Any] {
                                print(errors)
                                return false
                            }
                            
                            let exchanges = exchangesJSON["exchanges"] as! [[String: Any]]

                            let realm = try! Realm()
                            try! realm.write({
                                
                                for exchange in exchanges {
                                    realm.create(Exchange.self, value: exchange, update: .modified)
                                }
                                
                            })
                            
                            return true
                    
                    }
                
                return false
              }
                      
              catch let error as NSError {
                print("Failed parsing JSON: \(error)")
                return false
              }

    }
    
    func parseSettings(data: Data, realm: Realm) throws {
        
        do {
            // make sure this JSON is in the format we expect
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // try to read out a string array
                if let success = json["success"] as? Bool,
                    let message = json["message"] as? String,
                    let data = json["data"] as? [String: Any] {
                    
                    if success {
//                        let realm = try! Realm()
                        try! realm.write({
                            
                            // Delete the old settings object
                            let oldSettings = realm.objects(Settings.self)
                            realm.delete(oldSettings)
                            
                            
                            // Create new settings object
                            guard let maxAmountOfIntervalNotification = data["maxAmountOfIntervalNotification"] as? Int,
                                let maxAmountOfLimitNotification = data["maxAmountOfLimitNotification"] as? Int,
                                let maxAmountOfPortfolios = data["maxAmountOfPortfolios"] as? Int,
                                let fetchDataTimeInMiliSeconds = data["fetchDataTimeInMiliSeconds"] as? Double  else {
                                    
                                    throw NSError(domain: "parseSettings", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON Error: Not as expected"])
                            }
                            
                            
                            let settings = Settings()
                            settings.maxAmountOfIntervalNotifications = maxAmountOfIntervalNotification
                            settings.maxAmountOfLimitNotifications = maxAmountOfLimitNotification
                            settings.maxAmountOfPortfolios = maxAmountOfPortfolios
                            settings.fetchDataTimeInSeconds = fetchDataTimeInMiliSeconds / 1000
                            
                            realm.add(settings)
                        })
                        
                        return
                    }

                    throw NSError(domain: "parseSettings", code: 1,
                                  userInfo: [NSLocalizedDescriptionKey:message])

                }
                
                else {
                    throw NSError(domain: "parseSettings", code: 1,
                                  userInfo: [NSLocalizedDescriptionKey: "JSON Error: not as expected"])
                }
            }
            
        } catch let error as NSError {
            throw error
        }
    }
    
    
    func parseUserToken(data: Data, completion: @escaping (_ success: Bool) -> ()) {
        do {
            if let userJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                guard let token = userJSON["token"] as? String else {
                    completion(false)
                    return
                }
                
                let realm = try! Realm()
                try! realm.write({
                    User.user()?.token = token
                })
                completion(true)
                
            }
        } catch {
            completion(false)
        }
    }
    
    func parseValidateReceipt(data: Data, completion: @escaping (Bool,[String: Any]?) -> ()) {
        
        do {
            if let validationJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
               return completion(true,validationJSON)
            }
            completion(false,nil)
            
        } catch let error as NSError {
            print("Couldn't parse validation data from app store: \(error)")
            completion(false,nil)
        }
    }
    
    func parseDeleteMultiplePortfolios(data: Data, completion: @escaping (Error?) -> Void) {
        
        let error = NSError(domain: "parseDeleteMultiplePortfolios", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error parsing response"])
      
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                guard let success = json["success"] as? Bool,
                    let message = json["message"] as? String,
                    let portfoliosIds = json["data"] as? [String] else {

                        return completion(error)
                }
                
                if success {
                    let realm = try! Realm()
                    let portfoliosToDelete = realm.objects(Portfolio.self)
                        .filter(NSPredicate(format: "_id IN %@", portfoliosIds))
                    
                    try! realm.write({
                        realm.delete(portfoliosToDelete)
                    })
                    return completion(nil)
                }
                
                let error = NSError(domain: "parseDeleteMultiplePortfolios", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
                return completion(error)
                
            }
            
            else {
                completion(error)
            }
            
        } catch  {
            completion(error)
        }
        
    }
    
    
    func parseDeleteMultipleNotifications(data: Data, completion: @escaping (Error?) -> Void) {
        
        let error = NSError(domain: "parseDeleteMultipleNotifications", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error parsing response"])
      
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                guard let success = json["success"] as? Bool,
                    let message = json["message"] as? String,
                    let notificationsIds = json["data"] as? [String] else {

                        return completion(error)
                }
                
                if success {
                    let realm = try! Realm()
                    let limitNotificationsToDelete = realm.objects(LimitNotification.self)
                        .filter(NSPredicate(format: "_id IN %@", notificationsIds))
                    let intervalNotificationsToDelete = realm.objects(IntervalNotification.self)
                    .filter(NSPredicate(format: "_id IN %@", notificationsIds))
                    
                    try! realm.write({
                        realm.delete(limitNotificationsToDelete)
                        realm.delete(intervalNotificationsToDelete)
                    })
                    return completion(nil)
                }
                
                let error = NSError(domain: "parseDeleteMultiplePortfolios", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
                return completion(error)
                
            }
            
            else {
                completion(error)
            }
            
        } catch  {
            completion(error)
        }
        
    }
    
    
}
