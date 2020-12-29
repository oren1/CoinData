//
//  ZZCoinRate.swift
//  ZZBitRate
//
//  Created by aviza on 12/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation

struct ZZCoinRate {

    let id                  : String
    let name                : String
    let nameID              : String
   // let rank                : String
    var price_usd           : String
   // let price_btc           : String
    let one_day_volume_usd  : String
    let market_cap_usd      : String
    let available_supply    : String
 //   let total_supply        : Double
    let percent_change_1h   : String
    let percent_change_24h  : String
   // let percent_change_7d   : String
    //let last_updated        : String


    /*   {
    "id": "bitcoin",
    "name": "Bitcoin",
    "symbol": "BTC",
    "rank": "1",
    "price_usd": "16621.4",
    "price_btc": "1.0",
    "24h_volume_usd": "13411700000.0",
    "market_cap_usd": "278264259355",
    "available_supply": "16741325.0",
    "total_supply": "16741325.0",
    "max_supply": "21000000.0",
    "percent_change_1h": "-0.53",
    "percent_change_24h": "1.5",
    "percent_change_7d": "-0.39",
    "last_updated": "1513279154"
},
 */
    
    mutating func updatePriceUSD(priceUsd: String) {
        self.price_usd = priceUsd
    }

}


extension ZZCoinRate {
    init?(json: [String: Any]) {
        
        
      //  print(json)
        
        let COIN_INFO_JSON : [String:Any] = json["CoinInfo"] as? [String: Any] ?? [:]
        let DISPLAY_JSON : [String:Any] = json["DISPLAY"] as? [String: Any] ?? [:]
        let RAW_JSON : [String:Any] = json["RAW"] as? [String: Any] ?? [:]
        let RAW_USD_JSON : [String:Any] = RAW_JSON["USD"] as? [String: Any] ?? [:]


//                var COIN_INFO_JSON : [String:Any] = [:]
//                if let coinInfo = json["CoinInfo"] as? [String: Any] {
//                    COIN_INFO_JSON = coinInfo
//                 }
        
        //whats this

        
        
            self.name               = COIN_INFO_JSON["FullName"] as! String
            self.nameID             = COIN_INFO_JSON["Name"] as! String
       // self.id                 = String(COIN_INFO_JSON["Id"] as! IntegerLiteralType)
            self.id  = ""
    
  
       // self.rank               = String(json["cmc_rank"] as! Int)
        

        
//        self.price_usd          = String(RAW_USD_JSON["PRICE"] as? Double ?? 0.0)
        self.price_usd          = (RAW_USD_JSON["PRICE"] as? Double ?? 0.0).priceFormamtWithNoFractionLimit()

        self.one_day_volume_usd  = String(format: "%.2f",RAW_USD_JSON["VOLUME24HOUR"] as? Double ?? 0.0)
        
        self.market_cap_usd     =  String(format: "%.2f",RAW_USD_JSON["MKTCAP"] as? Double ?? 0.0)
        self.available_supply     =  String(RAW_USD_JSON["SUPPLY"] as? Double ?? 0.0)

       self.percent_change_1h  = String(format: "%.2f",RAW_USD_JSON["CHANGEPCTHOUR"] as? Double ?? 0.0)
       self.percent_change_24h = String(format: "%.2f",RAW_USD_JSON["CHANGEPCTDAY"] as? Double ?? 0.0)
       //self.percent_change_7d  = String(json["percent_change_7d"] as? Double ?? 0.0)
       //self.last_updated       = String(USD_JSON["last_updated"]! as! Double)


        
 

        
        
        //self.total_supply       = json["total_supply"] as! Double
       // self.available_supply   = json["available_supply"] as! String

 
//        self.id                 = id ?? ""
//        self.name               = name ?? ""
//        self.nameID             = nameID ?? ""
//        self.rank               = rank ?? ""
//        self.price_usd          = price_usd ?? ""
//       // self.price_btc          = price_btc ?? ""
//        self.one_day_volume_usd = one_day_volume_usd ?? ""
//        self.market_cap_usd     = market_cap_usd ?? ""
//       // self.available_supply   = available_supply ?? ""
//        self.total_supply       = total_supply ?? ""
//        self.percent_change_1h  = percent_change_1h ?? ""
//        self.percent_change_24h = percent_change_24h ?? ""
//        self.percent_change_7d  = percent_change_7d ?? ""
//        self.last_updated       = last_updated ?? ""
    
    }
    
     init?(RAW_USD_JSON: [String: Any]) {
            
              print(RAW_USD_JSON)

        if RAW_USD_JSON.isEmpty {
            print("⛔️ No value")

            return nil
        }

            
            
                self.name               = RAW_USD_JSON["FROMSYMBOL"] as! String //?? where is full name?
                self.nameID             = RAW_USD_JSON["FROMSYMBOL"] as! String
                self.id  = ""
                    
        
//            self.price_usd          = String(RAW_USD_JSON["PRICE"] as? Double ?? 0.0)
            self.price_usd          = (RAW_USD_JSON["PRICE"] as? Double ?? 0.0).priceFormamtWithNoFractionLimit()

            self.one_day_volume_usd  = String(format: "%.2f",RAW_USD_JSON["VOLUME24HOUR"] as? Double ?? 0.0)
            
            self.market_cap_usd     =  String(format: "%.2f",RAW_USD_JSON["MKTCAP"] as? Double ?? 0.0)
            self.available_supply     =  String(RAW_USD_JSON["SUPPLY"] as? Double ?? 0.0)

           self.percent_change_1h  = String(format: "%.2f",RAW_USD_JSON["CHANGEPCTHOUR"] as? Double ?? 0.0)
           self.percent_change_24h = String(format: "%.2f",RAW_USD_JSON["CHANGEPCTDAY"] as? Double ?? 0.0)
         
        
        }
}



struct ZZCoin  {
        
    var id: String
    var imageUrl: String
    var symbol: String
    var fullName: String

}

