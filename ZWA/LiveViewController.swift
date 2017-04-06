//
//  LiveViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/24.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class LiveViewController: UITableViewController {
    
    
    /*
    // 给TableView加点装饰
    */
    func decorateTableView() -> Void {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        var frame = indicator.frame
        frame.origin.x = (self.tableView.bounds.size.width - frame.size.width) / 2.0
        frame.origin.y = -44 + (44 - frame.size.height) / 2.0
        indicator.frame = frame
        self.tableView.addSubview(indicator)
        indicator.startAnimating()

        /*
        let w = self.tableView.bounds.size.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: w, height: 38))
        view.backgroundColor = UIColor.groupTableViewBackground
        
        let h = view.bounds.size.height
        var button = UIButton(frame: CGRect(x: 8, y: 0, width: 40, height: h))
        button.setTitle("时间", for: .normal)
        view.addSubview(button)
        
        button = UIButton(frame: CGRect(x: 48, y: 0, width: 40, height: h))
        button.setTitle("车牌", for: .normal)
        view.addSubview(button)
        
        self.tableView.tableHeaderView = view
        */
    }
    
    /*/*
    // 从记录集创建状态字符串
    */
    func statusStringWithResultDictionary(dic: [AnyHashable: Any?]) -> NSAttributedString? {
        let overRate = dic[ "OverRate"] as? Double
        let widthOver = dic[ "WidthOver"] as? Double
        let heightOver = dic[ "HeightOver"] as? Double
        let lengthOver = dic[ "LengthOver"] as? Double
        
        var string = "正常"
        var color = UIColor.black
        if (overRate != nil && overRate! > 0.0)
        || (widthOver != nil && widthOver! > 0.0)
        || (heightOver != nil && heightOver! > 0.0)
        || (lengthOver != nil && lengthOver! > 0.0) {
            string = "异常"
            color = .red
        }
        
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: color])
    }
    */
    
    func pullRecentData() -> Void {
        let indicator = MyActivityIndicatorView()
        indicator.show()
        
        let _ = LiveDataService.service.pullData(completion: { (success: Bool, collection: (Int, Int, Int)?) ->Void in
            indicator.dismiss()
            
            if success {
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
      
        decorateTableView()
        self.pullRecentData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return LiveDataService.service.visibleCollection.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveTableVeiwCell", for: indexPath) as! LiveTableViewCell

        // Configure the cell...
        if let data = LiveDataService.service.dataAtIndexPath(indexPath: indexPath) {
            cell.statusLabel.text = "\(data.overWeightRate)"
            cell.plateLabel.text = data.carNo
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            if let time = data.scaleDate {
                cell.timeLabel.text = formatter.string(from: time)
            }
        }

        return cell
    }

//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row >= self.recCount - 1 {
//            self.recCount = self.increaseRecCount(recCount: self.recCount)
//            tableView.reloadData()
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UIScrollViewDelegate
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offset = scrollView.contentOffset.y
//        if offset <= -48 {
//            let recCount = self.increaseRecCount(recCount: self.recCount)
//            if recCount != self.recCount {
//            }
//            
//        }
//    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let insets = scrollView.contentInset
        let h = scrollView.contentSize.height
        let y = offset.y + bounds.size.height - insets.bottom
        
        if offset.y + insets.top < -44 {
            var insets = scrollView.contentInset
            insets.top += 44
//            scrollView.contentInset = insets
        }
        else if y > h +  44{
        }
    }
}
