//
//  DatePickerViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/5.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    var context: Any?
    
    private var _date: Date?
    var date: Date? {
        get {
            return self.datePicker?.date
        }
        set {
            if let newValue = newValue {
                self._date = newValue
                self.datePicker?.date = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self._date != nil {
            self.datePicker.date = self._date!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
