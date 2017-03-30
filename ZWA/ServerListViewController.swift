//
//  ServerListViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/22.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ServerListViewController: UITableViewController {

    // MARK: - 属性
    private var serverCount: Int {
        var count = 0
        
        DatabaseManager.DBM?.dbQueue.inDatabase({ (db: FMDatabase?) in
            let sql = "SELECT COUNT(*) FROM \(DatabaseManager.TableName.ServerList) ORDER BY rid"
            if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                while rs.next() {
                    count = Int(rs.int(forColumnIndex: 0))
                }
            }
        })
        
        return count
    }
    
    /*
    // MARK: - 方法
    */
    func serverAtIndexPath(indexPath: IndexPath) -> ServerStruct? {
        var server: ServerStruct?
        
        DatabaseManager.DBM?.dbQueue.inDatabase({ (db: FMDatabase?) in
            let sql = "SELECT an, url FROM \(DatabaseManager.TableName.ServerList) ORDER BY rid LIMIT 1 OFFSET \(indexPath.row)"
            if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                while rs.next() {
                    server = ServerStruct(name: rs.string(forColumn: "an"), address: rs.string(forColumn: "url"))
                }
            }
        })
        
        return server
    }
    
    /** 下载服务器列表
     
     */
    func downloadServerList(completion: ((Bool) -> Void)?) -> Void {
        let s = { (task: URLSessionDataTask, data: Data?) -> Void in
            self.saveData(data: data ) ? completion?(true) : completion?(false)
        }
        
        let f = {(task: URLSessionDataTask?, error: Error) -> Void in
            if completion != nil {
                completion!(false)
            }
        }
        
        let request = Request.ServerList
        if HTTPSession.session.post(request: request, progress: nil, success: s, failure: f) == nil && completion != nil {
            completion!(false)
        }
    }
    
    /** 服务器列表的网络数据存入数据
     */
    func saveData(data: Data?) -> Bool {
        guard data != nil else {
            return false
        }
        
        do {
            //　解析 JSON 数据
            let jsonObj = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            if let serverArray = jsonObj?["Table"] as? [[String: Any]] {
                DatabaseManager.DBM?.dbQueue.inTransaction({ (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
                    var sql: String
                    for aServer in serverArray {
                        sql = "INSERT OR REPLACE INTO \(DatabaseManager.TableName.ServerList) (rid, an, upi, sc, url) VALUES(:rid, :an, :upi, :sc, :url)"
                        db?.executeUpdate(sql, withParameterDictionary: aServer)
                    }
               })
                
            }
        }
        catch let error {
            print("\(error.localizedDescription)")
            return false
        }

        
        return true
    }
    
    // MARK: - 控件事件
    @IBAction func updateServerList(_ sender: Any) {
        let indicator = MyActivityIndicatorView()
        indicator.show()
        
        let completion = {(success: Bool) -> Void in
            indicator.dismiss()
            self.tableView.reloadData()
        }
        
        self.downloadServerList(completion: completion)
    }

    // MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择服务器"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // 已保存了登录服务器信息，可以跳过选择服务器这一步
        if HTTPSession.session.server != nil {
            self.performSegue(withIdentifier: "ServerListToSignin", sender: nil)
        }
        else if self.serverCount <= 0{  // 没保存且数据库里没有服务器列表，则从网络上下载
            let indicator = MyActivityIndicatorView()
            indicator.show()
            
            let completion = {(success: Bool) -> Void in
                indicator.dismiss()
                self.tableView.reloadData()
            }
            
            self.downloadServerList(completion: completion)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.serverCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        if let aServer = self.serverAtIndexPath(indexPath: indexPath) {
            cell.textLabel?.text = aServer.name
            cell.detailTextLabel?.text = aServer.address
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
        if segue.identifier == "ServerListToSignin" {
            if let cell = sender as? UITableViewCell, let indexPath = self.tableView.indexPath(for: cell), let server = self.serverAtIndexPath(indexPath: indexPath) {
                HTTPSession.session.server = server
           }
        }
    }

}
