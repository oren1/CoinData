//
//  CoreDataManager.swift
//  ZZBitRate
//
//  Created by avi zazati on 30/08/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import Foundation
import RealmSwift

typealias setPricesComplition = (Results<UserHolding>) -> Void


class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
    }
    
    
    
    // MARK: - realm Func
    
    func createNewHolding(amount: Double, coinName: String, coinNameId: String) {
        print("isMainThread \(Thread.isMainThread)")

        //create a disk song
//        let userHolding: UserHolding = NSEntityDescription.insertNewObject(forEntityName: "UserHolding", into: managedObjectContext) as! UserHolding
//        userHolding.amount = amount
//        userHolding.coinName = coinName
//        userHolding.coinNameId = coinNameId
        
        // Use them like regular Swift objects
        let userHolding = UserHolding()
        userHolding.coinName = coinName
        userHolding.amount = amount
        userHolding.coinNameId = coinNameId
        
        
        // Get the default Realm
        let realm = try! Realm()
//
//        // Query Realm for all dogs less than 2 years old
//        let puppies = realm.objects(Dog.self).filter("age < 2")
//        puppies.count // => 0 because no dogs have been added to the Realm yet
//
        // Persist your data easily
        try! realm.write {
            realm.add(userHolding)
        }

    }

     func fatchAllHolding() -> Results<UserHolding>  {
        print("isMainThread \(Thread.isMainThread)")
        // Get the default Realm
        let realm = try! Realm()
//
//                // Query Realm for all dogs less than 2 years old
//                let puppies = realm.objects(Dog.self).filter("age < 2")
//                puppies.count // => 0 because no dogs have been added to the Realm yet
//
        
        
        // Query Realm for all dogs less than 2 years old
        let userHoldingArray : Results<UserHolding> = realm.objects(UserHolding.self)
        //puppies.count // => 0 because no dogs have been added to the Realm yet
        
        return userHoldingArray

    }
    
    func fatchCoin(coinNameId : String) -> UserHolding? {
        // Get the default Realm
        let realm = try! Realm()
        let predicate = NSPredicate(format: "coinNameId == %@", coinNameId)

        // Query Realm for all
        let coins = realm.objects(UserHolding.self).filter(predicate)
        
        return coins.first
    }
    
    func updateAmountFor(coinNameId : String, newAmount:Double) {
        // Get the default Realm
        let realm = try! Realm()
        let predicate = NSPredicate(format: "coinNameId == %@", coinNameId)
        
        // Query Realm for all
        let coins = realm.objects(UserHolding.self).filter(predicate)
        
        let coin = coins.first
        
        //let theDog = realm.objects(Dog.self).filter("age == 1").first
        try! realm.write {
            //set the price and total usd to core data object
            coin?.amount = newAmount
        }
    }
    
    func deleteUserHoldingWith(coinNameId : String) {
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "coinNameId == %@", coinNameId)
        
        // Query Realm for all
        let coins = realm.objects(UserHolding.self).filter(predicate)
        
        let coin = coins.first
        
        //let theDog = realm.objects(Dog.self).filter("age == 1").first
        try! realm.write {
            //set the price and total usd to core data object
            realm.delete(coin!)

           
        }
    }
    
    
    func setPricesFor(holdingArray : Results<UserHolding> , onCompletion: @escaping setPricesComplition) {
        
        let allCoinArray =  chaceManager.shared.allCoinArray
        
        for userHolding in holdingArray {

            for coin in allCoinArray {
                if coin.nameID == userHolding.coinNameId {
                    print("11111 ---------------- found  \(userHolding.coinNameId)--------------------- ")
                    
                    let realm = try! Realm()
                    try! realm.write {
                        //set the price and total usd to core data object
                        let price : Double = Double(coin.price_usd) ?? 0.0
                        userHolding.priceForOneCoin = price
                        userHolding.totalUSD = userHolding.amount * price
                    }


                    break
                }
            }
            
            onCompletion(holdingArray)
            
        }
        
      
        
    }
    
    
}


