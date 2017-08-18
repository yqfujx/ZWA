//
//  Configuration.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class Configuration: NSObject {
    static var routerHost: String? {
        get {
            return UserDefaults.standard.string(forKey: "routerHost")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "routerHost")
        }
    }
    
    static var  routerUrl: String? {
        get {
            if self.routerHost != nil {
                return "http://" + self.routerHost! + "/Service1.asmx"
            }
            else {
                return nil
            }
        }
    } //= "http://192.134.2.166/webservice/Service1.asmx"

    static var userID: String? {
        get {
            return UserDefaults.standard.string(forKey: "userID")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userID")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var password: String? {
        get {
            return UserDefaults.standard.string(forKey: "password")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "password")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var authenticated: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "authenticated")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "authenticated")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var expiredTime: Date? {
        get {
            if let value = UserDefaults.standard.string(forKey: "expiredTime") {
                return Date(string: value, format: "yyyy-MM-dd HH:mm:ss")
            }
            else {
                return nil
            }
        }
        set {
            UserDefaults.standard.set(newValue?.string(with: "yyyy-MM-dd HH:mm:ss"), forKey: "expiredTime")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var deviceToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "deviceToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "deviceToken")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var sessionToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "sessionToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "sessionToken")
            UserDefaults.standard.synchronize()
        }
    }
}
