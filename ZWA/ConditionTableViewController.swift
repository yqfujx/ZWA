//
//  ConditionTableViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/4.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ConditionTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var vehicleIDButton: UIButton!
    @IBOutlet weak var vehicleIDTextField: UITextField!
    @IBOutlet weak var overRateLowerLabell: UILabel!
    @IBOutlet weak var overRateUpperLabel: UILabel!
    @IBOutlet weak var overRateLowerTextField: UITextField!
    @IBOutlet weak var overRateUpperTextField: UITextField!
    @IBOutlet weak var overloadStatusSegment: UISegmentedControl!
    @IBOutlet weak var laneTextField: UITextField!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    private var _sectionData: [(String, Bool, Int)] = [
        ("站点", true, 1),
        ("检测时间", true, 1),
        ("检测时间", true, 1),
        ("超载状态", true, 3),
        ("车牌", false, 1),
        ("车道", false, 1),
    ]
    var sectionData: [(String, Bool, Int)] {
        get {
            return self._sectionData
        }
    }
    
    private let _provinces: [String] = [
    "京", "沪", "津", "渝", "黑", "吉", "辽", "蒙", "冀", "新", "甘", "青", "陕", "宁", "豫", "鲁", "晋", "皖", "鄂", "湘", "赣", "苏", "川", "黔", "滇", "桂", "藏", "浙", "粤", "闽", "琼"
    ]
    
    
    private var _station: Station?
    var station: Station? {
        get {
            return self._station
        }
    }
    private var _province: String?
    var province: String? {
        get {
            return self._province
        }
    }
    private var _vehicleID: String?
    var vehicleID: String? {
        get {
            return self._vehicleID
        }
    }
    private var _overloadStatus: Int?
    var overloadStatus: Int? {
        get {
            return self._overloadStatus
        }
    }
    private var _overRateLower: Int?
    var overRateLower: Int? {
        get {
            return self._overRateLower
        }
    }
    private var _overRateUpper: Int?
    var overRateUpper: Int? {
        get {
            return self._overRateUpper
        }
    }
    private var _lane: String?
    var lane: String? {
        get {
            return self._lane
        }
    }
    private var _startTime: Date?
    var startTime: Date? {
        get {
            return self._startTime
        }
    }
    private var _endTime: Date?
    var endTime: Date? {
        get {
            return self._endTime
        }
    }
    
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

    // MARK: - 事件
    @IBAction func overloadStatusChanged(_ sender: Any) {
        if let segment = sender as? UISegmentedControl {
            self._overloadStatus = segment.selectedSegmentIndex
            if self._overloadStatus == 0 {
                self.overRateLowerLabell.isEnabled = true
                self.overRateUpperLabel.isEnabled = true
                self.overRateLowerTextField.isEnabled = true
                self.overRateUpperTextField.isEnabled = true
            }
            else {
                self.overRateLowerLabell.isEnabled = false
                self.overRateUpperLabel.isEnabled = false
                self.overRateLowerTextField.isEnabled = false
                self.overRateUpperTextField.isEnabled = false
            }
        }
    }
    
    @IBAction func textFiledTextChanged(_ sender: Any) {
        let textField = sender as! UITextField
        
        if textField === self.vehicleIDTextField {
            textField.text = textField.text?.uppercased()
            
            // 车牌号只有5个字符
            let needless = textField.text!.characters.count - 5
            if needless > 0 {
                textField.text = textField.text?.dropLast(needless)
            }
        }
        else if textField === self.overRateLowerTextField {
            let lowerText = !String.isEmptyOrNil(string: textField.text) ? textField.text! : "0"
            var lower = Int(lowerText)!
            lower = max(0, lower)
            self._overRateLower = lower
            textField.text = String(format: "%d", lower)
            
            let upperText = !String.isEmptyOrNil(string: self.overRateUpperTextField.text) ? self.overRateUpperTextField.text! : "0"
            var upper = Int(upperText)!
            upper = max(lower, upper)
            self._overRateUpper = upper
            self.overRateUpperTextField.text = String(format: "%d", upper)
        }
        else if textField === self.overRateUpperTextField {
            let upperText = !String.isEmptyOrNil(string: textField.text) ? textField.text! : "0"
            var upper = Int(upperText)!
            upper = max(0, upper)
            self._overRateUpper = upper
            textField.text = String(format: "%d", upper)
            
            let lowerText = !String.isEmptyOrNil(string: self.overRateLowerTextField.text) ? self.overRateLowerTextField.text! : "0"
            var lower = Int(lowerText)!
            lower = min(upper, max(0, lower))
            self._overRateLower = lower
            self.overRateLowerTextField.text = String(format: "%d", lower)
        }
        else if textField === self.vehicleIDTextField {
            self._vehicleID = textField.text
        }
        else if textField === self.laneTextField {
            self._lane = textField.text
        }
    }
    
    @IBAction func returnKeyTapped(_ sender: Any) {
        let textField = sender as! UITextField
        textField.resignFirstResponder()
        
        let allTextFields = [self.overRateLowerTextField!, self.overRateUpperTextField!, self.vehicleIDTextField!, self.laneTextField!]
        let index = allTextFields.index {
            return $0 == textField
        }
        if let index = index {
            for i in index + 1 ..< allTextFields.count {
                let textField = allTextFields[i]
                if textField.canBecomeFirstResponder {
                    textField.becomeFirstResponder()
                    break
                }
            }
        }
    }
    
    // MARK: - 方法
    func initFields() -> Void {
        self._station = self._stations?[0]
        self._province = "赣"
        self._overloadStatus = 0
        self._overRateLower = 10
        self._overRateUpper = 100
        let now = Date()
        self._endTime = Date(year: now.year, month: now.month, day: now.day)
        self._startTime = self._endTime?.addingTimeInterval(-24 * 60 * 60)
        
        self.stationNameLabel.text = self._station?.stationName
        self.vehicleIDButton.setTitle(self._province, for: .normal)
        self.overRateLowerTextField.text = String(format: "%d", arguments: [self._overRateLower!])
        self.overRateUpperTextField.text = String(format: "%d", arguments: [self._overRateUpper!])
        
        self.startTimeLabel.text = self._startTime?.string(with: "yyyy-MM-dd")
        self.endTimeLabel.text = self._endTime?.string(with: "yyyy-MM-dd")
    }
    
    // MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0)
        self.vehicleIDButton.setBackground(color: UIColor(red: 0.0, green: 122.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0), forState: .normal)
        self.initFields()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self._sectionData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, isEnabled, rows) = self._sectionData[section]
        
        return (isEnabled ? rows : 0)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TableViewHeaderView(frame: CGRect(x: 0, y: 0, width: 375, height: 33))
        
        view.textLabel.text = self._sectionData[section].0
        view.textLabel.sizeToFit()
        view.switcher.isOn = self._sectionData[section].1
        view.switcher.handle(events: .valueChanged) {
            self._sectionData[section].1 = !self._sectionData[section].1
            tableView.reloadSections(IndexSet.init(integer: section), with: .automatic)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
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
        self.presentedViewController?.dismiss(animated: false, completion: nil)
        
        if let identifier = segue.identifier {
            if identifier.hasPrefix("popover") {
                segue.destination.popoverPresentationController?.delegate = self
                segue.destination.popoverPresentationController?.sourceView = (sender as! UIView)
                segue.destination.popoverPresentationController?.sourceRect = (sender as! UIView).bounds
            }
            
            switch identifier {
            case "popoverStationName":
                let vc = segue.destination as! CommonPickerViewController
                vc.context = identifier
                vc.items = self._stations
                vc.selectedIndex = vc.items?.index(where: {
                    return ($0 as! Station).stationID == self._station?.stationID
                }) ?? 0
                
            case "popoverProvince":
                let vc = segue.destination as! CommonPickerViewController
                vc.context = identifier
                vc.items = self._provinces
                vc.selectedIndex = vc.items?.index(where: {
                    return $0.description == self._province
                }) ?? 0
            case "popoverStartTime":
                let vc = segue.destination as! DatePickerViewController
                vc.context = identifier
                vc.date = self._startTime
                
            case "popoverEndTime":
                let vc = segue.destination as! DatePickerViewController
                vc.context = identifier
                vc.date = self._endTime
                
            default:
                break
            }
        }
    }
 
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        if let vc = popoverPresentationController.presentedViewController as? CommonPickerViewController {
            
            switch (vc.context as! String) {
            case "popoverStationName":
                self._station = self._stations?[vc.selectedIndex!]
                self.stationNameLabel.text = self._station?.stationName
                
            case "popoverProvince":
                self._province = (vc.selectedItem) as? String
                self.vehicleIDButton.setTitle(self._province, for: .normal)
            default:
                break
            }
        }
        else if let vc = popoverPresentationController.presentedViewController as? DatePickerViewController {
            switch vc.context as! String {
            case "popoverStartTime":
                self._startTime = vc.date
                self.startTimeLabel.text = self._startTime?.string(with: "yyyy-MM-dd")
            case "popoverEndTime":
                self._endTime = vc.date
                self.endTimeLabel.text = self._endTime?.string(with: "yyyy-MM-dd")
            default:
                break
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.vehicleIDTextField {
            if !string.isEmpty {
                let charset = CharacterSet.init(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\n")
                guard (string.rangeOfCharacter(from: charset) != nil) else {
                    return false
                }
            }
        }
        else if textField === self.overRateLowerTextField || textField === self.overRateUpperTextField {
            if !string.isEmpty {
                let charset = CharacterSet.init(charactersIn: "0123456789\n")
                guard (string.rangeOfCharacter(from: charset) != nil) else {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let allTextFields = [self.vehicleIDTextField!, self.overRateLowerTextField!, self.overRateUpperTextField!, self.laneTextField!]
        
        for textField in allTextFields {
            if textField.canResignFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }
}
