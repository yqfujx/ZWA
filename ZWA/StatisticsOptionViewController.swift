//
//  StatisticsOptionViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/11.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class StatisticsOptionViewController: UIViewController {

    private weak var _tableViewController: StatisticsOptionTableViewController?
    @IBOutlet weak var commitButton: UIButton!
    
    @IBAction func commitButtonTapped(_ sender: Any?) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "统计条件"
        self.commitButton.setBackground(color: UIColor(red: 75.0 / 255.0, green: 186.0 / 255.0, blue: 81.0 / 255.0, alpha: 1.0), forState: .normal)
        self.commitButton.setTitleColor(UIColor.white, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            switch identifier {
            case "embed":
                self._tableViewController = segue.destination as? StatisticsOptionTableViewController
            case "commit":
                let vc = segue.destination as! StatisticsResultTableViewController
                vc.station = self._tableViewController?.station
                vc.key = self._tableViewController?.key
                vc.timeSpan = self._tableViewController?.timeSpan
                vc.time = self._tableViewController?.time
            default:
                break
            }
        }
    }

}
