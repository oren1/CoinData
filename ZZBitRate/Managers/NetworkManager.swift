//
//  NetworkManager.swift
//  ZZBitRate
//
//  Created by aviza on 12/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//


//news api https://newsapi.org/docs/get-started

import Foundation
import RealmSwift

typealias StringResponse = (String) -> Void
typealias ErrorResponse = (Error) -> Void
typealias AllCoinsResponse = ([ZZCoin]) -> Void
typealias ServiceResponse = (Array<ZZCoinRate>) -> Void
typealias NewsServiceResponse = (Array<NewsItem>) -> Void
typealias historyServiceResponse = (CoinHistory) -> Void
typealias ServiceResponseImages = ([String:String]) -> Void
typealias ServiceResponseExchange = ([String]) -> Void
typealias CryptoPanicResponse = (Array<CryptoPanicNewsItem>) -> Void
typealias ServiceResponsePrice = (Double) -> Void
typealias ServiceResponsePrices = ([String: Double], Error?) -> Void
typealias ServiceResponseSetPrices = (Results<UserHolding>) -> Void
typealias ServiceResponseBalance = ([CoinBalance], Error?) -> Void




class NetworkManager {
    static let shared = NetworkManager()
    
    #if DEBUG
        let coinDataServiceUrl = "https://staging-coin-data.herokuapp.com"
    #else
        let coinDataServiceUrl = "https://production-coin-data.herokuapp.com"
    #endif
    
    
    let cryptocompareBaseURL = "https://min-api.cryptocompare.com"
    let newsAPI_KEY = "a7eb0a74943a472b8a8900dd319257ff"
    let cryptoPanic_API_KEY = "ce9cb374fbb3c6113cdbb637cd9969843949b35e"
    
    //let coinMarketCup_API_KEY = "5f08a8f7-e9e0-4a12-8ee2-8e7b87b046f9"
    
    
    
    //
    let cryptocompare_API_KEY = "dd470f89924f82d5f63d337a001d096c550841337788ec74602293c285964060"
    let verifyReceiptProductionUrl = "https://buy.itunes.apple.com/verifyReceipt"
    let verifyReceiptSandBoxUrl = "https://sandbox.itunes.apple.com/verifyReceipt"

    
    
    func createUserSync(token: String? = nil, completion: @escaping ()->()) {
        let urlString = "\(coinDataServiceUrl)/createUser"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        
        var postString = ""
        if let token = token {
            postString = "token=\(token)"
        }
        
        // Set HTTP Request Body
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    DispatchQueue.main.async {
                        completion()
                    }
                }
         
