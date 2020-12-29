//
//  EditProtfolioVC.swift
//  ZZBitRate
//
//  Created by avi zazati on 07/09/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import UIKit

//protocol EditProtfolioDelegate: class {
//    func editProtfolioDidClose()
//}

class EditProtfolioVC: UIViewController , UITableViewDelegate,UITableViewDataSource,EditProtfolioTableViewCellDelegate {
    
    @IBOutlet weak var plusImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var dataSource : Array <UserHolding> = []
    
    //weak var dalegate: EditProtfolioDelegate?
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true,completion: nil)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        plusImageView.tintColor = .orange
        
        self.title = "Edit Portfolio" 
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addNewButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "editProtfolioAddNewSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataSource = Array(CoreDataManager.shared.fatchAllHolding())
        self.tableView.reloadData()
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditProtfolioTableViewCell") as! EditProtfolioTableViewCell
        cell.deleteButton.tintColor = .red
        cell.delegate = self
        cell.indexPath = indexPath

        
        let userHolding = self.dataSource[indexPath.row]
        
        let imageUrl = UserDataManager.shared.imagesDict[userHolding.coinNameId]
        if let imageUrl = imageUrl {
            let url = URL(string: imageUrl)
            cell.coinImageView.kf.setImage(with: url)
        }
        
        cell.coinNameLabel.text = "\(userHolding.coinName) (\(userHolding.coinNameId))"
        cell.coinAmountLabel.text = "x\(userHolding.amount)"
        return cell
    }
    
    func didClickDeleteButton(indexPath : IndexPath) {
        
        let userHolading = self.dataSource[indexPath.row]
        
        
        let title = "\(userHolading.coinNameId)"
        let message = "Are you sure you want to delete \(userHolading.coinName) from your protfolio?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .blue
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
            
            DispatchQueue.main.async {
                CoreDataManager.shared.deleteUserHoldingWith(coinNameId: userHolading.coinNameId)
                self.dismiss(animated: true, completion: nil)

                
            }
        }))
        
        self.present(alert, animated: true)
        
    }



    func didClickEditButton(indexPath : IndexPath) {
        
        let userHolading = self.dataSource[indexPath.row]
        performSegue(withIdentifier: "EditProtfolioButtonSegue", sender: userHolading)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "EditProtfolioButtonSegue" {
            
            let coin = sender as? UserHolding
            let vc = segue.destination as! AddNewHoldingVC
            vc.coinNameID = coin?.coinNameId
            vc.coinName = coin?.coinName
        }
        
        if segue.identifier == "editProtfolioAddNewSegue" {
        
        }

        
    }

}

