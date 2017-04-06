//
//  Configuration.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class Configuration: NSObject {
//    let SLURL = "http://192.134.2.166:8080/Service1.asmx/AreaUrlJsStr"

    enum ConfigurationKey: String {
        case kDeviceToken, kServerName, kServiceUrl, kUserID, kPassword, kPhone, kLocationCode
    }

    static let current = Configuration()
    
    var currentAccount: Account? {
        didSet {
            self.save()
        }
    }
    
    var currentServer: ServerStruct? {
        get {
            return self.currentAccount?.server
        }
    }
    
    var deviceToken: String? {
        get {
            return self.item(forKey: .kDeviceToken) as? String
        }
        set {
            self.set(newValue, forKey: .kDeviceToken)
            UserDefaults.standard.synchronize()
        }
    }
    
    private override init() {
    }
    
    func item(forKey key: ConfigurationKey) -> Any? {
        return UserDefaults.standard.value(forKey: key.rawValue)
    }
    
    func set(_ item: Any?, forKey key: ConfigurationKey) -> Void {
        UserDefaults.standard.set(item, forKey: key.rawValue)
    }
    
    /** 加载配置项
     */
    func load() -> Void {
        let serverName = self.item(forKey: .kServerName) as? String
        let serviceUrl = self.item(forKey: .kServiceUrl) as? String
        
        if let server = ServerStruct(name: serverName, url: serviceUrl) {
            let userID = self.item(forKey: .kUserID) as? String
            let password = self.item(forKey: .kPassword) as? String
            let phone = self.item(forKey: .kPhone) as? String
            let locationCode = self.item(forKey: .kLocationCode) as? String
            self.currentAccount = Account(server: server, userID: userID, password: password, phone: phone, locationCode: locationCode, token: nil)
        }
        
    }
    
    /** 保存配置项
     */
    func save() -> Void {
        self.set(self.currentAccount?.server.name, forKey: .kServerName)
        self.set(self.currentAccount?.server.url, forKey: .kServiceUrl)
        self.set(self.currentAccount?.userID, forKey: .kUserID)
        self.set(self.currentAccount?.password, forKey: .kPassword)
        self.set(self.currentAccount?.phone, forKey: .kPhone)
        self.set(self.currentAccount?.locationCode, forKey: .kLocationCode)
        
        UserDefaults.standard.synchronize()
    }
}
