//
//  ChartViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/15.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

fileprivate enum ChartMode {
    case pie, pillar
}

fileprivate struct ChartItem {
    var color: UIColor!
    var description: String!
    var value: CGFloat!
}

class ChartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var sectionData: StatisticsSection?
    private var _chartItems: [ChartItem]?
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func segmentChanged(_ sender: Any?) {
        let sender = sender as! UISegmentedControl
        let mode = (sender.selectedSegmentIndex == 0 ? ChartMode.pie : ChartMode.pillar)
        
        self.display(inMode: mode)
    }
    
    func makeChartItems() -> Bool {
        guard let rows = self.sectionData?.rows else {
            return false
        }
        
        self._chartItems = []
        for row in rows {
            if row.indivisible && row.value > 0 {
                let item = ChartItem(color: UIColor.randomOpaque, description: row.description, value: CGFloat(row.value))
                self._chartItems?.append(item)
            }
        }
        
        return true
    }
    
    fileprivate func display(inMode mode: ChartMode) -> Void {
        guard let count = self._chartItems?.count, count > 0 else {
            return
        }
        
        var oldChart: UIView?
        var newChar: UIView?
        
        if self.placeholderView.subviews.count > 0 {
            oldChart = self.placeholderView.subviews[0]
        }
        
        
        if mode == .pie {
            var items = [PNPieChartDataItem]()
            for data in self._chartItems! {
                items.append(PNPieChartDataItem(value: data.value, color: data.color))
            }
            
            let pieChart = PNPieChart(frame: self.placeholderView.bounds.insetBy(dx: 20, dy: 20), items: items)
            pieChart?.stroke()
            newChar = pieChart
        }
        else if mode == .pillar {
            var bars = [PNBar]()
            var xLabels = [String]()
            var yValues = [CGFloat]()
            var colors = [UIColor]()
            for data in self._chartItems! {
                let bar = PNBar()
                bar.barColor = data.color
                bars.append(bar)

                xLabels.append(data.description)
                yValues.append(data.value)
                colors.append(data.color)
            }
            
            let barChart = PNBarChart(frame: self.placeholderView.bounds)
            barChart.showLabel = false
            barChart.showChartBorder = true
            barChart.chartMarginBottom = 30
            barChart.barWidth = 30
            
            barChart.xLabels = xLabels
            barChart.yValues = yValues
            barChart.strokeColors = colors
            barChart.stroke()
            newChar = barChart
        }
        
        if oldChart != nil {
            UIView.transition(from: oldChart!, to: newChar!, duration: 0.35, options: [.transitionCrossDissolve], completion: nil)
        }
        else {
            self.placeholderView.addSubview(newChar!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.sectionData?.description
        if self.makeChartItems() {
            self.display(inMode: .pie)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = self._chartItems?.count {
            return num
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = self._chartItems![indexPath.row]
        
        cell.imageView?.image = row.color.rectImage(size: CGSize(width: 16, height: 16))
        cell.textLabel?.text = row.description
        cell.detailTextLabel?.text = String(format: "%d", arguments: [Int(row.value)])
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
