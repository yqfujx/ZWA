//
//  ChartViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/15.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let items = [PNPieChartDataItem.init(value: 10, color: UIColor.red),
                     PNPieChartDataItem.init(value: 20, color: UIColor.blue, description: "WWDC"),
                     PNPieChartDataItem.init(value: 40, color: .green, description: "GOOLI/O")]
        
        let pieChart = PNPieChart(frame: CGRect(x: 40.0, y: 155.0, width: 240.0, height: 240.0), items: items)
        pieChart?.descriptionTextColor = UIColor.white
        pieChart?.descriptionTextFont = UIFont.init(name: "Avenir-Medium", size: 14.0)
        pieChart?.stroke()
        
        self.view.addSubview(pieChart!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
