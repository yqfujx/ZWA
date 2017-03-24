//
//  ServerListViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/22.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ServerListViewController: UITableViewController {

    func updateServerList() {
        let list = [ServerStruct(name: "dev_sever", address: "http://192.134.2.166:8080")!]
        
        AppConfiguration.configuration.servers = list
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择服务器"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // 已保存了登录服务器信息，可以跳过选择服务器这一步
        if AppConfiguration.configuration.defaultSession.server != nil {
            self.performSegue(withIdentifier: "ServerListToSignin", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AppConfiguration.configuration.servers.count <= 0 {
            OperationQueue.main.addOperation {[weak self] in
                self?.updateServerList()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return AppConfiguration.configuration.servers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        let aServer = AppConfiguration.configuration.servers[indexPath.row]
        cell.textLabel?.text = aServer.name
        cell.detailTextLabel?.text = aServer.address

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
            if let cell = sender as? UITableViewCell {
                let indexPath = self.tableView.indexPath(for: cell)
                if let index = indexPath?.row {
                    let server = AppConfiguration.configuration.servers[index]
                    AppConfiguration.configuration.defaultSession.server = server
                }
            }
        }
    }

}
