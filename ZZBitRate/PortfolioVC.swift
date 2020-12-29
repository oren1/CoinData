//
//  PortfolioVC.swift
//  ZZBitRate
//
//  Created by avi zazati on 29/08/2018.
//  Copyright © 2018 aviza. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class PortfolioVC: UIViewController ,ChartViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {


    @IBOutlet weak var addFirstValueView: UIView!
    @IBOutlet weak var plusImage: UIImageView!
    
    @IBOutlet weak var rightNavButton: UIBarButtonItem?
    @IBOutlet weak var collectionView: UICollectionView!
    
    //@IBOutlet weak var detailsView: UIView!
    //@IBOutlet weak var detailsTitleLabel: UILabel!
    //@IBOutlet weak var detailsViewAmountLabel: UILabel!
   // @IBOutlet weak var detailsViewImageView: UIImageView!
    
   // @IBOutlet weak var detailsViewTotalLabel: UILabel!
    
    

    
    @IBOutlet weak var chartView: PieChartView!
    
//    let colorAarray = [UIColor(red: 255/255, green: 1/255, blue: 1/255, alpha: 1)]
//        + [UIColor(red: 1/255, green: 125/255, blue: 1/255, alpha: 1)]
//        + [UIColor(red: 255/255, green: 100/255, blue: 0/255, alpha: 1)]
//        + [UIColor(red: 1/255, green: 1/255, blue: 255/255, alpha: 1)]
//        + [UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 1)]
//        + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
    
   // var colorAarray : Array<UIColor> = [.red, .blue ,.green, .yellow,.orange,.cyan]
    var colorAarray : Array<UIColor> = []

//
    var selectedUserHolding : UserHolding?
    var dataSource : Array <UserHolding> = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Protfolio"
        
        colorAarray = [.orange,
                       UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0),
                        UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
                        UIColor(red: 153/255, green: 0.0, blue: 76/255, alpha: 1.0),
                        UIColor(red: 102/255, green: 0.0, blue: 204/255, alpha: 1.0),
                        UIColor(red: 0.0, green: 0.55, blue: 0.55, alpha: 1.0),
                        UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
                        UIColor(red: 153/255, green: 0.0, blue: 76/255, alpha: 1.0),
                        UIColor(red: 102/255, green: 0.0, blue: 204/255, alpha: 1.0),
                        UIColor(red: 0.0, green: 0.55, blue: 0.55, alpha: 1.0)


                        
        ]
        plusImage.tintColor = .orange
        self.setup(pieChartView: chartView)
        
        chartView.delegate = self
        
//        chartView.legend.enabled = false
        chartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        
        //self.setDataCount(coinsArray: self.dataSource)
