//
//  LaunchViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/21.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 启动画面 3 秒后进入功能界面
        // 手动切换场景
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            var storyboard: UIStoryboard?
            
            if  HTTPSession.session.didSignin {
                storyboard = UIStoryboard(name: "Main", bundle: nil)
            }
            else {
                storyboard = UIStoryboard(name: "Signin", bundle: nil)
            }
            
            if let vc = storyboard?.instantiateInitialViewController() {
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
