//
//  PortfolioCollectionViewCell.swift
//  ZZBitRate
//
//  Created by oren shalev on 30/09/2020.
//  Copyright © 2020 aviza. All rights reserved.
//

import UIKit
import Charts
import RealmSwift
import NVActivityIndicatorView
import Kingfisher

class PortfolioCVCell: UICollectionViewCell, ChartViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var piChartTableViewHeader: PieChartView!
    var portfolio: Portfolio!
    var rates: [String: Double] = [:]
    var storedError: Error?
    var activityIndicatorView : NVActivityIndicatorView!
    var currentTotalUSD: String = ""
    
    var colorAarray : Array<UIColor> = [.orange,
                   UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
                    UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0),
                    UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
                    UIColor(red: 153/255, green: 0.0, blue: 76/255, alpha: 1.0),
                    UIColor(red: 102/255, green: 0.0, blue: 204/255, alpha: 1.0),
                    UIColor(red: 0.0, green: 0.55, blue: 0.55, alpha: 1.0),
                    UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
                    UIColor(red: 153/255, green: 0.0, blue: 76/255, alpha: 1.0),
                    UIColor(red: 102/255, green: 0.0, blue: 204/255, alpha: 1.0),
                    UIColor(red: 0.0, green: 0.55, blue: 0.55, alpha: 1.0)]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func configure() {
        currentTotalUSD = ""
        tableView.delegate = self
        tableView.dataSource = self
        
        self.setup(pieChartView: piChartTableViewHeader)
        piChartTableViewHeader.delegate = self
        piChartTableViewHeader.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        piChartTableViewHeader.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)

        //fake results
                
        piChartTableViewHeader.highlightPerTapEnabled = true
        setFakeData()
        
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: piChartTableViewHeader.bounds.width, height: piChartTableViewHeader.bounds.size.height) , type: .ballClipRotateMultiple, color: .white, padding: 120)
        
    
        piChartTableViewHeader.centerText = ""
        
        showActivityIndicator()
        fetchData()
        
    }
    
    
    // MARK: Network Calls
    @objc func fetchData() {
        
        let portfolioType = PortfolioType(rawValue: portfolio.type)
        switch portfolioType {
        case .Manual:

            getPricesWithCompletion { [weak self] in
                
                self?.hideActivityIndicator()
                if let error = self?.storedError {
                    self?.showError(error: error)
                    self?.storedError = nil
                }
                else {
                    print("getPricesWithCompletion")
                    self?.setChartData()
//                    self?.setCenterText()
                    self?.tableView.reloadData()
                }
            }
            
        case .Exchange:
                       getExchangeBalanceWithCompletion { [weak self] in
                        self?.getPricesWithCompletion { [weak self] in
                            
                            self?.hideActivityIndicator()
                            if let error = self?.storedError {
                                self?.showError(error: error)
                                self?.storedError = nil
                            }
                            else {
                                print("getPricesWithCompletion")
                                self?.setChartData()
//                                self?.setCenterText()
                                self?.tableView.reloadData()
                            }
                        }
                       }
            
        default:
            print("error")
        }
    }
    
    func getPricesWithCompletion(completion: @escaping () -> ()) {
     
        let fsymsArr = portfolio.balance.map({ $0.symbol })
        let fsyms = fsymsArr.joined(separator: ",")
        NetworkManager.shared.getPricesFor(fsyms: fsyms, tsym: "USD") { [weak self] (rates, error) in
            if let error = error {
                self?.storedError = error
            }
            else {
                self?.rates = rates
            }
            completion()
        }
    }
    func getExchangeBalanceWithCompletion(completion: @escaping () -> ()) {
        
            NetworkManager.shared.getExchangeBalance(exchangeName: portfolio.exchangeName,
                                                     token: portfolio.token) { [weak self] (balance, error) in
                if let error = error {
                    self?.storedError = error
                }
                else {
                    
                        let balanceList = List<CoinBalance>()
                        balanceList.append(objectsIn: balance)
                        self?.portfolio.balance = balanceList
                    
                }
                completion()
        }
    }
    func showError(error: Error) {
        
        guard let generalMessageView = UINib(nibName: "GeneralMessageView", bundle: .main).instantiate(withOwner: nil, options: nil).first as? GeneralMessageView else {
            return
        }
        
        generalMessageView.messageLabel.text = error.localizedDescription
        generalMessageView.makeRoundEdges()
        
        self.addSubview(generalMessageView)
        NSLayoutConstraint.activate([
            generalMessageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            generalMessageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            generalMessageView.widthAnchor.constraint(equalToConstant: 300),
            generalMessageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        self.layoutSubviews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            generalMessageView.removeFromSuperview()
        }
        
    }
    
    // MARK: Chart Logic
     func setup(pieChartView chartView: PieChartView) {
         chartView.usePercentValuesEnabled = false
         chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.85
         chartView.transparentCircleRadiusPercent = 0.61
         chartView.chartDescription?.enabled = false
         //chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
         chartView.drawCenterTextEnabled = true
         chartView.holeColor = .black
        
         chartView.drawHoleEnabled = true
         chartView.rotationAngle = 0
         chartView.rotationEnabled = true
         chartView.highlightPerTapEnabled = true
//        chartView.xAxis.axisMinimum = 20
       //  chartView.xAxis.axisMinimum = 20
         //chartView.leftAxis.customAxisMin = 20

         
//         setCenterText()
         
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
        
            var tailColor: UIColor
            let newTotalUSDString = getTotal().priceFormamtWithCurrencySign()


            let result = currentTotalUSD.compare(newTotalUSDString)
            if result == .orderedAscending {
                tailColor = UIColor(red: 59/255, green: 170/255, blue: 0, alpha: 1)
            }
            else if result == .orderedDescending {
                tailColor = UIColor.red
            }
            else {
                tailColor = UIColor.white
            }
        
            let changeIndex = getIndexOfFirstChangedChar(currentPrice: currentTotalUSD, newPrice: newTotalUSDString)
        
            let centerText = NSMutableAttributedString(string: "Your Balance:\n" + newTotalUSDString)
            centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 18),
                                      .paragraphStyle : paragraphStyle,
                                      .foregroundColor : UIColor.white], range: NSRange(location: 0, length: 14))
        
            if changeIndex == -1 { // There is no change in the price or it's the first value so that means no change. so color the hole price string
                centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 26)!,
                                          .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.white], range: NSRange(location: 14, length: newTotalUSDString.count))
            }
        
            else {
                    centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 26)!,
                                          .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.white], range: NSRange(location: 14, length: changeIndex))
                
                    centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Light", size: 26)!,
                                              .paragraphStyle : paragraphStyle, .foregroundColor: tailColor], range: NSRange(location: 14 + changeIndex, length: newTotalUSDString.count - changeIndex))
            }
        
            piChartTableViewHeader.centerAttributedText = centerText
            currentTotalUSD = newTotalUSDString
        
        }
    
    func getIndexOfFirstChangedChar(currentPrice: String, newPrice: String) -> Int {
        
        for (index,currentChar) in currentPrice.enumerated() {
           let newChar = newPrice[index]
            if currentChar != newChar {
                return index
            }
        }
        return -1
    }
    
    func setChartData() {
        
        if (portfolio.balance.count == 0) {
           return
        }
        
        var entries: [PieChartDataEntry] = []
        for index in 0...portfolio.balance.count - 1 {
            let coinBalance = portfolio.balance[index]
            if let usdRate = rates[coinBalance.symbol] {
            let totalUSD: Double = coinBalance.amount * usdRate
            let doubleStr = String(format: "%.2f", totalUSD) // "3.14"
            let val:Double =  Double(doubleStr) ?? 0.0
                entries.append(PieChartDataEntry(value: val,
                label: coinBalance.symbol,
                data:coinBalance))
            }
        }
            
                
                let set = PieChartDataSet(entries: entries, label: "")
                set.drawIconsEnabled = false
                set.sliceSpace = 4
                set.drawValuesEnabled = false
        
                var arr: Array<UIColor> = []
                for (i,_) in portfolio.balance.enumerated() {
                    arr.append(self.colorAarray[i % self.colorAarray.count])
                }
                
                set.colors = arr
        //        set.colors = [UIColor(red: 255/255, green: 1/255, blue: 1/255, alpha: 1)]
        //            + [UIColor(red: 1/255, green: 125/255, blue: 1/255, alpha: 1)]
        //            + [UIColor(red: 255/255, green: 100/255, blue: 0/255, alpha: 1)]
        //            + [UIColor(red: 1/255, green: 1/255, blue: 255/255, alpha: 1)]
        //            + [UIColor(red: 255/255, green: 100/255, blue: 100/255, alpha: 1)]
        //            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
                
//                set.valueLinePart1OffsetPercentage = 0.1
                set.valueLinePart1Length = 0.1
                set.valueLinePart2Length = 0.1
                set.xValuePosition = .outsideSlice
                set.yValuePosition = .outsideSlice
                set.valueLineColor = .clear
        
        
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
                
                piChartTableViewHeader.data = data
                piChartTableViewHeader.highlightValues(nil)
                
                setCenterText()
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
    
        
        piChartTableViewHeader.data = data
        piChartTableViewHeader.highlightValues(nil)
        
        setCenterText()
    }
    
     func getTotal() -> Double {
        var sum = 0.0
        for coinBalance in portfolio.balance {
            if let usdRate = rates[coinBalance.symbol] {
                sum += coinBalance.amount * usdRate
            }
        }
        return sum
        
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//        numberFormatter.usesSignificantDigits = false
//        numberFormatter.maximumFractionDigits = 2
//        numberFormatter.minimumFractionDigits = 2
//
//        let currencySign = "$"
//        return currencySign + numberFormatter.string(from: NSNumber(value: sum))!
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
        
        piChartTableViewHeader.data = data
        piChartTableViewHeader.highlightValues(nil)
        
        setCenterText()
    }
   
    
    // MARK: Activity Indicator
    func showActivityIndicator() {
        self.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicatorView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
    }
    

         //MARK: - Chart Delegate
        
        /// Called when a value has been selected inside the chart.
        /// - parameter entry: The selected Entry.
        /// - parameter highlight: The corresponding highlight object that contains information about the highlighted position such as dataSetIndex etc.
