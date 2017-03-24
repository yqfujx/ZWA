//
//  ViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/8.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func browseServicesOnClick(_ sender: Any) {
        self.performSegue(withIdentifier: "BrowseWebServices", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BrowseWebServices" {
            segue.destination.title = "browse services"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

