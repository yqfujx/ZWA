//
//  CommonPickerViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/4.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class CommonPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var context: Any?
    var items: [String]?
    var selectedIndex: Int?
    var selectedItem: String? {
        get {
            if let index = self.selectedIndex {
                return self.items?[index]
            }
            else {
                return nil
            }
        }
    }
    
    
    @IBOutlet weak var pickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.selectedIndex {
            self.pickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.items?[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedIndex = row
    }
}
