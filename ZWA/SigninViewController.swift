//
//  SigninViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/10.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit


class SigninViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - 属性
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    
    @IBAction func testBaidu(_ sender: Any) {
        let p = {(p: Progress) -> Void in
        }
        
        let s = {(task: URLSessionDataTask, data: Any?) ->Void in
            if let content = data as? Data, let string = String(data: content, encoding: .utf8) {
                print(string)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateInitialViewController()
                
                let segue = UIStoryboardSegue(identifier: "Temp", source: self, destination: vc!, performHandler: {
                    vc!.modalTransitionStyle = .crossDissolve
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let animation = CATransition()
                    animation.type = kCATransitionFade
                    delegate.window!.layer.add(animation, forKey: nil)
                    delegate.window!.rootViewController = vc!
                })
                
                segue.perform()
            }
        }
        
        let f = {(task: URLSessionDataTask?, error: Error) ->Void in
            print(error.localizedDescription)
        }
        
        let session = AppConfiguration.configuration.defaultSession
        let request: Request = .Baidu
        session.post(request: request, progress: p, success: s, failure: f)
    }

    // MARK: - 功能函数
    func signin(withUserID userID: String, password: String, completion: @escaping (Bool) -> Void) -> Void {
        
        let request: Request = .Signin(["user_id": userID, "password": password])
        let session = AppConfiguration.configuration.defaultSession
        
        let success = {[unowned session] (task: URLSessionDataTask, data: Any?) ->Void in
            session.signin(account: Account(userID: userID, password: password)!)
            session.isOnline = true
            completion(true)
        }
        
        let failure = { (task: URLSessionDataTask?, error: Error) ->Void in
            completion(false)
        }
        
        if session.post(request:request, progress: nil, success: success, failure: failure) == nil {
            completion(false)
        }
    }
    
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
        sender.isEnabled = false
        self.navigationItem.hidesBackButton = true
        
        signin(withUserID: self.accountTextField.text!, password: self.passwordTextField.text!) {
            [weak self, weak sender](success: Bool) in
            
            if success {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateInitialViewController()
                let segue = UIStoryboardSegue(identifier: "signinToMain", source: self!, destination: vc!)
                segue.perform()
            }
            else {
                sender?.isEnabled = true
                self?.navigationItem.hidesBackButton = false
            }
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
