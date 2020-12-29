//
//  AlertsVC.swift
//  ZZBitRate
//
//  Created by oren shalev on 07/09/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import RealmSwift

class AlertsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ChooceCoinTVCDelegate{

    
    var limitNotificationToken: NotificationToken? = nil
    var intervalNotificationToken: NotificationToken? = nil
    
    var limitNotificationResults: Results<LimitNotification>?
    var intervalNotificationResults: Results<IntervalNotification>?

    var notificationTypeToCreate: NotificationType = .IntervalNotification
    
    @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setLimitNotificationToken()
        setIntervalNotificationToken()
        
        getNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getNotifications), name: .UIApplicationWillEnterForeground, object: nil)
        
    }
    
        
    @objc func getNotifications()  {
        if let user = User.user() {
            NetworkManager.shared.getNotifications(userId: user.userId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
        
    
    // MARK: - CustomLoginc
    func openPurchaseTVC()  {
        let purchaseTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchaseTVC") as! PurchaseTVC
        self.navigationController?.pushViewController(purchaseTVC, animated: true)
    }

    func openChooseCoinTVC() {
        let chooseCoinNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseCoinNavController") as! UINavigationController
        let chooseCoinTVC = chooseCoinNavController.viewControllers.first as! ChooceCoinTVC
        chooseCoinTVC.delegate = self
        self.present(chooseCoinNavController, animated: true, completion: nil)
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionNotificationType = NotificationType(rawValue: section)
        
        switch sectionNotificationType {
        case .IntervalNotification:
               return intervalNotificationResults!.count + 1
        case .LimitNotification:
            return limitNotificationResults!.count + 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionNotificationType = NotificationType(rawValue: indexPath.section)

        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertTableViewCell") as! AlertTableViewCell
        
        switch sectionNotificationType{
        case .IntervalNotification:
            if (indexPath.row == intervalNotificationResults?.count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewNotificationCell")!
                return cell
            }
            let notification = intervalNotificationResults?[indexPath.row]
            cell.descriptionLabel.text = notification?.notificationDescription()
            cell.statusLabel.text = notification?.status == 1 ? "ON" : "OFF"
            cell.statusLabel.textColor = notification?.status == 1 ? UIColor.green : UIColor.red
        case .LimitNotification:
            if (indexPath.row == limitNotificationResults?.count) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewNotificationCell")!
                return cell
            }
            let notification = limitNotificationResults?[indexPath.row]
            cell.descriptionLabel.text = notification?.notificationDescription()
            cell.statusLabel.text = notification?.status == 1 ? "ON" : "OFF"
            cell.statusLabel.textColor = notification?.status == 1 ? UIColor.green : UIColor.red
        default:
            return cell
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)

            let cell = tableView.cellForRow(at: indexPath)
            if cell is AlertTableViewCell {
                return
            }
            
        
            guard (User.user()?.token.count)! > 0 else { // Making sure that there is a token that the server will be able to send notifications to.
                let alert = UIAlertController(title: "Enable Notification", message: "To use this feature you need to allow notifications in Setting", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        
            

             let sectionNotificationType = NotificationType(rawValue: indexPath.section)
             switch sectionNotificationType {
             case .IntervalNotification:
                        guard let maxAmountOfIntervalNotifications =  UserDataManager.shared.settings?.maxAmountOfIntervalNotifications else { return }
                        
                        if (intervalNotificationResults!.count >= maxAmountOfIntervalNotifications) &&
                            !UserDataManager.shared.purchasedProVersion() {
                            openPurchaseTVC()
                        }
                        else {
                            notificationTypeToCreate = .IntervalNotification
                            openChooseCoinTVC()
                        }
             case .LimitNotification:
                        guard let maxAmountOfLimitNotifications =  UserDataManager.shared.settings?.maxAmountOfLimitNotifications else { return }
                        
                        if (limitNotificationResults!.count >= maxAmountOfLimitNotifications) &&
                            !UserDataManager.shared.purchasedProVersion() {
                            openPurchaseTVC()
                        }
                        else {
                            notificationTypeToCreate = .LimitNotification
                            openChooseCoinTVC()
                        }
                
             default:
                print("sectionNotificationType error")

        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        let sectionNotificationType = NotificationType(rawValue: indexPath.section)

        switch sectionNotificationType {
        case .IntervalNotification:
            if (indexPath.row == intervalNotificationResults?.count) {
                    return 60
             }
        case .LimitNotification:
            if (indexPath.row == limitNotificationResults?.count) {
                return 60
            }
        default:
               return 100
        }
        
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UINib(nibName: "AlertHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView

        let titleLabel = headerView.viewWithTag(10) as! UILabel
        
        if section == 0 {
            titleLabel.text = "Interval Alerts"
        }
        else if section == 1 {
            titleLabel.text = "Limit Alerts"

        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                  
        if (indexPath.section == 0) {
            if (indexPath.row == intervalNotificationResults?.count) {return UISwipeActionsConfiguration()}
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == limitNotificationResults?.count) {return UISwipeActionsConfiguration()}
        }
        
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete",
                  handler: { (action, view, completionHandler) in
                    let notificationType = NotificationType(rawValue: indexPath.section)
                    switch notificationType {
                    case .IntervalNotification:
                        if let notification = self.intervalNotificationResults?[indexPath.row] {
                            NetworkManager.shared.deleteNotification(notificationId: notification._id, onSuccess: { (successMessage) in
                              
                            }) { (error) in
                              
                            }
                        }

                    case .LimitNotification:
                        if let notification = self.limitNotificationResults?[indexPath.row] {
                            NetworkManager.shared.deleteNotification(notificationId: notification._id, onSuccess: { (successMessage) in
                              
                            }) { (error) in
                              
                            }
                        }
                    default:
                        print("deleteAction error")
                        
                    }
                
                    completionHandler(true)
                })
        deleteAction.image = UIImage(named: "trash32")
        deleteAction.backgroundColor = UIColor.red
                
        
        
        let editAction = UIContextualAction(style: .normal, title: "Edit",
                  handler: { (action, view, completionHandler) in
                      print("Edit")
                    
                    let addNotificationTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNotificationTVC") as! AddNotificationTVC
                    
                    addNotificationTVC.screenState = .edit

                    let sectionNotificationType = NotificationType(rawValue: indexPath.section)
                
                    switch sectionNotificationType {
                    case .IntervalNotification:
                        let intervalNotification = self.intervalNotificationResults?[indexPath.row]
                        addNotificationTVC.intervalNotification = intervalNotification?.copy() as? IntervalNotification
                        addNotificationTVC.notificationType = .IntervalNotification
                    case .LimitNotification:
                        let limitNotification = self.limitNotificationResults?[indexPath.row]
                        addNotificationTVC.limitNotification = limitNotification?.copy() as? LimitNotification
                        addNotificationTVC.notificationType = .LimitNotification
                    default:
                        print("error")
                    }
                    

                    self.navigationController?.pushViewController(addNotificationTVC, animated: true)
                    
                  completionHandler(true)
                })
        editAction.image = UIImage(named: "edit32")
        editAction.backgroundColor = UIColor.gray
              
                
        let resumePauseAction = UIContextualAction(style: .normal, title: "Resume/Pause",
                handler: { (action, view, completionHandler) in
                    print("Resume/Pause")
                    
                    let notificationType = NotificationType(rawValue: indexPath.section)
                    switch notificationType {
                    case .IntervalNotification:
                        if let notification = self.intervalNotificationResults?[indexPath.row] {
                            let status = notification.status == 0 ? 1 : 0 // Allways sending the oposite
                            NetworkManager.shared.updateNotificationStatus(notificationId: notification._id, status: status, onSuccess: { (successMessage) in
                            }) { (error) in
                            }
                        }

                    case .LimitNotification:
                        if let notification = self.limitNotificationResults?[indexPath.row] {
                            let status = notification.status == 0 ? 1 : 0 // Allways sending the oposite
                            NetworkManager.shared.updateNotificationStatus(notificationId: notification._id, status: status, onSuccess: { (successMessage) in
                            }) { (error) in
                            }
                        }
                    default:
                        print("deleteAction error")
                        
                    }
                
                    completionHandler(true)
                completionHandler(true)
            })
                
                if (indexPath.section == 0) {
                    let notification = self.intervalNotificationResults?[indexPath.row]
                    let name = notification?.status == 1 ? "pause32" : "play32"
                    resumePauseAction.image = UIImage(named: name)
                    resumePauseAction.title = notification?.status == 1 ? "Pause" : "Resume"
                }
                else if (indexPath.section == 1) {
                 let notification = self.limitNotificationResults?[indexPath.row]
                    let name = notification?.status == 1 ? "pause32" : "play32"
                    resumePauseAction.image = UIImage(named: name)
                    resumePauseAction.title = notification?.status == 1 ? "Pause" : "Resume"

                 }

            


                resumePauseAction.backgroundColor = UIColor.lightGray

                
                
              let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction,resumePauseAction])

              return configuration
    }

    
    
    //MARK: - Realm Notification
    func setIntervalNotificationToken() {
        
         let realm = try! Realm()
         intervalNotificationResults = realm.objects(IntervalNotification.self)

         // Observe Results Notifications
         intervalNotificationToken = intervalNotificationResults?.observe { [weak self] (changes: RealmCollectionChange) in
             guard let tableView = self?.tableView else { return }
             switch changes {
             case .initial:
                 // Results are now populated and can be accessed without blocking the UI
                 tableView.reloadData()
             case .update(_, let deletions, let insertions, let modifications):
                 // Query results have changed, so apply them to the UITableView
                 tableView.beginUpdates()
                 // Always apply updates in the following order: deletions, insertions, then modifications.
                 // Handling insertions before deletions may result in unexpected behavior.
                 tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                      with: .fade)
                 tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                      with: .fade)
                 tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                      with: .fade)
                 tableView.endUpdates()
             case .error(let error):
                 // An error occurred while opening the Realm file on the background worker thread
                 fatalError("\(error)")
             }
         }
    }
    

    
    func setLimitNotificationToken() {
        
         let realm = try! Realm()
         limitNotificationResults = realm.objects(LimitNotification.self)
        
         // Observe Results Notifications
         limitNotificationToken = limitNotificationResults?.observe { [weak self] (changes: RealmCollectionChange) in
             guard let tableView = self?.tableView else { return }
             switch changes {
             case .initial:
                 // Results are now populated and can be accessed without blocking the UI
                 tableView.reloadData()
             case .update(_, let deletions, let insertions, let modifications):
                 // Query results have changed, so apply them to the UITableView
                 tableView.beginUpdates()
                 // Always apply updates in the following order: deletions, insertions, then modifications.
                 // Handling insertions before deletions may result in unexpected behavior.
                 tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 1)}),
                                      with: .fade)
                 tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 1) }),
                                      with: .fade)
                 tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 1) }),
                                      with: .fade)
                 tableView.endUpdates()
             case .error(let error):
                 // An error occurred while opening the Realm file on the background worker thread
                 fatalError("\(error)")
             }
         }
    }
    
    // MARK: - CooseCoinTVCDelegate
    func didChooseCoin(_ coin : ZZCoin) {
       
        self.dismiss(animated: true) { [unowned self] in
            
            let addNotificationTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNotificationTVC") as! AddNotificationTVC
            
            addNotificationTVC.screenState = .add
            addNotificationTVC.notificationType = self.notificationTypeToCreate

            if (self.notificationTypeToCreate == .IntervalNotification) {
                let intervalNotification = IntervalNotification()
                intervalNotification.name = coin.fullName
                intervalNotification.exchange = "CCCAGG"
                intervalNotification.fsym = coin.symbol
                intervalNotification.tsym = "USD"
                intervalNotification.interval = 1000 * 60 * 5
                
                addNotificationTVC.intervalNotification = intervalNotification
            }
            else {
                let limitNotification = LimitNotification()
                limitNotification.name = coin.fullName
                limitNotification.exchange = "CCCAGG"
                limitNotification.fsym = coin.symbol
                limitNotification.tsym = "USD"
                limitNotification.direction = "biggerThan"
                
                addNotificationTVC.limitNotification = limitNotification
            }

            
            self.navigationController?.pushViewController(addNotificationTVC, animated: true)
        }
    }
    
    
    
    deinit {
        limitNotificationToken?.invalidate()
        intervalNotificationToken?.invalidate()
    }
}
