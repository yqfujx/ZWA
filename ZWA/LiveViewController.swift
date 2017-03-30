//
//  LiveViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/24.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class LiveViewController: UITableViewController {

    var recCount = 0
    var maxRecNo = 0
    
    // MARK: - 功能函数
    /**
     增长正在显示的记录数
     */
    func increaseRecCount ( recCount: Int, delta: Int = 50) -> Int {
        var recCount = recCount
        let dbQueue = DatabaseManager.DBM?.dbQueue
        
        dbQueue?.inDatabase({ (database: FMDatabase?) in
            let sql = "SELECT COUNT(*) FROM \(DatabaseManager.TableName.Live) LIMIT \(recCount + delta)"
            if let rs = database?.executeQuery(sql, withArgumentsIn: []) {
                while rs.next() {
                    recCount = min(Int(rs.int(forColumnIndex: 0)), recCount + delta)
                }
            }
        })
        
        return recCount
    }
    
    
    /*
    // 给TableView加一个Header
    */
    func makeHeader() -> Void {
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
    }
    
    /*
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
    
    // 保存网络数据到数据库
    func dataToDB(data: Any?) -> Bool {
        guard data != nil && JSONSerialization.isValidJSONObject(data!) else {
            return false
        }
        
        do {
            let dic = try JSONSerialization.jsonObject(with: data as! Data, options: [])
        }
        catch {
            return false
        }
        
        return true
    }
    
    // 请求最新的网络数据
    func downloadRecentData(count: Int, completion: ((Bool) ->Void)?) -> Void {
        let s = { (task: URLSessionDataTask, data: Any?) in
            if completion != nil {
                completion!(true)
            }
        }
        
        let f = {(task: URLSessionDataTask?, error: Error) in
            if completion != nil {
                completion!(false)
            }
        }
        
        let req = Request.RecentLiveData(count)
        if HTTPSession.session.post(request: req, progress: nil, success: s, failure: f) == nil {
            if completion != nil {
                completion!(false)
            }
        }
    }
    
    // 请求区间网络数据
    func downloadRecords(start: Int, count: Int, completion: ((Bool) ->Void)?) ->Void {
        let s = { (task: URLSessionDataTask, data: Any?) in
            
            if !self.dataToDB(data: data) {
                completion?(false)
            }
            else {
                completion?(true)
            }
        }
        
        let f = {(task: URLSessionDataTask?, error: Error) in
            if completion != nil {
                completion!(false)
            }
        }
        
        let req = Request.LiveData(start, count)
        if HTTPSession.session.post(request: req, progress: nil, success: s, failure: f) == nil {
            if completion != nil {
                completion!(false)
            }
        }
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        var frame = indicator.frame
        frame.origin.x = (self.tableView.bounds.size.width - frame.size.width) / 2.0
        frame.origin.y = -44 + (44 - frame.size.height) / 2.0
        indicator.frame = frame
        self.tableView.addSubview(indicator)
        indicator.startAnimating()
      
//        makeHeader()
        
//        DatabaseManager.removeDB()
//        DatabaseManager.DBM?.insertTestData()
        self.recCount = self.increaseRecCount(recCount: self.recCount)
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
        return self.recCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveTableVeiwCell", for: indexPath) as! LiveTableViewCell

        // Configure the cell...
        let dbq = DatabaseManager.DBM?.dbQueue
        dbq?.inDatabase({ (db: FMDatabase?) in
            repeat {
                let sql = "SELECT MatchCode, Plate, OverRate, WidthOver, HeightOver, LengthOver, ScaleDate FROM \(DatabaseManager.TableName.Live) ORDER BY MatchCode LIMIT 1 OFFSET \(indexPath.row)"
                guard let rs = db?.executeQuery(sql, withArgumentsIn: nil) else {
                    break
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                while rs.next() {
                    guard let dictionary = rs.resultDictionary() else {
                        break;
                    }
                    
                    let no = dictionary["MatchCode"]
                    
                    cell.statusLabel.attributedText = self.statusStringWithResultDictionary(dic: dictionary)
                    
                    if let tm = dictionary["ScaleDate"] as? Double {
                        let date = Date(timeIntervalSince1970:tm)
                        cell.timeLabel.text = formatter.string(from: date)
                    }
                    
                    if let plate = dictionary["Plate"] as? String {
                        cell.plateLabel?.text = "\(no!)" + plate
                    }

                }
            } while false
        })
        

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
        struct LocalStruct {
            static var isReloading = false
        }
        
        if LocalStruct.isReloading {
            return
        }
        LocalStruct.isReloading = true
        
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let insets = scrollView.contentInset
        let h = scrollView.contentSize.height
        let y = offset.y + bounds.size.height - insets.bottom
        
        if offset.y + insets.top < -44 {
            var insets = scrollView.contentInset
            insets.top += 44
            scrollView.contentInset = insets
            
            let completion = {(success: Bool, newRec: Int) ->Void in
                if success {
//                    let recCount = self.increaseRecCount(recCount: <#T##Int#>)
                }
            }
        }
        else if y > h +  44{
            let recCount = self.increaseRecCount(recCount: self.recCount)
            if recCount > self.recCount {
                self.recCount = recCount
                self.tableView.reloadData()
            }
        }
        
        LocalStruct.isReloading = false
    }
}
