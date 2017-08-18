//
//  StatisticsOptionTableViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/14.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit


class StatisticsOptionTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    var station: Station?
    var key: StatisticsKey?
    var timeSpan: StatisticsTimeSpan?
    var time: Date?
    
    
    private lazy var _stations: [Station]? = {
        var stations: [Station]?
        
        ServiceCenter.privateDb?.inTransaction({ (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
            let sql = "SELECT zoneID, stationID, stationName FROM \(DbTabName.station) ORDER BY zoneID, stationID"
            if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                stations = [Station]()
                
                while rs.next() {
                    let zoneID = rs.string(forColumnIndex: 0)
                    let stationID = rs.string(forColumnIndex: 1)
                    let stationName = rs.string(forColumnIndex: 2)
                    stations!.append(Station(zoneID: zoneID!, stationID: stationID!, stationName: stationName!))
                }
            }
        })
        
        return stations
    }()
    var stations: [Station]? {
        get {
            return self._stations
        }
    }
    
    private lazy var _stationNames: [String]? = {
        var names = self._stations?.map({ (station: Station) -> String in
            return station.stationName
        })
        
        return names
    }()
    

    // MARK: - 方法
    func initFields() -> Void {
        self.station = self._stations?[0]
        self.key = .overload
        self.timeSpan = .month
        self.time = Date()
    }
    
    // MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.initFields()
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
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "站点"
            cell.detailTextLabel?.text = self.station?.stationName
        case 1:
            cell.textLabel?.text = "统计类型"
            cell.detailTextLabel?.text = self.key?.description
        case 2:
            cell.textLabel?.text = "时间跨度"
            cell.detailTextLabel?.text = self.timeSpan?.description
        case 3:
            cell.textLabel?.text = "统计时点"
            cell.detailTextLabel?.text = self.time?.string(with: "yyyy-MM-dd")
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var vc: UIViewController?
        
        switch indexPath.row {
        case 0:
            let picker = self.storyboard?.instantiateViewController(withIdentifier: "CommonPickerViewController") as! CommonPickerViewController
            picker.items = self._stations
            picker.selectedIndex = self._stations?.index(where: { (station: Station) -> Bool in
                return station.stationID == self.station?.stationID
            }) ?? 0
            picker.context = "station"
            vc = picker
        case 1:
            let picker = self.storyboard?.instantiateViewController(withIdentifier: "CommonPickerViewController") as! CommonPickerViewController
            picker.items = [StatisticsKey.axle, StatisticsKey.lane, StatisticsKey.overload, StatisticsKey.rate]
            picker.selectedIndex = picker.items?.index(where: { (obj: DescriptiveObject) -> Bool in
                return (obj as! StatisticsKey) == self.key!
            }) ?? 0
            picker.context = "key"
            vc = picker
        case 2:
            let picker = self.storyboard?.instantiateViewController(withIdentifier: "CommonPickerViewController") as! CommonPickerViewController
            picker.items = [StatisticsTimeSpan.day, StatisticsTimeSpan.week, StatisticsTimeSpan.month, StatisticsTimeSpan.year]
            picker.selectedIndex = picker.items?.index(where: { (obj: DescriptiveObject) -> Bool in
                return (obj as! StatisticsTimeSpan) == self.timeSpan
            }) ?? 0
            picker.context = "timeSpan"
            vc = picker
        case 3:
            let picker = self.storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
            picker.date = self.time
            picker.context = "time"
            vc = picker
        default:
            break
        }
        
        // 手动弹出选择器
        vc?.modalTransitionStyle = .coverVertical
        vc?.modalPresentationStyle = .popover
        let pop = vc?.popoverPresentationController
        pop?.delegate = self
        let cell = tableView.cellForRow(at: indexPath)
        pop?.sourceView = cell
        pop?.sourceRect = cell!.bounds
        
        self.present(vc!, animated: true, completion: nil)
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
    }

    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if let vc = popoverPresentationController.presentedViewController as? CommonPickerViewController {
            switch (vc.context as! String) {
            case "station":
                self.station = vc.selectedItem as? Station
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            case "key":
                self.key = vc.selectedItem as? StatisticsKey
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            case "timeSpan":
                self.timeSpan = vc.selectedItem as? StatisticsTimeSpan
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            default:
                break
            }
        }
        else if let vc = popoverPresentationController.presentedViewController as? DatePickerViewController {
            switch (vc.context as! String) {
            case "time":
                self.time = vc.date
                self.tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
            default:
                break
            }
        }
    }
}
