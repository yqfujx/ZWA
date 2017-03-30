//
//  AppConfiguration.swift
//  ZWA
//
//  Created by mac on 2017/3/21.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit


class AppConfiguration: NSObject {

    let SLURL = "http://192.134.2.166:8080/Service1.asmx/AreaUrlJsStr"
    static let kServerName = "serverName"
    static let kServerAddress = "serverAddress"
    static let kUserID = "userID"
    static let kPassword = "password"
    static let kDidSignin = "didSignin"
    
    var serverName: String?
    var serverAddress: String?
    var userID: String?
    var password: String?
    var phone: String?
    var locationCode: String?
    var didSign: Bool = false
    
    private override init () {
        let defaults = UserDefaults.standard
        
        serverName = defaults.value(forKey: AppConfiguration.kServerName) as? String
        serverAddress = defaults.value(forKey: AppConfiguration.kServerAddress) as? String
        userID = defaults.value(forKey: AppConfiguration.kUserID) as? String
        password = defaults.value(forKey: AppConfiguration.kPassword) as? String
        if let boolValue = defaults.value(forKey: AppConfiguration.kDidSignin) as? Bool {
            didSign = boolValue
        }
        
        super.init()
    }
    
    func save() -> Void {
        let defaults = UserDefaults.standard
        
        defaults.set(self.serverName ?? "", forKey: AppConfiguration.kServerName)
        defaults.set(self.serverAddress ?? "", forKey: AppConfiguration.kServerAddress)
        defaults.set(self.userID ?? "", forKey: AppConfiguration.kUserID)
        defaults.set(self.password ?? "", forKey: AppConfiguration.kPassword)
        defaults.set(self.didSign, forKey: AppConfiguration.kDidSignin)
        
        defaults.synchronize()
    }
    
    /**
     单例
     */
    static let configuration = AppConfiguration()

}
