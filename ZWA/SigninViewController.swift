//
//  SigninViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/10.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit
//import DTIActivityIndicator


class SigninViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - 属性
    var server: ServerStruct?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    var activityIndicator: MyActivityIndicatorView?
    
    // MARK: - 功能函数
    
    
    // MARK: - 控件事件

    /**
     文本框输入
     */
    @IBAction func textFieldChangedText(_ sender: Any) {
        if let l1 = self.accountTextField.text?.characters.count, let l2 = self.passwordTextField.text?.characters.count{
            self.signinButton.isEnabled =  (l1 > 0 &&  l2 > 0)
        }
    }
    
    /**
     点击登录按钮
     */
    @IBAction func signinButtonClicked(_ sender: UIButton) {
        self.activityIndicator = MyActivityIndicatorView()
        self.activityIndicator?.show()
        
         let completion = {(success: Bool) -> Void in
            if success {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                
                let segue = UIStoryboardSegue(identifier: nil, source: self, destination: vc!, performHandler: {
                    vc!.modalTransitionStyle = .crossDissolve
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let animation = CATransition()
                    animation.type = kCATransitionFade
                    delegate.window!.layer.add(animation, forKey: nil)
                    delegate.window!.rootViewController = vc!
                })
                
                segue.perform()
            }
            self.activityIndicator?.dismiss()
        } // end of closure

        if !SignService.service.signin(server: self.server!, userID: self.accountTextField.text!, password: self.passwordTextField.text!, completion: completion) {
            self.activityIndicator?.dismiss()
        }
    }
    
    // MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let image = UIImage(named: "login_btn")?.stretchableImage(withLeftCapWidth: 4, topCapHeight: 4) {
            self.signinButton.setBackgroundImage(image, for: .normal)
        }
        
        if let l1 = self.accountTextField.text?.characters.count, let l2 = self.passwordTextField.text?.characters.count{
            self.signinButton.isEnabled =  (l1 > 0 &&  l2 > 0)
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
