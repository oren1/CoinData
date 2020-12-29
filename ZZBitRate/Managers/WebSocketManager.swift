//
//  WebSocketManager.swift
//  ZZBitRate
//
//  Created by oren shalev on 03/12/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import Foundation
import Starscream

class WSManager {
    static var shared: WSManager = WSManager()
    var socket: WebSocket
    var tempSubs: [String] = []
    init() {
        var request = URLRequest(url: URL(string: "wss://streamer.cryptocompare.com/v2?api_key=dd470f89924f82d5f63d337a001d096c550841337788ec74602293c285964060")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.onConnect = {
         print("socket conectet")
            self.subscribe(subs: self.tempSubs)
        }
        socket.onData = { data in
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("data received: \(jsonObject)")
                }
            } catch{
                print(error)
            }
        }
        socket.onText = { text in
            print("socket text: \(text)")
            let data = text.data(using: .utf8)!
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any]
                {
                   print("socket text json: \(jsonArray)") // use the json here
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        socket.onDisconnect = { error in
            print("socket disconnect")
        }
        
        
        socket.connect()

    }
    
    
    func subscribe(subs: [String]) {
        
        if !socket.isConnected {
           return tempSubs.append(contentsOf: subs)
        }
        
        let message: [String : Any] = [
            "action": "SubAdd",
            "subs": subs
            ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: [])
            self.socket.write(data: data)

        } catch  {
            print(error)
        }
    }
    
    func unSubscribe(subs: [String]) {
        if !socket.isConnected {
            for sub in subs {
                if let indexForRemove = tempSubs.index(of: sub) {
                    tempSubs.remove(at: indexForRemove)
                }
            }
        }
        
        
        let message: [String : Any] = [
            "action": "SubRemove",
            "subs": subs
            ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: [])
            self.socket.write(data: data)

        } catch  {
            print(error)
        }

    }
}
