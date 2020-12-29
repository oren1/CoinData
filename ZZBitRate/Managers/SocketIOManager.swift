//
//  SocketIOManager.swift
//  ZZBitRate
//
//  Created by aviza on 16/12/2017.
//  Copyright © 2017 aviza. All rights reserved.
//

import Foundation

import SocketIO

typealias socketFinish = (Bool) -> Void



protocol SocketIOManagerDelegate: class {
    func socketAnswer(str : String)
}

class SocketIOManager: NSObject {
    static let shared = SocketIOManager()
    
    weak var delegate: SocketIOManagerDelegate?
    var socket : SocketIOClient?
    var  manager : SocketManager?
    
    // let dict = [ "subs" : ["5~CCCAGG~BTC~USD"]]
    
    var subsArray : [String] = [""]
    
    let dict = [ "subs" : ["2~Poloniex~BTC~USD","2~Bitstamp~BTC~USD","2~OKCoin~BTC~USD","2~Coinbase~BTC~USD","2~Cexio~BTC~USD"]]
    
    //    let dict = [ "subs" : ["0~Bitstamp~BTC~USD","0~OKCoin~BTC~USD","0~Coinbase~BTC~USD","0~Cexio~BTC~USD"]]
    
    //    0~Cryptsy~BTC~USD, 0~Bitstamp~BTC~USD, 0~OKCoin~BTC~USD, 0~Coinbase~BTC~USD, 0~Poloniex~BTC~USD, 0~Cexio~BTC~USD, 0~BTCE~BTC~USD, 0~BitTrex~BTC~USD, 0~Kraken~BTC~USD, 0~Bitfinex~BTC~USD, 0~LocalBitcoins~BTC~USD, 0~itBit~BTC~USD, 0~HitBTC~BTC~USD, 0~Coinfloor~BTC~USD, 0~Huobi~BTC~USD, 0~LakeBTC~BTC~USD, 0~Coinsetter~BTC~USD, 0~CCEX~BTC~USD, 0~MonetaGo~BTC~USD, 0~Gatecoin~BTC~USD, 0~Gemini~BTC~USD, 0~CCEDK~BTC~USD, 0~Exmo~BTC~USD, 0~Yobit~BTC~USD, 0~BitBay~BTC~USD, 0~QuadrigaCX~BTC~USD, 0~BitSquare~BTC~USD, 0~TheRockTrading~BTC~USD, 0~Quoine~BTC~USD, 0~LiveCoin~BTC~USD, 0~WavesDEX~BTC~USD, 0~Lykke~BTC~USD, 0~Remitano~BTC~USD, 0~Coinroom~BTC~USD, 0~Abucoins~BTC~USD,
    
    override init() {
        super.init()
        print("init called")
        
//        manager = SocketManager(socketURL: URL(string: "https://streamer.cryptocompare.com/")!, config: [.log(true), .compress])
//        if let manager = manager {
//            socket = manager.defaultSocket
//        }
//
//        if let socket = socket {
//            // socket.connect()
//            socket.on(clientEvent: .connect) {data, ack in
//                print("socket connected \(data) \(ack)")
//                //print("socket connected")
//            }
//
//
//        }
  }
        
        
    // trade
    // '{SubscriptionId}~{ExchangeName}~{CurrencySymbol}~{CurrencySymbol}~{Flag}~{TradeId}~{TimeStamp}~{Quantity}~{Price}~{Total}'
    
    //M [0~Poloniex~BTC~USD~1~15619661~1513469808~0.00007821~19160.00000104~1.4985036~1f]
    
    //flags
    //    1    Buy
    //    2    Sell
    //    4    Unknown
    //
    
    
    func addSubsToSocket(strArray : [String]) {
        
      let dictSubs = [ "subs" : strArray ]
        print("addSubsToSocket : \(dictSubs)")
        if let socket = socket {
            socket.emit("SubAdd", dictSubs)
            
            socket.on("m", callback: {data,ack in
                print("***********************************************")
                print("M printed")
                print("M \(data)")
                print("***********************************************")
                let myString: String = String(describing: data[0])
                if myString == "3~LOADCOMPLETE"{
                    
                    //doing this
                    
                    //self.socket?.emit("SubRemove", self.dict)
                    // SocketIOManager.init()
                    
                    // got this massage !!!!!
                    //
                    //                    [401~TOO_MANY_SOCKETS_FROM_SAME_IP_MAX_50]
                    //                    M printed
                    //                    M [401~TOO_MANY_SOCKETS_FROM_SAME_IP_MAX_50]
                    
                    
                    
                    print("Updated **** 3~LOADCOMPLETE ******")
                }else {
                    
                    self.delegate?.socketAnswer(str : myString)
                    
         
                }
                
                
            })
            
        }
        
    }
    
    func removeSubs(strArray : [String]) {
        //print(" removeSubs \([String])")
        
        //unebale to SubRemove let's kill the socket,
        if let socket = socket {
        let dictSubs = [ "subs" : strArray ]
            socket.emit("SubRemove", dictSubs)
        }
        
 
    }
    
    func killSoucktAndOpenNewOne(strArray: [String],onCompletion: @escaping socketFinish) {

        closeConnection()
        socket = nil
        manager = nil
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            
            
            self.manager = SocketManager(socketURL: URL(string: "https://streamer.cryptocompare.com/")!, config: [.log(true), .compress])
            if let manager = self.manager {
                self.socket = manager.defaultSocket
            }
            
            onCompletion(true)
            
            if let socket = self.socket {
                socket.connect()
                socket.on(clientEvent: .connect) {[weak self] data, ack in
                    print("-----socket connected \(data) \(ack)")
                    //print("socket connected")
  //                  if (self?.subsArray)! != strArray {
                        self?.subsArray = strArray
                        self?.addSubsToSocket(strArray: strArray)
  //                  }
                }
            }
            
        }

    }
    
    func openNewSocket(strArray: [String]) {
        
    }
    
    
    
    func establishConnection() {
        if let socket = socket {
            socket.connect()
        }
        
    }
    func closeConnection() {
        if let socket = socket {
            socket.disconnect()
            print("-----socket  disconnect  *****")
        }
    }
    
}

