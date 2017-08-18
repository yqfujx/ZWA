//
//  StatisticsResultTableViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/14.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class StatisticsResultTableViewController: UITableViewController {

    private var _service: StatisticsService?
    
    var station: Station?
    var key: StatisticsKey?
    var timeSpan: StatisticsTimeSpan?
    var time: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self._service = StatisticsService()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self._service?.statisticWith(stationID: self.station!.stationID,
                                     key: self.key!.rawValue,
                                     timeSpan: self.timeSpan!.rawValue,
                                     time: self.time!,
                                     completion: { (success: Bool, error: SysError?) in
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                        if success {
                                            self.tableView.reloadData()
                                        }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let num = self._service?.data?.sections?.count {
            return num
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self._service?.data?.sections?[section]
        if let num = section?.rows?.count {
            return num
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        let section = self._service?.data?.sections?[indexPath.section]
        let row = section?.rows?[indexPath.row]
        cell.textLabel?.text = row!.description + ":"
        cell.detailTextLabel?.text = String(format: "%d", arguments: [row!.value])
        cell.indentationLevel = row!.indentLevel
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self._service?.data?.sections?[section]
        let title = String(format: "%@", arguments: [section!.description])
        return title
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
        if segue.identifier == "StatisticsToChart" {
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPath(for: cell)
            let section = self._service?.data?.sections?[indexPath!.section]
            let vc = segue.destination as! ChartViewController
            vc.sectionData = section
        }
    }

}
