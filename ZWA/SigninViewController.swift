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
    
    // MARK: - 成员
    private var _service: AuthorizationService?

    // MARK: - 属性
    var server: ServerStruct?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
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
     回车按钮
     */
    @IBAction func onReturnKey(_ sender: Any) {
        if let sender = (sender as? UITextField) {
            if sender == self.accountTextField {
                self.passwordTextField.becomeFirstResponder()
            }
            else {
                if sender == self.passwordTextField && self.signinButton.isEnabled{
                    self.signinButtonClicked(nil)
                }
                sender.resignFirstResponder()
            }
        }
    }
    
    /**
     点击登录按钮
     */
    @IBAction func signinButtonClicked(_ sender: Any?) {
        if self.accountTextField.canResignFirstResponder {
            self.accountTextField.resignFirstResponder()
        }
        if self.passwordTextField.canResignFirstResponder {
            self.passwordTextField.resignFirstResponder()
        }
        
        self.activityIndicator = MyActivityIndicatorView()
        self.activityIndicator?.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let completion = {[weak self] (success: Bool, error: SysError?) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self?.activityIndicator?.dismiss()
            
            guard self != nil else {
                return
            }
            
            if success {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateInitialViewController()
                    
                    let segue = UIStoryboardSegue(identifier: nil, source: self!, destination: vc!, performHandler: {
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
            else {
                self?.messageLabel.text = error?.localizedDescription
            }
            
            self?._service = nil
            
        } // end of closure

        self._service = AuthorizationService(baseURL: URL(string: self.server!.url)!)
        _ = self._service?.authenticate(userID: self.accountTextField.text!, pwd: self.passwordTextField.text!, completion: completion)
    }
    
    // MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        if let image = UIImage(named: "login_btn")?.stretchableImage(withLeftCapWidth: 4, topCapHeight: 4) {
//            self.signinButton.setBackgroundImage(image, for: .normal)
//        }
        self.signinButton.setBackground(color: UIColor(red: 5.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0), forState: .normal)
        self.signinButton.setBackground(color: UIColor(white: 0.9, alpha: 1.0), forState: .disabled)
        self.signinButton.setTitleColor(UIColor.white, for: .normal)
        self.signinButton.setTitleColor(UIColor.gray, for: .disabled)
        
        if let l1 = self.accountTextField.text?.characters.count, let l2 = self.passwordTextField.text?.characters.count{
            self.signinButton.isEnabled =  (l1 > 0 &&  l2 > 0)
        }
        
        self.messageLabel.text = ""
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
