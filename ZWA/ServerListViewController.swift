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
    var service: SeverListService!
    /*
    // MARK: - 方法
    */
    
    // MARK: - 控件事件
    @IBAction func updateServerList(_ sender: Any) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let indicator = MyActivityIndicatorView()
        indicator.show()
        
        let completion = {(success: Bool, error: SysError?) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            indicator.dismiss()
            self.tableView.reloadData()
        }
        
        self.service.update(completion: completion)
    }

    // MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择服务器"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // 数据库里没有服务器列表，则从网络上下载
        self.service = SeverListService()
        if self.service.repository.count <= 0{
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let indicator = MyActivityIndicatorView()
            indicator.show()
            
            let completion = {[weak self] (success: Bool, error: SysError?) -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                indicator.dismiss()
                self?.tableView.reloadData()
            }
            
            self.service.update(completion: completion)
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
        return self.service.repository.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        if let aServer = self.service.repository[indexPath.row] {
            cell.textLabel?.text = aServer.name
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
            if let cell = sender as? UITableViewCell, let indexPath = self.tableView.indexPath(for: cell), let server = self.service.repository[indexPath.row] {
                let destVc = segue.destination as! SigninViewController
                destVc.server = server
           }
        }
    }

}
