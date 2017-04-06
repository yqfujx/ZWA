//
//  LaunchViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/21.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    func switchToSceen(sceen: String) -> Void {
        // 切换场景
        let deadlineTime = DispatchTime.now()
        
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            let storyboard = UIStoryboard(name: sceen, bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                let segue = UIStoryboardSegue(identifier: nil, source: self, destination: vc, performHandler: {
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    let window = delegate.window!
                    let anim = CATransition()
                    anim.type = kCATransitionFade
                    window.layer.add(anim, forKey: nil)
                    window.rootViewController = vc
                })
                segue.perform()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if  Configuration.current.currentAccount != nil {
            if !Configuration.current.currentAccount!.didSignin {
                let result = SignService.service.signin(completion: { (success: Bool) in
                    if success {
                        self.switchToSceen(sceen: "Main")
                    }
                    else {
                        self.switchToSceen(sceen: "Signin")
                    }
                })
                
                if !result {
                    self.switchToSceen(sceen: "Signin")
                }
            }
        }
        else {
            self.switchToSceen(sceen: "Signin")
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMain" {
            print("OK")
        }
    }
}
