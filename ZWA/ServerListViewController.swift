//
//  ServerListViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/22.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ServerListViewController: UITableViewController {

    @IBOutlet weak var barItem: UIBarButtonItem!
    
    private weak var _positiveAction: UIAlertAction?
    
    // MARK: - 属性
    private var service: SeverListService?
    /*
    // MARK: - 方法
    */
    
    // MARK: - 控件事件
    @IBAction func configRouter(_ sender: Any?) {
        let alert = UIAlertController(title: nil, message: "配置主机", preferredStyle: .alert)
        alert.addTextField { [unowned self] (textField: UITextField) in
            textField.placeholder = "输入主机地址"
            textField.text = Configuration.routerHost
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldTextDidChangeNotification(notification:)), name: .UITextFieldTextDidChange, object: textField)
        }
        
        let action = UIAlertAction(title: "确定", style: .default) { [weak self, alert] (_: UIAlertAction) in
            guard let _self = self else {
                return
            }
            
            let textField = alert.textFields![0]
            if textField.text != nil {
                if textField.text != Configuration.routerHost {
                    Configuration.routerHost = textField.text
                    
                    _self.service = SeverListService()
                    _self.updateServerList(nil)
                }
                
            }
            NotificationCenter.default.removeObserver(_self, name: .UITextFieldTextDidChange, object: textField)
        }
        action.isEnabled = !String.isEmptyOrNil(string: Configuration.routerHost)
        alert.addAction(action)
        self._positiveAction = action
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func updateServerList(_ sender: Any?) {
        self.barItem.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let indicator = MyActivityIndicatorView()
        indicator.show()
        
        let completion = { [weak self] (success: Bool, error: SysError?) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            guard let _self = self else {
                return
            }
            
            _self.barItem.isEnabled = true
            indicator.dismiss()
            _self.tableView.reloadData()
        }
        
        self.service?.update(completion: completion)
    }
    
    func handleTextFieldTextDidChangeNotification(notification: Notification) -> Void {
        let textField = notification.object as! UITextField
        self._positiveAction?.isEnabled = !String.isEmptyOrNil(string: textField.text)
    }

    // MARK: - 重载
    deinit {
        self.service = nil
        self._positiveAction = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择服务器"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if Configuration.routerHost == nil {
            self.configRouter(nil)
        }
        else {
            // 数据库里没有服务器列表，则从网络上下载
            self.service = SeverListService()
            if self.service!.repository.count <= 0 {
                self.updateServerList(nil)
            }
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
        if self.service != nil {
            return self.service!.repository.count
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        if let aServer = self.service!.repository[indexPath.row] {
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
            if let cell = sender as? UITableViewCell, let indexPath = self.tableView.indexPath(for: cell), let server = self.service!.repository[indexPath.row] {
                let destVc = segue.destination as! SigninViewController
                destVc.server = server
           }
        }
    }

}
