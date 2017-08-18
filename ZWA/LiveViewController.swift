//
//  LiveViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/24.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class LiveViewController: UITableViewController {
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
    
    var service: LiveDataService!
    var isBusy = false
    // 为了防止在更新数据库时影响现有记录列表的显示，特使用成员变量保存当前记录数，
    // 使得列表中显示的数据都是数据库已存在的数据，追加的新数据待完成数据库更新后刷新显示
    private var _count = 0
    private var _notificationObserver: Any?
    
    /*
    // 给TableView加点装饰
    */
    func decorateTableView() -> Void {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 44))
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        var frame = indicator.frame
        frame.origin.x = (view.bounds.size.width - frame.size.width) / 2.0
        frame.origin.y = (44 - frame.size.height) / 2.0
        indicator.frame = frame
        view.addSubview(indicator)
        indicator.startAnimating()
        
        self.tableView.tableFooterView = view
        var insets = self.tableView.contentInset
        insets.bottom -= view.frame.size.height
        self.tableView.contentInset = insets

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
        let string = String(format: "超载率 %.f%%", data.overWeightRate)
        let level = min(10, max(0, Int(data.overWeightRate) / 10))
        let color = self._statusColors[level]
        
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: color])
    }
    
    func syncData() -> Void {
        if self.isBusy {
            return
        }
        self.isBusy = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        let indicator = MyActivityIndicatorView()
//        indicator.show()
        
        if !self.service.sync(completion: { [weak self] (success: Bool, error: SysError?) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard self != nil else {
                return
            }
            // 考虑到在分页请求过程中，有可能出现“部分成功”的现象，
            // 因此对比请求前后结果集中记录数的变化，更为准确
            if self?.service.repository.count != self?._count {
                self!._count = self!.service.repository.count
                self?.tableView.reloadData()
            }
//            indicator.dismiss()
            self?.isBusy = false
        }) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            indicator.dismiss()
            self.isBusy = false
        }
    }
    
    func onPushNotification(notificatiion: Notification) -> Void {
        DispatchQueue.main.sync {
            self.syncData()
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
      
        self.service = LiveDataService()
        decorateTableView()
        self._count = self.service.repository.count
        self.tableView.contentOffset = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
        
        self._notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.init(pushNotification), object: nil, queue: OperationQueue.main) {_ in
            self.syncData()
        }
        
        self.syncData()
    }
    
    deinit {
        if self._notificationObserver != nil {
            NotificationCenter.default.removeObserver(self._notificationObserver!, name: NSNotification.Name.init(pushNotification), object: nil)
        }
        self.service.stop()
        self.service = nil
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
        return self._count
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
            
            let size = scrollView.contentSize
            let offset = scrollView.contentOffset
            let insets = scrollView.contentInset
            let total = offset.y + scrollView.frame.size.height + insets.bottom
            if total > size.height + 44{
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
