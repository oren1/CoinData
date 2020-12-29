//
//  PortfoliosCVC.swift
//  ZZBitRate
//
//  Created by oren shalev on 30/09/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import RealmSwift
import NVActivityIndicatorView

private let reuseIdentifier = "Cell"

class PortfoliosCVC: UICollectionViewController, ChooceCoinTVCDelegate, AddNewHoldingDelegate, AddExchangeDelegeate {

    private let sectionInsets = UIEdgeInsets(top: 0,
                                             left: 0,bottom: 0,right: 0)

    var portfoliosToken: NotificationToken? = nil
    var portfoliosResults: Results<Portfolio>?
    var activityIndicatorView : NVActivityIndicatorView!
    var titleView: PortfolioTitleView!
    var ratesTimer: Timer!

    
    func startTimer() {
        ratesTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(fetchDataForCurrentShownCell), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        ratesTimer.invalidate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        titleView = Bundle.main.loadNibNamed("PortfolioTitleView", owner: self, options: nil)![0] as? PortfolioTitleView
        
        navigationItem.titleView = titleView
        navigationItem.title = "Portfolios"
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))

        navigationItem.rightBarButtonItems = [add,edit]

        titleView.titleLabel.text = "Portfolios"
        titleView.pageControl.currentPage = 0
        titleView.pageControl.numberOfPages = 1
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height) , type: .ballClipRotateMultiple, color: .white, padding: 160)
        
        setPortfoliosNotificationToken()
        
        //Fetch the portfolios
        if let userId = User.user()?.userId {
            
            showActivityIndicator()
            NetworkManager.shared.getMyPortfolios(userId: userId, onSuccess: { [weak self] (message) in
                DispatchQueue.main.async {
                    self?.hideActivityIndicator()
                    self?.titleView.pageControl.numberOfPages = (self?.portfoliosResults!.count)! + 1
                }
            })
            { [weak self] (error) in
                DispatchQueue.main.async {
                    self?.hideActivityIndicator()
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: false)
                }

            }
        }
        
    }

    @objc func fetchDataForCurrentShownCell() {
        let pageWidth = self.collectionView!.frame.size.width
        let currentPage = Int(self.collectionView!.contentOffset.x / pageWidth)
        fetchDataForPage(page: currentPage)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }
    

    // MARK: AddExchangeDelegate
    func exchangeAdded() {
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    // MARK: AddNewHoldingDelegate
    func doneEditing() {
        self.navigationController?.popViewController(animated: true)
        let currentPage = titleView.pageControl.currentPage
        let indexPath = IndexPath(row: currentPage, section: 0)
//        collectionView?.reloadItems(at: [indexPath])
    }

    // MARK: ChooceCoinTVCDelegate
    func didChooseCoin(_ coin : ZZCoin) {
        dismiss(animated: false) { [weak self] in
                   let addNewHoldingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNewHoldingVC") as! AddNewHoldingVC

             addNewHoldingVC.coinNameID = coin.symbol
             addNewHoldingVC.coinName = coin.fullName
             
            let currentPage = self?.titleView.pageControl.currentPage
            addNewHoldingVC.portfolio = self?.portfoliosResults![currentPage!]
             addNewHoldingVC.addNewHoldingDelegate = self
             
             self?.navigationController?.pushViewController(addNewHoldingVC, animated: true)
        }
        
    }

        //MARK: - Realm Notification
        func setPortfoliosNotificationToken() {
             
             let realm = try! Realm()
            portfoliosResults = realm.objects(Portfolio.self).sorted(byKeyPath: "_id")
             // Observe Results Notifications
             portfoliosToken = portfoliosResults?.observe { [weak self] (changes: RealmCollectionChange) in
                 guard let collectionView = self?.collectionView else { return }
                 switch changes {
                 case .initial:
                     // Results are now populated and can be accessed without blocking the UI
                     collectionView.reloadData()
                 case .update(_, let deletions, let insertions, let modifications):

                    collectionView.performBatchUpdates({
                        collectionView.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0)}))
                        collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0)}))
                        collectionView.reloadItems(at: modifications.map({ IndexPath(row: $0, section: 0)}))

                    }) { (collectionViewUpdated) in
                        self?.titleView.pageControl.numberOfPages = (self?.portfoliosResults!.count)! + 1
                        self?.updateTitleViewNameAndPlusButton()
                    }

                 case .error(let error):
                     // An error occurred while opening the Realm file on the background worker thread
                     fatalError("\(error)")
                 }
                
             }
        }
    
    //MARK: Custom Logic
    @objc func addButtonTapped() {
        if (isAddPortfolioState()) {
            guard let maxAmountOfPortfolios = UserDataManager.shared.settings?.maxAmountOfPortfolios else {return}
            
            if (portfoliosResults!.count >= maxAmountOfPortfolios) &&
                !UserDataManager.shared.purchasedProVersion() {
                openPurchaseTVC()
            }
            else {
                displayPortfolioTypeOptionMenu()
            }
        }
        else {
            let currentPage = titleView.pageControl.currentPage
            let portfolio = portfoliosResults![currentPage]
            if portfolio.type == PortfolioType.Manual.rawValue {
                openChooseCoinViewController()
            }

        }
    }
    
    func openPurchaseTVC() {
        let purchaseTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PurchaseTVC")
        navigationController?.pushViewController(purchaseTVC, animated: true)
    }
    
    @objc func editButtonTapped() {
       let editPortfoliosVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditPortfoliosTVC") as! EditPortfoliosTVC
        editPortfoliosVC.portfoliosResults = self.portfoliosResults
        navigationController?.pushViewController(editPortfoliosVC, animated: true)
    }
    
    func isAddPortfolioState() -> Bool {
        let currentPage = titleView.pageControl.currentPage
        return portfoliosResults!.count == 0 || currentPage == portfoliosResults!.count
    }
    
    func openChooseCoinViewController() {
         let chooseCoinNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseCoinNavController") as! UINavigationController
         
        let chooseCoinTVC = chooseCoinNavController.viewControllers.first as! ChooceCoinTVC
        chooseCoinTVC.delegate = self
         
         self.present(chooseCoinNavController, animated: true, completion: nil)
    }
    
    //MARK: UI Logic
    func displayPortfolioTypeOptionMenu() {
        let optionMenu = UIAlertController(title: nil, message: "Choose", preferredStyle: .actionSheet)
            
        let exchangeAction = UIAlertAction(title: "From Exchange", style: .default) { [weak self] (action) in
            let chooseExchangeTVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseExchangeTVC") as! ChooseExchangeTVC
           
            chooseExchangeTVC.delegate = self
            
            self?.navigationController?.pushViewController(chooseExchangeTVC, animated: true)
            
        }
        
        let manualAction = UIAlertAction(title: "Manual", style: .default) { [weak self] (action) in
            let enterNameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterNameVC") as! EnterNameVC
            self?.navigationController?.pushViewController(enterNameVC, animated: true)
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
        optionMenu.addAction(exchangeAction)
        optionMenu.addAction(manualAction)
        optionMenu.addAction(cancelAction)
            
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func hidePlusButton() {
        let plusBarButtonItem = navigationItem.rightBarButtonItems![0]
        plusBarButtonItem.isEnabled = false
        plusBarButtonItem.tintColor = UIColor.clear
    }
    func showPlusButton() {
        let plusBarButtonItem = navigationItem.rightBarButtonItems![0]
        plusBarButtonItem.isEnabled = true
        plusBarButtonItem.tintColor = UIColor.orange
    }
    
    func showActivityIndicator() {
        collectionView?.isHidden = true
        self.tabBarController?.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicator() {
        collectionView?.isHidden = false
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
    }
    
    deinit {
        portfoliosToken?.invalidate()
    }
}

extension PortfoliosCVC : UICollectionViewDelegateFlowLayout {

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return portfoliosResults!.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        if (indexPath.row == portfoliosResults!.count) { // last object
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPortfolioCVCell", for: indexPath) as! AddPortfolioCVCell
            return cell
        }
    
        // Configure the cell
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortfolioCVCell", for: indexPath) as! PortfolioCVCell
        
        cell.portfolio = portfoliosResults![indexPath.row].copy() as? Portfolio
        
        cell.configure()
        
        return cell
    }
    
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight = (self.navigationController?.navigationBar.frame.size.height)!
    let tabBarHeight = (self.tabBarController?.tabBar.frame.size.height)!
    
    let height = collectionView.frame.size.height - statusBarHeight - navigationBarHeight - tabBarHeight
    
    let size = CGSize(width: self.view.bounds.width, height: height)
    
    return size
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
    
    
    

    // MARK: ScrollView Override
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = self.collectionView!.frame.size.width
        let currentPage = Int(self.collectionView!.contentOffset.x / pageWidth)
        titleView.pageControl.currentPage = currentPage
        updateTitleViewNameAndPlusButton()
    }
    
    func fetchDataForPage(page: Int) {
        let indexPath = IndexPath(row: page, section: 0)
        if let cell = collectionView?.cellForItem(at: indexPath) as? PortfolioCVCell {
            cell.fetchData()
        }
    }
    
    func updateTitleViewNameAndPlusButton() {
        if isAddPortfolioState() {
            titleView.titleLabel.text = "Portfolios"
            showPlusButton()
        }
        else {
            let portfolio = portfoliosResults![titleView.pageControl.currentPage]
            titleView.titleLabel.text = portfolio.name
            if portfolio.type == PortfolioType.Exchange.rawValue {
                hidePlusButton()
            }
            else {
                showPlusButton()
            }
        }
    }
    
}


