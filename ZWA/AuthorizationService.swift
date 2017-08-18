//
//  AuthorizationService.swift
//  ConchIOS
//
//  Created by osx on 2017/7/12.
//  Copyright © 2017年 osx. All rights reserved.
//

import UIKit

class AuthorizationService: NSObject {
    // 变量
    
    // MARK: - 属性
    //
    let client = "iOS"
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    var baseURL: URL!
    
    var userID: String? {
        get {
            return Configuration.userID
        }
        set {
            Configuration.userID = newValue
        }
    }
    
    var password: String? {
        get {
            return Configuration.password
        }
        set  {
            Configuration.password = newValue
        }
    }
    var deviceToken: String? {
        get {
            return Configuration.deviceToken
        }
        set {
            Configuration.deviceToken = newValue
        }
    }
    
    var sessionToken: String? {
        get {
            return Configuration.sessionToken
        }
        set {
            Configuration.sessionToken = newValue
        }
    }
    
    var expiredTime: Date? {
        get {
            return Configuration.expiredTime
        }
        set {
            Configuration.expiredTime = newValue
        }
    }
    
    var authenticated: Bool {
        get {
            return Configuration.authenticated
        }
        set {
            Configuration.authenticated = newValue
        }
    }
    
    private var _network: NetworkService!
    
    // MARK: - 方法
    //
    init(baseURL: URL) {
        self.baseURL = baseURL
        self._network = NetworkService(baseURL: self.baseURL)
    }
    
    func authenticate(userID: String, pwd: String, completion: ((Bool, SysError?) -> Void)?) -> Void {
        
        let request = Request.login(userID, pwd, self.deviceToken)
        _ = self._network.send(request: request) { [unowned self] (success: Bool, dictionary: [String: Any]?, error: SysError?) in
            var success = success
            var error = error
            
            if success {
                if var string = dictionary!["result"] as? String {
                    string = string.lowercased()
                    if let result = Bool.init(string) {
                        // 登录成功
                        if result {
                            var account = Account(serverUrl: self.baseURL.absoluteString, userID: userID, password: pwd)
                            let token = dictionary!["token"] as? String
                            account.token = token
                            
                            var stations: [Station] = []
                            let array = dictionary!["Table"] as? [[String: Any]]
                            for dic in array! {
                                if let zoneID = dic["areaid"] as? String, let stationID = dic["siteid"] as? String, let stationName = dic["sitename"] as? String {
                                    stations.append(Station(zoneID: zoneID, stationID: stationID, stationName: stationName))
                                }
                            }
                            account.stations = stations
                            
                            // 创建或更新用户数据库
                            self.register(account: account)
                            // 设为当前账户
                            self.userID = account.userID
                            self.authenticated = true
                            ServiceCenter.currentAccount = account
                        }
                        else {  // 登录不成功
                            success = false
                            error = SysError(domain: ErrorDomain.authorizationService, code: ErrorCode.loginFailed)
                        }
                    }
                }
                else {
                    success = false
                    error = SysError(domain: ErrorDomain.authorizationService, code: ErrorCode.badData)
                }
            } // if success
            
            completion?(success, error)
        } // closure
    }
    
    func authenticate(completion: ((Bool, SysError?) -> Void)?) -> Void {
        self.authenticate(userID: self.userID!, pwd: self.password!, completion: completion)
    }
    
    /**
     创建或更新用户数据库
     */
    func register(account: Account) {
        // 保存账户信息
        let db = DatabaseManager.privateDb(with: account.userID)
        
        db.inTransaction({ (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
            var tabName = DbTabName.userInfo.rawValue
            
            var sql = "INSERT OR REPLACE INTO \(tabName) (userID, password, token, serverUrl) VALUES (?, ?, ?, ?)"
            let args: [CVarArg] = [account.userID, account.password, account.token!, account.serverUrl]
            _ = withVaList(args) {
                db?.executeUpdate(sql, withVAList: $0)
            }
            
            if let stations = account.stations, stations.count > 0 {
                tabName = DbTabName.station.rawValue
                for sta in stations {
                    let zoneID = sta.zoneID
                    let stationID = sta.stationID
                    let stationName = sta.stationName
                    sql = "INSERT OR REPLACE INTO \(tabName) (zoneID, stationID, stationName) VALUES (?, ?, ?)"
                    db?.executeUpdate(sql, withArgumentsIn: [zoneID, stationID, stationName])
                }
            }
        })
    }

}
