//
//  SignService.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class SignService: NSObject {
    // 定义两个消息
    enum ServiceNotification: String {
        case signin, signout
    }
    
    static let service = SignService()
    
    var currentAccount: Account? {
        get {
            return Configuration.current.currentAccount
        }
    }
    
    var didSignin: Bool {
        get {
            if let account = Configuration.current.currentAccount {
                return account.didSignin
            }
            else {
                return false
            }
        }
    }
    
    private override init() {
        
    }
    
    func signin(completion: ((Bool) -> Void)?) -> Bool {
        let success = { (task: URLSessionDataTask, data: Data?) ->Void in
            var signed = false
            
            repeat {
                guard data != nil else {
                    break
                }
                
                do {
                    // 必须是形如{"key": value}
                    guard let jsonObj = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else {
                        break
                    }
                    // 必须是形如{"userInfo": [value]}
                    guard let array = (jsonObj["userinfo"] as? [Any]) else {
                        break
                    }
                    guard array.count > 0 else {
                        break
                    }
                    // 必须是形如{"userInfo": [{"key": value}, ...]}
                    guard let dictionary = array[0] as? [String: Any] else {
                        break
                    }
                    // 登录成功标志
                    guard let flag = dictionary["flag"] as? String  else {
                        break
                    }
                    guard  let success = Bool(flag.lowercased()) else {
                        break
                    }
                    if !success {
                        break
                    }
                    
                    if let locationCode = dictionary["managearea"] as? String
                        , let token = dictionary["token"] as? String
//                        , let userID = dictionary["userid"] as? String
//                        , let phone = dictionary["userphone"] as? String
                    {
                        
                        Configuration.current.currentAccount!.locationCode = locationCode
                        Configuration.current.currentAccount!.token = token
                        Configuration.current.currentAccount!.didSignin = true
                        Configuration.current.save()
                        signed = true
                   }
                    
                }
                catch let error {
                    print("\(error.localizedDescription)")
                }
                
            } while false
            
            if completion != nil {
                completion!(signed)
            }
            
            if signed {
                NotificationQueue.default.enqueue(Notification(name: Notification.Name(rawValue: ServiceNotification.signin.rawValue)), postingStyle: .asap)
            }
        }
        
        let failure = { (task: URLSessionDataTask?, error: Error) ->Void in
            if completion != nil {
                completion!(false)
            }
        }
        
        assert(Configuration.current.currentAccount != nil, "The current account must not be nil.")
        if let userID = Configuration.current.currentAccount?.userID
            , let password = Configuration.current.currentAccount?.password
            , let url = Configuration.current.currentAccount?.server.url {
            let request: Request = .Signin(userID, password, Configuration.current.deviceToken)
            return NetworkService.service.post(url: url, request:request, progress: nil, success: success, failure: failure) != nil
        }
        
        return false
    }
    
    func signin(server: ServerStruct, userID: String, password: String, completion: ((Bool) ->Void)?) -> Bool {
        let success = { (task: URLSessionDataTask, data: Data?) ->Void in
            var signed = false
            
            repeat {
                guard data != nil else {
                    break
                }
                
                do {
                    // 必须是形如{"key": value}
                    guard let jsonObj = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else {
                        break
                    }
                    // 必须是形如{"userInfo": [value]}
                    guard let array = (jsonObj["userinfo"] as? [Any]) else {
                        break
                    }
                    guard array.count > 0 else {
                        break
                    }
                    // 必须是形如{"userInfo": [{"key": value}, ...]}
                    guard let dictionary = array[0] as? [String: Any] else {
                        break
                    }
                    // 登录成功标志
                    guard let flag = dictionary["flag"] as? String  else {
                        break
                    }
                    guard  let result = Bool(flag.lowercased()) else {
                        break
                    }
                    if !result {
                        break
                    }
                    
                    if let userID = dictionary["userid"] as? String,
                        let phone = dictionary["userphone"] as? String,
                        let locationCode = dictionary["managearea"] as? String,
                        let token = dictionary["token"] as? String {
                        
                        if let account = Account(server: server, userID: userID, password: password, phone: phone, locationCode: locationCode, token: token) {
                            Configuration.current.currentAccount = account
                            
                            signed = true
                        }
                    }
                    
                }
                catch let error {
                    print("\(error.localizedDescription)")
                }
                
            } while false
        
            if completion != nil {
                completion!(signed)
            }
            
            if signed {
                NotificationQueue.default.enqueue(Notification(name: Notification.Name(rawValue: ServiceNotification.signin.rawValue)), postingStyle: .asap)
            }
        }
        
        let failure = { (task: URLSessionDataTask?, error: Error) ->Void in
            if completion != nil {
                completion!(false)
            }
        }
        
        let request: Request = .Signin(userID, password, Configuration.current.deviceToken)
        return NetworkService.service.post(url: server.url, request:request, progress: nil, success: success, failure: failure) != nil
    }
    
    func signout () ->Void {
        Configuration.current.currentAccount = nil
        NotificationQueue.default.enqueue(Notification(name: Notification.Name(rawValue: ServiceNotification.signout.rawValue)), postingStyle: .asap)
    }
}
