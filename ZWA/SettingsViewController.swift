//
//  SettingsViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/15.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    private weak var _positiveAction: UIAlertAction?
   
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var routerHostLabel: UILabel!
    @IBOutlet weak var spaceLabel: UILabel!
    
    func folderSize(folderPath: String) ->UInt64 {
        let filesArray = try? FileManager.default.subpathsOfDirectory(atPath: folderPath)
        var fileSize = UInt64(0);
    
        for fileName in filesArray! {
            let filePath = (folderPath as NSString).appendingPathComponent(fileName)
            let fileDictionary = try? FileManager.default.attributesOfItem(atPath: filePath)
            fileSize += fileDictionary![FileAttributeKey.size] as! UInt64
        }
    
        return fileSize;
    }
    
    func appSize() -> UInt64 {
        let bundlePath = Bundle.main.bundlePath
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        
        let bundleSize = self.folderSize(folderPath: bundlePath)
        let docsSize = self.folderSize(folderPath: documentsDirectory)
        let cachesSize = self.folderSize(folderPath: cachesDirectory)
        
        let totalSize = Double(bundleSize + docsSize + cachesSize) / 1024.0 / 1024.0
        return UInt64(totalSize)
    }
    
    
    func configRouter() {
        let alert = UIAlertController(title: nil, message: "配置主机", preferredStyle: .alert)
        alert.addTextField { [weak self] (textField: UITextField) in
            guard let _self = self else {
                return
            }
            
            textField.placeholder = "输入主机地址"
            textField.text = Configuration.routerHost
            NotificationCenter.default.addObserver(_self, selector: #selector(_self.handleTextFieldTextDidChangeNotification(notification:)), name: .UITextFieldTextDidChange, object: textField)
        }
        
        let action = UIAlertAction(title: "确定", style: .default) { [weak self] (action: UIAlertAction) in
            guard let _self = self else {
                return
            }
            
            let textField = alert.textFields![0]
            if textField.text != nil {
                if textField.text != Configuration.routerHost {
                    Configuration.routerHost = textField.text
                    _self.routerHostLabel.text = textField.text
                }
             }
            NotificationCenter.default.removeObserver(_self, name: .UITextFieldTextDidChange, object: textField)
        }
        action.isEnabled = !String.isEmptyOrNil(string: Configuration.routerHost)
        alert.addAction(action)
        self._positiveAction = action
        
        let negative = UIAlertAction(title: "取消", style: .cancel) { (action: UIAlertAction) in
        }
        alert.addAction(negative)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleTextFieldTextDidChangeNotification(notification: Notification) -> Void {
        let textField = notification.object as! UITextField
        self._positiveAction?.isEnabled = !String.isEmptyOrNil(string: textField.text)
    }
    
    func exit() -> Void {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logout = UIAlertAction(title: "退出当前帐号", style: .default) { (action: UIAlertAction) in
            NotificationCenter.default.post(name: NSNotification.Name.init(logoutNotification), object: nil)
        }
        alert.addAction(logout)

        let quite = UIAlertAction(title: "关闭程序", style: .default) { (action: UIAlertAction) in
            Darwin.exit(Int32(0))
        }
        alert.addAction(quite)
        
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.userIDLabel.text = ServiceCenter.currentAccount?.userID ?? ""
        self.routerHostLabel.text = Configuration.routerHost ?? ""
        self.spaceLabel.text = String(format: "%d MB", self.appSize())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
 */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                self.configRouter()
            case 1:
                self.exit()
            default:
                break
            }
        }
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
