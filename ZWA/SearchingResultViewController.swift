//
//  SearchingResultViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/2.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class SearchingResultViewController: UITableViewController {
    private let _statusColors =  [UIColor.init(0x000000),
                                  UIColor.init(0x663333),
                                  UIColor.init(0x993333),
                                  UIColor.init(0xFF9999),
                                  UIColor.init(0xFF6699),
                                  UIColor.init(0xCC3333),
                                  UIColor.init(0xCC0033),
                                  UIColor.init(0xFF6666),
                                  UIColor.init(0xFF3333),
                                  UIColor.init(0xFF0033),
                                  UIColor.init(0xFF0000),
                                  UIColor.init(0xCC0000),
                                  ]
    
    private var _isBusy = false
    private var _service: SearchingService!
    
    var stationID: String?
    var vehicleID: String?
    var overloadStatus: Int?
    var overRateLower: Int?
    var overRateUpper: Int?
    var lane: String?
    var startTime: Date?
    var endTime: Date?
    
    @IBAction func cancelTapped(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }

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

    func statusString(with data: LiveData) -> NSAttributedString? {
        let string = String(format: "超载率 %.f%%", data.overWeightRate)
        let level = min(10, max(0, Int(data.overWeightRate) / 10))
        let color = self._statusColors[level]
        
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: color])
    }

    func search() -> Void {
        if self._isBusy {
            return
        }
        self._isBusy = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let count = self._service.repository.count
        let indicator = MyActivityIndicatorView()
        indicator.show()
        
        if !self._service.searchWith(stationID: self.stationID,
                                     vehicleID: self.vehicleID,
                                     overloadStatus: self.overloadStatus,
                                     overRateLower: self.overRateLower,
                                     overRateUpper: self.overRateUpper,
                                     lane: self.lane,
                                     earliestTime: self.startTime, lastTime: self.endTime, completion: { [weak self] (success: Bool, error: SysError?) in
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                        indicator.dismiss()
            
                                        // 考虑到在分页请求过程中，有可能出现“部分成功”的现象，
                                        // 因此对比请求前后结果集中记录数的变化，更为准确
                                        guard let _self = self else {
                                            return
                                        }
                                        if _self._service.repository.count != count {
                                            _self.tableView.reloadData()
                                        }
                                        _self._isBusy = false
        }) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            indicator.dismiss()
            self._isBusy = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "查询结果"
        
        decorateTableView()
        self._service = SearchingService()
        self.search()
        self.tableView.contentOffset = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
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
        return self._service.repository.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveTableVeiwCell", for: indexPath) as! LiveTableViewCell
        
        // Configure the cell...
        if let data = self._service.repository[indexPath.row] {
            cell.statusLabel.attributedText = self.statusString(with: data)
            cell.plateLabel.text = data.carNo
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            if let time = data.checkDatetime {
                cell.timeLabel.text = formatter.string(from: time)
            }
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ResultToDetail" {
            if let cell = sender as? UITableViewCell {
                if let index = self.tableView.indexPath(for: cell) {
                    let data = self._service.repository[index.row]
                    let controller = segue.destination as! DetailViewController
                    controller.data = data
                }
            }
        }
    }

}