//        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//            //detailsView.alpha = 1.0
//            //detailsView.layer.borderColor = highlight
//           // print("entry : \(entry)")
//
//
//            if let userHolding = entry.data as? UserHolding {
//           // print("userHolding : \(userHolding)")
//            updateDetailesViewFrom(userHolding:userHolding)
//            print("highlight : \(highlight)")
//            selectedUserHolding = userHolding
//    //        let index = highlight.dataSetIndex
//    //        print("Selected \(index)")
//            let index = self.dataSource.index(of: userHolding) ?? 0
//            let indexPath = IndexPath(item: index, section: 0)
//            self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
//            }
//
//        }
//
//        // Called when nothing has been selected or an "un-select" has been made.
//        func chartValueNothingSelected(_ chartView: ChartViewBase) {
//            //detailsView.alpha = 0.0
//            selectedUserHolding = nil
//
//        }
    
}


// MARK: UITableViewDelegate
extension PortfolioCVCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (portfolio.balance.count == 0) {
            return 1
        }
        
        return portfolio.balance.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (portfolio.balance.count == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddCoinTVCell", for: indexPath) as! AddCoinTVCell
                return cell
        }
        
        
        let coinBalance = portfolio.balance[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioCoinTVCell", for: indexPath) as! PortfolioCoinTVCell
        
        let imageUrl = UserDataManager.shared.imagesDict[coinBalance.symbol]
        if let imageUrl = imageUrl {
            
            let url = URL(string: imageUrl)
            cell.coinImageView.kf.setImage(with: url)
            // Make Image Corners Rounded
            cell.coinImageView.makeRoundCorners()

        }
        else {
            // USD imageUrl dont exist in the 'imagesDict' so adding a quick fix here
            if coinBalance.symbol == "USD" {
                cell.coinImageView.image = UIImage(named: "DollarUSDicon")
            }
            else {
                cell.coinImageView.image = nil
            }
        }
        
        cell.symbolLabel.text = coinBalance.symbol
        cell.amountLabel.text = String(coinBalance.amount)
       
        if let rate = rates[coinBalance.symbol] {
            let total = coinBalance.amount * rate
            cell.totalLabel.text = total.priceFormamtWithCurrencySign()
        }
        else {
            cell.totalLabel.text = "Rate Error"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (portfolio.balance.count == 0 && indexPath.row == 0) {
            tableView.deselectRow(at: indexPath, animated: true)
            if let portfolioCVController = self.findViewController() as? PortfoliosCVC {
                portfolioCVController.addButtonTapped()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UINib(nibName: "PortfolioTableSectionHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PortfolioTableSectionHeader
        
        headerView.leftLabel.text = "Name"
        headerView.centerLabel.text = "Amount"
        headerView.rightLabel.text = "Total"
        
        return headerView

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
}