                // Convert HTTP Response Data to a String
                else if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    parsingManager.shared.parseUser(data: data)
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            
            semaphore.signal()

        }
        
        task.resume()
        
        let timeout = DispatchTime.now() + .seconds(10)
        let _ = semaphore.wait(timeout: timeout)
        
    }
    
    func updateUserToken(userId: String, token: String) {
        let urlString = "\(coinDataServiceUrl)/updateUserToken"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "userId=\(userId)&token=\(token)";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    parsingManager.shared.parseUserToken(data: data) { (success) in
                    }
                }
        }
        task.resume()
    }
    
    func getNotifications(userId: String) {
        let urlString = "\(coinDataServiceUrl)/getNotifications"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "userId=\(userId)";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    parsingManager.shared.parseNotifications(data: data)
                    
                }
        }
        
        task.resume()
    }
    
    func addPortfolio(params: [String: Any],
                      completion: @escaping (_ error: Error?, _ successMessage: String?) -> ()) {
        let urlString = "\(coinDataServiceUrl)/addPortfolio"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        request.encodeBodyParameters(parameters: params)
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    completion(error,nil)
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Add Portfolio Response data string:\n \(dataString)")
                   
                    let parseResult = parsingManager.shared.parseAddPortfolio(data: data)
                   
                        if let errorMessage = parseResult.errorMessage {
                            DispatchQueue.main.async {
                                let error = NSError(domain: "addPortfolio", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                                completion(error,nil)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                completion(nil,parseResult.successMessage!)
                            }
                        }
 
                }
        }
        
        task.resume()
    }
    
    func getMyPortfolios(userId: String,
                         onSuccess: @escaping StringResponse,
                         onFailure: @escaping ErrorResponse) {
        let urlString = "\(coinDataServiceUrl)/myPortfolios"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "userId=\(userId)";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                   let parsed = parsingManager.shared.parsePortfolios(data: data)
                    if parsed {
                        onSuccess("got portfolios")
                    }
                    else {
                        let error = NSError(domain: "getMyPortfolios", code: 1, userInfo: [NSLocalizedDescriptionKey:"failed getting portfolios try again later"])
                        onFailure(error)
                    }
                    
                }
        }
        
        task.resume()
    }
    
    func deletePortfolio(portfolioId: String,
                                  onSuccess: @escaping StringResponse,
                                  onFailure: @escaping ErrorResponse) {
        let urlString = "\(coinDataServiceUrl)/deletePortfolio"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "portfolioId=\(portfolioId)";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    DispatchQueue.main.async {
                        onFailure(error)
                    }
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    let success = parsingManager.shared.parseDeletePortfolio(data: data)
                    if success {
                        DispatchQueue.main.async {
                            onSuccess("portfolio deleted!")
                        }
                    }
                    else {
                        let error = NSError(domain: "deletePortfolio", code: 1, userInfo: [NSLocalizedDescriptionKey:"Couldn't delete portfolio"])
                        DispatchQueue.main.async {
                            onFailure(error)
                        }
                    }
                }
        }
        
        task.resume()
    }
    
    func getSupportedExchanges(completion: @escaping (_ error: Error?) -> ()) {
        let urlString = "\(coinDataServiceUrl)/supportedExchanges"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    completion(error)
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("supported exchanges Response data string:\n \(dataString)")
                   
                     let exchangesParsed = parsingManager.shared.parseSupportedExchanges(data: data)
                     if exchangesParsed {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                     }
                     else {
                        let error = NSError(domain: "getSupportedExchanges", code: 1, userInfo: [NSLocalizedDescriptionKey:"failed getting supported exchanges try again later"])
                        DispatchQueue.main.async {
                            completion(error)
                        }
                    }
                }
        }
        
        task.resume()
    }
    
    func getExchangeBalance(exchangeName: String, token: String,
                         completion: @escaping ServiceResponseBalance) {
        let urlString = "\(coinDataServiceUrl)/getBalanceForExchange"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "exchangeName=\(exchangeName)&token=\(token.replacingOccurrences(of: "+", with: "%2b"))"
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    completion([],error)
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                   
                    if let balance = parsingManager.shared.parseExchangeBalance(data: data) {
                        DispatchQueue.main.async {
                            completion(balance,nil)
                        }
                    }

                    else {
                        let error = NSError(domain: "getBalanceForExchange", code: 1, userInfo: [NSLocalizedDescriptionKey:"failed getting balance for exchange try again later"])
                        
                        DispatchQueue.main.async {
                            completion([],error)
                        }
                    }
                    
                }
        }
        
        task.resume()
    }
    func addCoinBalance(portfolioId: String, symbol: String, amount: Double,
                        completion: @escaping (_ error: Error?) -> ()) {
        let urlString = "\(coinDataServiceUrl)/addCoinBalance"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "portfolioId=\(portfolioId)&symbol=\(symbol)&amount=\(amount)"
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    completion(error)
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                   DispatchQueue.main.async {
                             let coinParsed = parsingManager.shared.parseAddCoinBalance(data: data)
                             if coinParsed {
                                    completion(nil)
                             }
                             else {
                                let error = NSError(domain: "addCoinBalance", code: 1, userInfo: [NSLocalizedDescriptionKey:"failed adding coin balance for portfolio try again later"])
                                    completion(error)
                            }
                    }

                }
        }
        
        task.resume()
    }
    
    func updateCoinBalance(portfolioId: String, symbol: String, amount: Double,
                        completion: @escaping (_ error: Error?) -> ()) {
        let urlString = "\(coinDataServiceUrl)/updateCoinBalance"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "portfolioId=\(portfolioId)&symbol=\(symbol)&amount=\(amount)"
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    completion(error)
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                   
                     let coinParsed = parsingManager.shared.parseUpdateCoinBalance(data: data)
                     if coinParsed {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                     }
                     else {
                        let error = NSError(domain: "updateCoinBalance", code: 1, userInfo: [NSLocalizedDescriptionKey:"failed updating coin balance for portfolio try again later"])
                        DispatchQueue.main.async {
                            completion(error)
                        }
                    }
                }
        }
        
        task.resume()
    }
    
    func parseQRCode(exchangeName: String, code: String, onSuccess:
        @escaping ([String: String]) -> (), onFailure: @escaping ErrorResponse) {
        
        let urlString = "\(coinDataServiceUrl)/parseQRCode"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "exchangeName=\(exchangeName)&code=\(code)"
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    onFailure(error)
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                   
                    if let qrJSON = parsingManager.shared.parseQRCode(data: data) {
                        DispatchQueue.main.async {
                            onSuccess(qrJSON)
                        }
                    }
                    else {
                        let error = NSError(domain: "parseQRCode", code: 1, userInfo: [NSLocalizedDescriptionKey:"failed parsing QR"])
                        DispatchQueue.main.async {
                            onFailure(error)
                        }
                    }
                }
        }
        
        task.resume()
    }
    
    func updateNotificationStatus(notificationId: String, status: Int,
                                  onSuccess: @escaping StringResponse,
                                  onFailure: @escaping ErrorResponse) {
        let urlString = "\(coinDataServiceUrl)/updateNotificationStatus"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "id=\(notificationId)&status=\(status)";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    onFailure(error)
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    let success = parsingManager.shared.parseUpdateNotificationStatus(data: data)
                    if success {
                        onSuccess("status changes")
                    }
                    else {
                        let error = NSError(domain: "updateNotificationStatus", code: 1, userInfo: [NSLocalizedDescriptionKey:"Couldn't update notification status"])
                        onFailure(error)
                    }
                }
        }
        
        task.resume()
    }
    
    func createNotification(intervalNotification: IntervalNotification? = nil,
                            limitNotification: LimitNotification? = nil,
                            onSuccess: @escaping StringResponse, onFailure: @escaping ErrorResponse ) {
       
        // Can't execute the request if a user doesn't exists
        guard let userId = User.user()?.userId else {
            let error = NSError(domain: "createNotification", code: 1, userInfo: [NSLocalizedDescriptionKey:"User not exists"])
            onFailure(error)
            return
        }
        
        var notificationType = "" // Type to be sent in the request url
        var postString = ""  // HTTP Request Parameters which will be sent in HTTP Request Body

        if let _ = intervalNotification  {
            notificationType = "intervalNotification"
            postString = "userId=\(userId)&fsym=\(intervalNotification!.fsym)&tsym=\(intervalNotification!.tsym)&exchange=\(intervalNotification!.exchange)&name=\(intervalNotification!.name)&interval=\(intervalNotification!.interval)"
  
        }
        else {
            notificationType = "limitNotification"
            postString = "userId=\(userId)&fsym=\(limitNotification!.fsym)&tsym=\(limitNotification!.tsym)&exchange=\(limitNotification!.exchange)&name=\(limitNotification!.name)&limit=\(limitNotification!.limit)&repeated=\(false)&direction=\(limitNotification!.direction)"
            

        }
        
        let urlString = "\(coinDataServiceUrl)/createNotification/\(notificationType)"
        
        
         let url = URL(string: urlString)
         guard let requestUrl = url else { fatalError() }
         // Prepare URL Request Object
         var request = URLRequest(url: requestUrl)
         request.httpMethod = "POST"
          
        
        // Set HTTP Request Body
         request.httpBody = postString.data(using: String.Encoding.utf8)
         // Perform HTTP Request
         let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                 
                 // Check for Error
                 if let error = error {
                     print("Error took place \(error)")
                     onFailure(error)
                     return
                 }
          
                 // Convert HTTP Response Data to a String
                 if let data = data, let dataString = String(data: data, encoding: .utf8) {
                     print("Response data string:\n \(dataString)")
                     let success = parsingManager.shared.parseCreateNotification(data: data)
                     if success {
                        onSuccess("Notification created!")
                     }
                     else {
                        let error = NSError(domain: "createNotification", code: 1, userInfo: [NSLocalizedDescriptionKey:"Could'nt create notification try again later"])
                        onFailure(error)
                     }
                     
                 }
         }
         
         task.resume()
    }
    
    func updateNotification(intervalNotification: IntervalNotification? = nil,
                              limitNotification: LimitNotification? = nil,
                              onSuccess: @escaping StringResponse, onFailure: @escaping ErrorResponse ) {
                   
          var notificationType = "" // Type to be sent in the request url
          var postString = ""  // HTTP Request Parameters which will be sent in HTTP Request Body

          if let _ = intervalNotification  {
              notificationType = "intervalNotification"
            postString = "id=\(intervalNotification!._id)&fsym=\(intervalNotification!.fsym)&tsym=\(intervalNotification!.tsym)&exchange=\(intervalNotification!.exchange)&name=\(intervalNotification!.name)&interval=\(intervalNotification!.interval)"
    
          }
          else {
              notificationType = "limitNotification"
            postString = "id=\(limitNotification!._id)&fsym=\(limitNotification!.fsym)&tsym=\(limitNotification!.tsym)&exchange=\(limitNotification!.exchange)&name=\(limitNotification!.name)&limit=\(limitNotification!.limit)&repeated=\(false)&direction=\(limitNotification!.direction)"
              

          }
          
          let urlString = "\(coinDataServiceUrl)/updateNotification/\(notificationType)"
          
          
           let url = URL(string: urlString)
           guard let requestUrl = url else { fatalError() }
           // Prepare URL Request Object
           var request = URLRequest(url: requestUrl)
           request.httpMethod = "POST"
            
          
          // Set HTTP Request Body
           request.httpBody = postString.data(using: String.Encoding.utf8)
           // Perform HTTP Request
           let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                   
                   // Check for Error
                   if let error = error {
                       print("Error took place \(error)")
                       onFailure(error)
                       return
                   }
            
                   // Convert HTTP Response Data to a String
                   if let data = data, let dataString = String(data: data, encoding: .utf8) {
                       print("Response data string:\n \(dataString)")
                       let success = parsingManager.shared.parseUpdateNotification(data: data)
                       if success {
                          onSuccess("Notification updated!")
                       }
                       else {
                          let error = NSError(domain: "updateNotification", code: 1, userInfo: [NSLocalizedDescriptionKey:"Could'nt update notification try again later"])
                          onFailure(error)
                       }
                       
                   }
           }
           
           task.resume()
      }
   
    func deleteNotification(notificationId: String,
                                  onSuccess: @escaping StringResponse,
                                  onFailure: @escaping ErrorResponse) {
        let urlString = "\(coinDataServiceUrl)/deleteNotification"
       
        let url = URL(string: urlString)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
         
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "id=\(notificationId)";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    onFailure(error)
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")
                    let success = parsingManager.shared.parseDeleteNotification(data: data)
                    if success {
                        onSuccess("notification deleted!")
                    }
                    else {
                        let error = NSError(domain: "updateNotificationStatus", code: 1, userInfo: [NSLocalizedDescriptionKey:"Couldn't delete notification"])
                        onFailure(error)
                    }
                }
        }
        
        task.resume()
    }
    
    func getTopList(page: Int , onCompletion: @escaping ServiceResponse) {
        
        print("------ getTopList")
       
        let urlString = "https://min-api.cryptocompare.com/data/top/mktcapfull?page=\(page)&limit=100&tsym=USD&api_key=\(cryptocompare_API_KEY)"
       
        if let url = URL(string: urlString) {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {
                            var arr = parsingManager.shared.parseTopListRequest(data: usableData)
                            
                            onCompletion(arr)
                        }
                    }
                    else {
                        
                        //                        DispatchQueue.main.async  { [weak self] in
                        //                            self?.showErrorAlertWithMassage("Response: " + response.description)
                        //                        }
                    }
                    
                }
                
            })
            task.resume()
        }
    }
    
    func getCoinsByNames(fsyms : String, tsyms: String = "USD" ,onCompletion: @escaping ServiceResponse) {
        
   
        

        
        print("------ getCoinsByNames")
             
              let urlString = "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=\(fsyms)&tsyms=\(tsyms)&api_key=\(cryptocompare_API_KEY)"
             
              if let url = URL(string: urlString) {
                  
                  let task = URLSession.shared.dataTask(with: url, completionHandler:
                  {data, response, error -> Void in
                      
                      if let response = response as? HTTPURLResponse {
                          if response.statusCode == 200 {
                              if let usableData = data {
                                let names = fsyms.components(separatedBy: ",")

                                let arr = parsingManager.shared.parseCoinsByNameListRequest(data: usableData,namesArr: names)
                                  
                                  onCompletion(arr)
                              }
                          }
                          else {
                              
                              //                        DispatchQueue.main.async  { [weak self] in
                              //                            self?.showErrorAlertWithMassage("Response: " + response.description)
                              //                        }
                          }
                          
                      }
                      
                  })
                  task.resume()
              }
        
    }
    
    
    func getAllCoins(onCompletion: @escaping AllCoinsResponse, onFailure: @escaping StringResponse) {
        
        print("------ getAllCoins")
       
        let urlString = "https://min-api.cryptocompare.com/data/all/coinlist?summary=true&api_key=\(cryptocompare_API_KEY)"
       
        if let url = URL(string: urlString) {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                       
                        if let usableData = data {
                            
                            let general = General.general()
                            let realm = try! Realm()
                            try! realm.write({
                                general.allCoinsData = usableData
                            })
                            
                            let coins = parsingManager.shared.parseAllCoins(data: usableData)
                            onCompletion(coins)
                        }
                    }
                    else {
                        onFailure("Error getting all coins")
                    }
                    
                }
                
            })
            task.resume()
        }
    }
    
    func getPricesFor(fsyms: String, tsym: String , onCompletion: @escaping ServiceResponsePrices) {
        
        let dataUrl = "https://min-api.cryptocompare.com/data/pricemulti?fsyms=" + fsyms + "&tsyms=" + tsym + "&api_key=\(cryptocompare_API_KEY)"
        
        let urlString = URL(string:dataUrl)
        if let url = urlString {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let error = error {
                    DispatchQueue.main.async {
                        onCompletion([:], error)
                    }
                }
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {

                            DispatchQueue.main.async {
                                
                                if let prices = parsingManager.shared.parsePricesRequest(data: usableData) {
                                    onCompletion(prices, nil)
                                }
                                
                                else {
                                    let error = NSError(domain: "Get Prices", code: 1, userInfo: [NSLocalizedDescriptionKey:"failed getting prices"])
                                    onCompletion([:], error)

                                }
                            }

                        }
                    }
                    else {
                        let error = NSError(domain: "Get Prices", code: 1, userInfo: [NSLocalizedDescriptionKey:"failed getting prices"])
                        DispatchQueue.main.async {
                            onCompletion([:], error)
                        }
                        
                    }
                }
                
            })
            task.resume()
        }
    }
    
    func getFavoritesCoins(onCompletion: @escaping ServiceResponse) {
        
        // let urlString = URL(string: cryptocompareBaseURL + "/data/all/coinlist")

        
         let urlString = "https://min-api.cryptocompare.com/data/top/mktcapfull?limit=100&tsym=USD&api_key=\(cryptocompare_API_KEY)"
        
         if let url = URL(string: urlString) {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {
                            let arr = parsingManager.shared.parseFavoritesCoinsRequest(data: usableData)
                            onCompletion(arr)
                        }
                    }
                    
                }
                
            })
            task.resume()
        }
    }
    
    func getExchagesFor(fsym : String,tsym: String , onCompletion: @escaping ServiceResponseExchange) {
        let dataUrl = "https://min-api.cryptocompare.com/data/subs?fsym=" + fsym + "&tsyms=" + tsym
        
        let urlString = URL(string:dataUrl)
        if let url = urlString {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {
                            let arr = parsingManager.shared.parseExchagesRequest(data: usableData,tsym:tsym)
                            onCompletion(arr)
                        }
                    }
                    
                }
                
            })
            task.resume()
        }
    }
    
    func getPriceFor(fsym : String,tsym: String , onCompletion: @escaping ServiceResponsePrice) {
        
        
        let dataUrl = "https://min-api.cryptocompare.com/data/price?fsym=" + fsym + "&tsyms=" + tsym + "&api_key=\(cryptocompare_API_KEY)"
        
        let urlString = URL(string:dataUrl)
        if let url = urlString {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {
                             let price = parsingManager.shared.parsePriceRequest(data: usableData)
                           
                            DispatchQueue.main.async {
                                
                                onCompletion(price)
                                
                            }
                            //let arr = parsingManager.shared.parseExchagesRequest(data: usableData,tsym:tsym)
                            //onCompletion(arr)
                        }
                    }
                    
                }
                
            })
            task.resume()
        }
    }
    
    func getSettings(onCompletion: @escaping (Error?) -> ()){
        
        let urlString = coinDataServiceUrl + "/settings"
        let url = URL(string: urlString)!
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
           
            if error != nil {
                onCompletion(error)
                return
            }
            
            if let data = data {
                do {
                    let realm = try! Realm()
                    try parsingManager.shared.parseSettings(data: data, realm: realm)
                    onCompletion(nil)
                }
                catch let error as NSError {
                    onCompletion(error)
                    print("parse error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    func setPricesFor(holdingArray : Results<UserHolding> , onCompletion: @escaping ServiceResponseSetPrices) {
        
        
    }
    
    func setPricesFor__old(holdingArray : Results<UserHolding> , onCompletion: @escaping ServiceResponseSetPrices) {
        
        let myGroup = DispatchGroup()
        
        for i in 0 ..< holdingArray.count {
            myGroup.enter()
            
            getPriceFor(fsym: holdingArray[i].coinNameId, tsym: "USD") { (price) in
                
                print("isMainThread \(Thread.isMainThread)")


                
//                //set the price and total usd to core data object
//                holdingArray[i].priceForOneCoin = price
//                holdingArray[i].totalUSD = holdingArray[i].amount * price
//
                DispatchQueue.main.async {
                    print("isMainThread \(Thread.isMainThread)")

                    
                    print("\(holdingArray[i].coinName) price \(price)")
                    print("Finished request \(i)")
                    
                    print("isMainThread \(Thread.isMainThread)")

                    let realm = try! Realm()
                    //let theDog = realm.objects(Dog.self).filter("age == 1").first
                    try! realm.write {
                        //set the price and total usd to core data object
                        holdingArray[i].priceForOneCoin = price
                        holdingArray[i].totalUSD = holdingArray[i].amount * price
                    }
                }
     
                
               myGroup.leave()
            }
//
//            Alamofire.request("https://httpbin.org/get", parameters: ["foo": "bar"]).responseJSON { response in
//                print("Finished request \(i)")
//                myGroup.leave()
//            }
        }
        
        myGroup.notify(queue: .main) {
            print("Finished all requests.")
            //CoreDataManager.shared.saveContext()
            
            
            onCompletion(holdingArray)
        }
    }
    
    func builedImagesDictFromCryptoCompere(onCompletion: @escaping ServiceResponseImages) {
        
        // let urlString = URL(string: cryptocompareBaseURL + "/data/all/coinlist")
        let urlString = URL(string:"https://www.cryptocompare.com/api/data/coinlist/")
        if let url = urlString {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {
                            
                            let general = General.general()
                            let realm = try! Realm()
                            try! realm.write({
                                general.imagesDicData = usableData
                            })
                            
                            let dict = parsingManager.shared.parseAllCoinsImagesFromCryptoCompareRequest(data: usableData)
                            onCompletion(dict)
                        }
                    }
                }
                
            })
            task.resume()
        }
    }
    
    func getNews(page : Int,searchString : String ,sortBy: String, onCompletion: @escaping NewsServiceResponse) {
        //%20OR%20Litecoin%20OR%20Ethereum / top-headlines?
        //"sources=cnbc.crypto-coins-news.fortune&" +
        
        //old search string
        //Bitcoin%20OR%20Litecoin%20OR%20Ethereum
        
        //  sort by
        //        relevancy = articles more closely related to q come first.
        //        popularity = articles from popular sources and publishers come first.
        //        publishedAt = newest articles come first.
        //
        
        let str = "https://newsapi.org/v2/everything?" +
            "q=\(searchString)&" +
            "language=en&" +
            "page=\(page)&" +
            "sortBy=\(sortBy)&" +
        "apiKey=\(newsAPI_KEY)"
        let urlString = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let newsURL = URL(string: urlString!)
        
        if let url = newsURL {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {
                            let arr = parsingManager.shared.parseAllNewsRequest(data: usableData)
                            
                            onCompletion(arr)
                        }
                    }
                }
                
            })
            task.resume()
        }
    }
    
    func getHistory(apiName : String, fsym : String ,tsym : String ,limit : Int ,aggregate : Int ,exchange : String , onCompletion: @escaping historyServiceResponse) {
        // https://min-api.cryptocompare.com/data/histominute?fsym=ETH&tsym=USD&limit=60&aggregate=3&e=Kraken&extraParams=your_app_name,
        
        //https://min-api.cryptocompare.com/data/histominute?fsym=BTC&tsym=USD&limit=60&aggregate=3&e=CCCAGG
        
        //histominute
        //histohour
        //histoday
        
        let urlString = "https://min-api.cryptocompare.com/data/\(apiName)" +
            "?fsym=\(fsym)" +
            "&tsym=\(tsym)" +
            "&limit=\(limit)" +
            "&aggregate=\(aggregate)" +
        "&e=\(exchange)" +
        "&api_key=\(cryptocompare_API_KEY)"
        
        let theURL = URL(string: urlString)
        
        if let url = theURL {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {
                            let coinHistory = parsingManager.shared.parseHistoryRequest(data: usableData)
                            
                            onCompletion(coinHistory)
                            
                        }
                    }
                }
                
            })
            task.resume()
        }
    }
    
    
    //MARK: Crypto Panic
    
    func getCryptoPanicPostsForCurrencyWithFilter(currency:String,filter:String, onCompletion: @escaping CryptoPanicResponse) {
        
        var str = "https://cryptopanic.com/api/posts/"
            + "?auth_token=\(cryptoPanic_API_KEY)"
        
        
        if currency.count > 0 {
          str = str + "&currency=\(currency)"
        }
        
        if filter.count > 0 {
            str = str + "&filter=\(filter)"
        }
        
        let urlString = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let newsURL = URL(string: urlString!)
        
        if let url = newsURL {
            
            let task = URLSession.shared.dataTask(with: url, completionHandler:
            {data, response, error -> Void in
                
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let usableData = data {
                            let arr = parsingManager.shared.parseCryptoPanicNews(data: usableData)
                            
                            onCompletion(arr)
                        }
                    }
                }
                
            })
            task.resume()
        }
    }

    
    func validateAppleReceiptsAndUpdateUserDefaults(userDefaults: UserDefaults, completion: @escaping () -> ()) {
       
        let productionUrl = URL(string: verifyReceiptProductionUrl)!
        validateReceipts(withUrl: productionUrl) { [weak self] (dictionary) in
            
            if let statusCode = dictionary["status"] as? Int {
                if statusCode == 21007 { // Need to make the call to sandbox
                    
                    let sandboxUrl = URL(string: self!.verifyReceiptSandBoxUrl)!
                        self?.validateReceipts(withUrl: sandboxUrl) { (dictionary) in
                            print("receipt dictionary: \(dictionary)")

                            CoinDataProducts.store.updateIAPStatusForAppleReceit(json: dictionary, userDefaults: userDefaults)
                                completion()
                        }
                }
                else {
                            print("receipt dictionary: \(dictionary)")
                    
                    CoinDataProducts.store.updateIAPStatusForAppleReceit(json: dictionary, userDefaults: userDefaults)
                            completion()

                }
            }
            
        }
        
    }

    internal func validateReceipts(withUrl url: URL, completion: @escaping ([String: Any]) -> ()) {
                
        
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString()
                let appSecret = ProcessInfo.processInfo.environment["app_secret"]

                let parameters = ["receipt-data": receiptString,
                                  "password": appSecret]
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
                

                let dataTask = URLSession.shared.dataTask(with: request) { (data, respnse, error) in
                    if error != nil {
 
                        print("validateReceipts Error: \(error!.localizedDescription)")
                    }
                    
                    if let usableData = data {
                        parsingManager.shared.parseValidateReceipt(data: usableData) { (success, dictionary) in
                            if success {
                                    return completion(dictionary!)
                            }
                            else {

                                print("failed parsing apple receipt validation")
                            }
                        }

                    }
                    
                }
                
                dataTask.resume()
            }
            catch {

                print("Couldn't read receipt data with error: " + error.localizedDescription)
                
            }
        }
        
        else {

            print("No Apple Receipts")
        }
        
    }
    
    func deleteMultiplePortfolios(portfoliosIds:[String], completion: @escaping (Error?) -> Void) {
        
        let urlString = coinDataServiceUrl + "/deleteMultiplePortfolios"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        let jsonBody = ["portfoliosIds": portfoliosIds]
        let data = try! JSONSerialization.data(withJSONObject: jsonBody, options: [])
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
                if (error != nil) {
                    completion(error)
                }
                else {
                    if let usableData = data {
                        parsingManager.shared.parseDeleteMultiplePortfolios(data: usableData) { (error) in
                            if error != nil {
                                completion(error)
                            }
                            
                        }
                    }
                    
                }
            
        }
        
        task.resume()
    }
    
    func deleteMultipleNotifications(notificationsIds:[String], completion: @escaping (Error?) -> Void) {
        
        let urlString = coinDataServiceUrl + "/deleteMultipleNotifications"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        let jsonBody = ["notificationsIds": notificationsIds]
        let data = try! JSONSerialization.data(withJSONObject: jsonBody, options: [])
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
                if (error != nil) {
                    completion(error)
                }
                else {
                    if let usableData = data {
                        parsingManager.shared.parseDeleteMultipleNotifications(data: usableData) { (error) in
                            if error != nil {
                                completion(error)
                            }
                        }
                        
                    }
                    
                }
            
        }
        
        task.resume()
    }
    
    
    
}