//
//        detailsView.layer.cornerRadius = 8.0
//        detailsView.layer.borderWidth = 1.0
//        detailsView.layer.borderColor = UIColor.orange.cgColor
//        detailsView.alpha = 0.0

        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
   
    }
    
    
    @IBAction func detailsViewEditButtonTapped(_ sender: Any) {
        
        if let userHolding = selectedUserHolding {
            performSegue(withIdentifier: "EditHoldingSegue", sender: userHolding)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let resultArray = CoreDataManager.shared.fatchAllHolding()
        
        if resultArray.count > 0 {
            self.navigationItem.rightBarButtonItem = rightNavButton
            let rightNavButton1 = UIBarButtonItem(title: "Edit / Add", style: .plain, target: self, action: #selector(self.rightNavButtonTapped))
            self.navigationItem.rightBarButtonItem = rightNavButton1
        }else {
            self.navigationItem.rightBarButtonItem = rightNavButton
            let rightNavButton2 = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.rightNavButtonTapped))
            self.navigationItem.rightBarButtonItem = rightNavButton2

        }
        
        if resultArray.count > 0 {
            
           addFirstValueView.alpha = 0

         // no highlight for only one value
         chartView.highlightPerTapEnabled = resultArray.count != 1

             //let allCoinsArray = chaceManager.shared.allCoinArray
            
            CoreDataManager.shared.setPricesFor(holdingArray: resultArray) { (updatedHoldingArray) in
                
                self.dataSource = Array(updatedHoldingArray)
                self.setDataCount(holdingArray: self.dataSource)
                self.collectionView.reloadData()
            }
            

//
//            NetworkManager.shared.setPricesFor(holdingArray: resultArray) { (updatedHoldingArray) in
//
//                self.dataSource = Array(updatedHoldingArray)
//                self.setDataCount(holdingArray: self.dataSource)
//                self.collectionView.reloadData()
//            }
            
        }
        else {
            
            addFirstValueView.alpha = 1
            //fake results
            
            chartView.highlightPerTapEnabled = true
            self.dataSource = []
            self.setFakeData()
            self.collectionView.reloadData()
                        
        }
        
        //self.setup(pieChartView: chartView)

        

        
//        NetworkManager.shared.getFavoritesCoins { [weak self] arr in
//            self?.dataSource = arr
//            DispatchQueue.main.async {
//                self?.setDataCount(coinsArray: (self?.dataSource)!)
//                //self?.chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
//
//                self?.chartView.spin(duration: 1.0,
//                                     fromAngle: (self?.chartView.rotationAngle)!,
//                                     toAngle: (self?.chartView.rotationAngle)! + 360,
//                               easingOption: .easeInCubic)
//
//            }
//        }
        
    }
    
    func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = false
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.78
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.chartDescription?.enabled = false
        //chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        chartView.drawCenterTextEnabled = true
        chartView.holeColor = .black

        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0
        chartView.rotationEnabled = true
        
        
        chartView.highlightPerTapEnabled = true
        
   
      //  chartView.xAxis.axisMinimum = 20
        //chartView.leftAxis.customAxisMin = 20

        
        setCenterText()
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
        l.textColor = .white
        
               // chartView.legend = l
    }
    
    func setCenterText() {
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingHead
        paragraphStyle.alignment = .center
        
        //let priceStr = "$0.00"
        
        let doubleStr = String(format: "%.2f", getTotal()) // "3.14"
        let priceStr = "$" + "\(doubleStr)"

        let centerText = NSMutableAttributedString(string: "Your Balance: \n" + priceStr)
        centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 20)!,
                                  .foregroundColor : UIColor.white], range: NSRange(location: 0, length: centerText.length))
        
        centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 20)!,
                                  .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
        
        centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 30)!,
                                  .paragraphStyle : paragraphStyle], range: NSRange(location: 13, length: centerText.length - 13))
        //
        //        centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 11)!,
        //                                  .foregroundColor : UIColor.gray], range: NSRange(location: 10, length: centerText.length - 10))
        //        centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 11)!,
        //                                  .foregroundColor : UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)], range: NSRange(location: centerText.length - 19, length: 19))
        //
        
        chartView.centerAttributedText = centerText
    }
    
    func setDataCount(holdingArray: Array<UserHolding>) {
        let entries = (0..<holdingArray.count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            
            
            let totalUSD :Double = holdingArray[i].totalUSD
            let doubleStr = String(format: "%.2f", totalUSD) // "3.14"
            let val:Double =  Double(doubleStr) ?? 0.0

            return PieChartDataEntry(value: val,
                                     label: holdingArray[i].coinNameId,
                                     data:holdingArray[i])
        }
        
        let set = PieChartDataSet(entries: entries, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 4
        
        var arr :Array<UIColor> = []
        for (i,_) in holdingArray.enumerated() {
            arr.append(self.colorAarray[i % self.colorAarray.count])
        }
       
        set.colors = arr
//        set.colors = [UIColor(red: 255/255, green: 1/255, blue: 1/255, alpha: 1)]
//            + [UIColor(red: 1/255, green: 125/255, blue: 1/255, alpha: 1)]
//            + [UIColor(red: 255/255, green: 100/255, blue: 0/255, alpha: 1)]
//            + [UIColor(red: 1/255, green: 1/255, blue: 255/255, alpha: 1)]
//            + [UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 1)]
//            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        set.valueLinePart1OffsetPercentage = 0.8
        set.valueLinePart1Length = 0.2
        set.valueLinePart2Length = 0.4
        //set.xValuePosition = .outsideSlice
        set.yValuePosition = .outsideSlice
        set.valueLineColor = .white
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .currency
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        //pFormatter.percentSymbol = " %"
        pFormatter.currencySymbol = " $"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 10, weight: .bold))
        data.setValueTextColor(.white)
        
        chartView.data = data
        chartView.highlightValues(nil)
        
        setCenterText()
    }
    
    func setFakeData() {
        
        let entries = (0..<3).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            
            return PieChartDataEntry(value: 0.33,
                                     label: "")
        }
        
        let set = PieChartDataSet(entries: entries, label: "")
        set.drawIconsEnabled = false
        set.drawValuesEnabled = false
    
        set.sliceSpace = 4
        
        var arr :Array<UIColor> = []
        for i in 0..<3 {
            arr.append(self.colorAarray[i % self.colorAarray.count])
        }
        
        set.colors = arr

        set.valueLinePart1OffsetPercentage = 0.8
        set.valueLinePart1Length = 0.2
        set.valueLinePart2Length = 0.4
        //set.xValuePosition = .outsideSlice
        set.yValuePosition = .outsideSlice
        set.valueLineColor = .white
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .currency
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        //pFormatter.percentSymbol = " %"
        pFormatter.currencySymbol = " $"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 10, weight: .bold))
        data.setValueTextColor(.white)
        
        chartView.data = data
        chartView.highlightValues(nil)
        
        setCenterText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTotal() -> Double {
        var sum = 0.0
//        let resultArray = CoreDataManager.shared.fatchAllHolding()
//
//        for userHold in resultArray {
//           sum += userHold.totalUSD
//        }
//
//        if (sum > 100) {
//            sum = Double(Int(sum)) // cast to int and back
//        }
        
        
        for userholding in self.dataSource {
            sum += userholding.totalUSD
        }
        
        return sum
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "EditHoldingSegue" {
            
            let coin = sender as? UserHolding
            let vc = segue.destination as! AddNewHoldingVC
            //vc.coin = coin
            vc.coinNameID = coin?.coinNameId
            vc.coinName = coin?.coinName
            //performSegue(withIdentifier:"Popover", sender: self)
        }
        
        if segue.identifier == "addNewCoinSegue" {
            

        }
        if segue.identifier == "EditprotfolioSegue" {
            
            
        }
        
    }
    
     //MARK: - Chart Delegate
    
    /// Called when a value has been selected inside the chart.
    /// - parameter entry: The selected Entry.
    /// - parameter highlight: The corresponding highlight object that contains information about the highlighted position such as dataSetIndex etc.
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //detailsView.alpha = 1.0
        //detailsView.layer.borderColor = highlight
       // print("entry : \(entry)")
        
        
        if let userHolding = entry.data as? UserHolding {
       // print("userHolding : \(userHolding)")
        updateDetailesViewFrom(userHolding:userHolding)
        print("highlight : \(highlight)")
        selectedUserHolding = userHolding
//        let index = highlight.dataSetIndex
//        print("Selected \(index)")
        let index = self.dataSource.index(of: userHolding) ?? 0
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        }

    }
    
    // Called when nothing has been selected or an "un-select" has been made.
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        //detailsView.alpha = 0.0
        selectedUserHolding = nil

    }
    
    func updateDetailesViewFrom(userHolding:UserHolding ) {
        
//        let imageUrl = UserDataManager.shared.imagesDict[userHolding.coinNameId]
//        if let imageUrl = imageUrl {
//            let url = URL(string: imageUrl)
//            detailsViewImageView.kf.setImage(with: url)
//        }
//
//        detailsTitleLabel.text = "\(userHolding.coinName) (\(userHolding.coinNameId))"
//        detailsViewAmountLabel.text = "\(userHolding.amount)"
//        detailsViewTotalLabel.text = "\(userHolding.amount * userHolding.priceForOneCoin)"
    
    }
    //MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProtfolioCollectionViewCell", for: indexPath) as! ProtfolioCollectionViewCell
        let userHolding = dataSource[indexPath.row]
        
        
        let imageUrl = UserDataManager.shared.imagesDict[userHolding.coinNameId]
        if let imageUrl = imageUrl {
            let url = URL(string: imageUrl)
            cell.coinImageView.kf.setImage(with: url)
        }
        cell.divider.backgroundColor = colorAarray[indexPath.row % self.colorAarray.count]
        //cell.labelTitle.text = "\(userHolding.coinName) (\(userHolding.coinNameId))"
        cell.labelTitle.text = "\(userHolding.coinName)"

        cell.labelAmount.text = "x \(userHolding.amount)"
        cell.labelTotal.text = "$" + "\(userHolding.amount * userHolding.priceForOneCoin)".priceFormat
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //    let userholding = self.dataSource[indexPath.row]


    }
    
    @IBAction func rightNavButtonTapped(_ sender: Any) {
        
        let resultArray = CoreDataManager.shared.fatchAllHolding()

        if resultArray.count > 0 {
            performSegue(withIdentifier: "EditprotfolioSegue", sender: nil)
        }
        else {
            performSegue(withIdentifier: "addNewCoinSegue", sender: nil)
        }
        
        
    }
    
    @IBAction func addFirstValueButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "addNewCoinSegue", sender: nil)
    }

}
