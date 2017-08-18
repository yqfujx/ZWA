//
//  ConditionViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/2.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ConditionViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var tableViewController: ConditionTableViewController!
    
    @IBAction func cancelTapped(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "查询条件"
        self.button.setBackground(color: UIColor(red: 75.0 / 255.0, green: 186.0 / 255.0, blue: 81.0 / 255.0, alpha: 1.0), forState: .normal)
        self.button.setTitleColor(UIColor.white, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


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
        
        if let identifier = segue.identifier {

            switch identifier {
            case "embed":
                if let vc = segue.destination as? ConditionTableViewController {
                    self.tableViewController = vc
                }
            case "searchResult" where(self.tableViewController != nil):
                let vc = segue.destination as! SearchingResultViewController
                // 站点编号
                if self.tableViewController.sectionData[0].1 {
                    vc.stationID = self.tableViewController.station?.stationID
                }
                // 检测时间不早于
                if self.tableViewController.sectionData[1].1 {
                    vc.startTime = self.tableViewController.startTime
                }
                // 检测时间最迟至
                if self.tableViewController.sectionData[2].1 {
                    vc.endTime = self.tableViewController.endTime
                }
                // 超载状态
                if self.tableViewController.sectionData[3].1 {
                    vc.overloadStatus = self.tableViewController.overloadStatus
                    if self.tableViewController.overloadStatus! == 0 { // 超载
                        vc.overRateLower = self.tableViewController.overRateLower
                        vc.overRateUpper = self.tableViewController.overRateUpper
                    }
                }
                // 车牌号
                if self.tableViewController.sectionData[4].1 {
                    vc.vehicleID = self.tableViewController.province! + (self.tableViewController.vehicleID ?? "")
                }
                // 车道
                if self.tableViewController.sectionData[5].1 {
                    vc.lane = self.tableViewController.lane
                }
            default:
                break
            } // end switch
        }
    }

}
