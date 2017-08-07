//
//  LiveViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/24.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class LiveViewController: UITableViewController {
    var service: LiveDataService!
    var isBusy = false
    
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
    
    /**
    从记录集创建状态字符串
    */
    func statusString(with data: LiveData) -> NSAttributedString? {
        
        var string = "正常"
        var color = UIColor.black
        
        if data.overWeight > 0 {
            string = "超重"
            color = .red
        }
        else if data.overWidth > 0 {
            string = "超宽"
            color = .red
        }
        else if data.overLength > 0 {
            string = "超长"
            color = .red
        }
        else if data.overHeight > 0 {
            string = "超高"
            color = .red
        }
        
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: color])
    }
    
    func syncData() -> Void {
        if self.isBusy {
            return
        }
        self.isBusy = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let count = self.service.repository.count
        let indicator = MyActivityIndicatorView()
        indicator.show()
        
        if !self.service.sync(completion: { [unowned self] (success: Bool, error: SysError?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            // 考虑到在分页请求过程中，有可能出现“部分成功”的现象，
            // 因此对比请求前后结果集中记录数的变化，更为准确
            if self.service.repository.count != count {
                self.tableView.reloadData()
            }
            indicator.dismiss()
            self.isBusy = false
        }) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            indicator.dismiss()
            self.isBusy = false
        }
    }
    
    // MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "现场"
      
        decorateTableView()
        self.service = LiveDataService()
//        self.syncData()
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
        return self.service.repository.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveTableVeiwCell", for: indexPath) as! LiveTableViewCell

        // Configure the cell...
        if let data = self.service.repository[indexPath.row] {
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
        
        if !self.isBusy {
            
            let offset = scrollView.contentOffset
            let insets = scrollView.contentInset
            
            if offset.y + insets.top < -44 {
                self.syncData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LiveToDetail" {
            if let cell = sender as? UITableViewCell {
                if let index = self.tableView.indexPath(for: cell) {
                    let data = self.service.repository[index.row]
                    let controller = segue.destination as! DetailViewController
                    controller.data = data
                }
            }
        }
    }
}
