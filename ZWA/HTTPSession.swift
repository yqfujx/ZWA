//
//  HTTPSession.swift
//  ZWA
//
//  Created by mac on 2017/3/23.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit


/**
 定义服务器信息
 */
struct ServerStruct {
    var name: String!
    var address: String!
    
    init?(name: String?, address: String?) {
        guard name != nil && !name!.isEmpty && address != nil && !address!.isEmpty else {
            return nil
        }
        
        self.name = name
        self.address = address
    }
}


struct Account {
    
    var userID: String!
    var password: String!
    
    init?(userID: String?, password: String?) {
        
        guard userID != nil && !userID!.isEmpty && password != nil && !password!.isEmpty else {
            return nil
        }
        
        self.userID = userID
        self.password = password
    }
}


/**
定义请求
 */
enum Request {
    case Baidu
    case Signin([String: String])
    case RecentData(Int)
}


/**
 定义服务
 */
struct ServiceInterface {
    var host: String!
    var baseUrl: String {
        return self.host + "/service.asm"
    }
    
    init?(host: String) {
        if host.isEmpty {
            return nil
        }
        self.host = host
    }
    
    func interfaceWithRequest(request: Request) -> (String, Any?) {
        var url: String = ""
        var params: Any? = nil
        
        switch request {
        case .Signin(let param):
            url = self.baseUrl + "/login"
            params = param
        case .Baidu:
            url = "http://www.baidu.com/s"
            params = ["sl_lang":"en", "rsv_srlang": "en", "rsv_rq" :"en"]
        default:
            break;
        }
        
        return (url, params)
    }
    
}


class HTTPSession: NSObject {
    static let kServerName = "serverName"
    static let kServerAddress = "serverAddress"
    static let kUserID = "userID"
    static let kPassword = "password"
    static let kDidSignin = "didSignin"
    
    var server: ServerStruct? {
        didSet {
            if self.server != nil {
                
            }
        }
    }
    var account: Account?
    private let manager = {() -> AFHTTPSessionManager in
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/html", "text/xml", "application/json", "text/json", "text/javascript") as? Set<String>
        return manager
    }()
    
    var serverName: String? {
        get {
            return self.server?.name
        }
        set {
            self.server?.name = newValue
        }
    }
    
    var serverAddress: String? {
        get {
            return self.server?.address
        }
        set {
            self.server?.address = newValue
        }
    }
    
    var userID: String? {
        get {
            return self.account?.userID
        }
//        set {
//            self.account?.userID = newValue
//        }
    }
    
    var password: String? {
        get {
            return self.account?.password
        }
//        set {
//            self.account?.password = newValue
//        }
    }
    
    var didSignin: Bool {
        get {
            return self.server != nil && self.account != nil
        }
    }
    
    var isOnline = false
    
    private init(server: ServerStruct?, account: Account?) {
        self.server = server
        self.account = account
    }
    
    static func localSession() -> HTTPSession {
        let defaults = UserDefaults.standard
        
        let serverName = defaults.value(forKey: kServerName) as? String
        let serverAddress = defaults.value(forKey: kServerAddress) as? String
        let userID = defaults.value(forKey: kUserID) as? String
        let password = defaults.value(forKey: kPassword) as? String
        
        let server = ServerStruct(name: serverName, address: serverAddress)
        let account = Account(userID: userID, password: password)
        let session = HTTPSession(server: server, account: account)
        
        return session
    }

    // 签入
    func signin(account: Account) -> Void {
        assert(!account.userID.isEmpty && !account.password.isEmpty)
        
        self.account = account
        self.save()
    }
    
    // 签出
    func signout() -> Void {
        self.account = nil
        self.save()
    }
    
    /**
     保存登录信息
     */
    func save() {
        let defaults = UserDefaults.standard
        
        if self.server != nil {
            defaults.set(self.server!.name, forKey: HTTPSession.kServerName)
            defaults.set(self.server!.address, forKey: HTTPSession.kServerAddress)
        }
        else {
            defaults.set("", forKey: HTTPSession.kServerName)
            defaults.set("", forKey: HTTPSession.kServerAddress)
        }
        
        if self.account != nil {
            defaults.set(self.account!.userID, forKey: HTTPSession.kUserID)
            defaults.set(self.account!.password, forKey: HTTPSession.kPassword)
        }
        else {
            defaults.set("", forKey: HTTPSession.kUserID)
            defaults.set("", forKey: HTTPSession.kPassword)
        }
        
        defaults.synchronize()
    }

    // MARK: - 以下是封装服务接口
    func post(request: Request, progress: ((Progress) -> Void)?, success: ((URLSessionDataTask, Any?) -> Void)?, failure: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
        
        // 如果当前不在线，先要签入
        if !self.isOnline {
            
        }
        
        if let host = self.serverAddress, let interface = ServiceInterface(host: host) {
            let (url, params) = interface.interfaceWithRequest(request: request)
            return self.manager.post(url, parameters: params, progress: progress, success: success, failure: failure)
        }
        
        return nil
    }
    
}
