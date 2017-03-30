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
    var name = ""
    var address = ""
    
    init?(name: String?, address: String?) {
        guard name != nil && !name!.isEmpty && address != nil && !address!.isEmpty else {
            return nil
        }
        
        var lowcase = address!.lowercased()
        if lowcase.hasSuffix("?wsdl") {
            lowcase = String(lowcase.characters.dropLast(5))
        }
        self.name = name!
        self.address = lowcase
    }
}

/**
 账户信息
 */
struct Account {
    
    var userID: String!
    var password: String!
    var phone: String!
    var locationCode: String!
    var token: String!
    
    init?(userID: String?, password: String?, phone: String? = nil, locationCode: String? = nil, token: String? = nil) {
        
        guard userID != nil && !userID!.isEmpty
            && password != nil && !password!.isEmpty else {
            return nil
        }
        
        self.userID = userID
        self.password = password
        self.phone = phone
        self.locationCode = locationCode
        self.token = token
    }
}


/**
定义请求
 */
enum Request {
    case Baidu
    case ServerList
    case Signin(String, String)
    case LiveData(Int, Int)
    case RecentLiveData(Int)
}

/** 会话

*/
class HTTPSession: NSObject {
    
    // MARK: - 类属性
    // 单例
     static let session = HTTPSession()
    
    
    // MARK: - 实例属性
    var server: ServerStruct?
    var account: Account?
    
    private let manager = {() -> AFHTTPSessionManager in
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/html", "text/json", "text/xml", "application/json", "application/xml") as? Set<String>
        return manager
    }()
    
    var didSignin: Bool {
        get {
            return AppConfiguration.configuration.didSign
        }
    }
    
    var isOnline = false
    
    //MARK: - 方法
    private init(server: ServerStruct?, account: Account?) {
        self.server = server
        self.account = account
    }
    
    private override convenience init() {
        let conf = AppConfiguration.configuration
        let server = ServerStruct(name: conf.serverName, address:  conf.serverAddress)
        let account = Account(userID:  conf.userID, password:  conf.password)
        
        self.init(server: server, account: account)
    }
    
    
    /**
     根据请求返回服务接口
     */
    func interfaceWithRequest(request: Request) -> (String, Any?)? {
        var url: String?
        var params: Any?
        
        switch request {
        case .ServerList:
            url = AppConfiguration.configuration.SLURL
            
        case .Signin(let userID, let password) where (self.server != nil):
            url = self.server!.address + "/loginUserIos"
            params = ["logid": userID, "pwd": password]
            
        case .RecentLiveData(let count) where (self.server != nil):
            url = self.server!.address + "/recentdata"
            params = ["count": count]
            
        case .LiveData(let start, let count) where (self.server != nil):
            url = self.server!.address + "/livedata"
            params = ["start": start, "count": count]
            
        case .Baidu:
            url = "http://www.baidu.com/s"
            params = ["sl_lang":"en", "rsv_srlang": "en", "rsv_rq" :"en"]
            
        default:
            break;
        }
        
        if url != nil {
            return (url!, params)
        }
        else {
            return nil
        }
    }
    
    
    /** 签入
 */
    func signin(userID: String, password: String, phone: String, locationCode: String, token: String) -> Bool {
        if let account = Account(userID: userID, password: password, phone: phone, locationCode: locationCode, token: token) {
            self.account = account
            
            let conf = AppConfiguration.configuration
            conf.userID = userID
            conf.password = password
            conf.didSign = true
            conf.save()
            
           return true
        }
        return false
    }
    
    /** 签出
 */
    func signout() -> Void {
        self.account = nil
        
        let conf = AppConfiguration.configuration
        conf.userID = nil
        conf.password = nil
        conf.didSign = false
        conf.save()
    }
    
    // MARK: - 以下是封装服务接口
    /** 发请求
     Service 提供的数据为 XML 格式，形如：
     <?xml version="1.0" encoding="utf-8"?>
     <string xmlns="http://tempuri.org/">{"Table":[json obj]}</string>
     为解析出内嵌的 JSON，需要先解析 XML

     */
    func post(request: Request, progress inp: ((Progress) -> Void)?, success ins: ((URLSessionDataTask, Data?) -> Void)?, failure inf: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
        
        // 如果当前不在线，先要签入
        if !self.isOnline {
            
        }
        
        let p = {(progress: Progress) -> Void in
            if inp != nil {
                inp!(progress)
            }
        }
        
        let s = {(task: URLSessionDataTask, netData: Any?) -> Void in
            var jsonData: Data? = nil
            
            if let data = netData as? Data {
                // 解析 XML，提取出内嵌的JSON 格式的字符串
                let parser = XMLParser(data: data)
                let delegate = ResponseXMLParserDelegate(parser: parser, keyElementName: "string")
                parser.parse()
                print("\(delegate.elementValue)")
                jsonData = delegate.elementValue?.data(using: .utf8)
            }
            
            if ins != nil {
                ins!(task, jsonData)
            }
        }
        
        let f = {(task: URLSessionDataTask?, error: Error) -> Void in
            print("\(error.localizedDescription)")
            if inf != nil {
                inf!(task, error)
            }
        }
        
        if let (url, params) = self.interfaceWithRequest(request: request) {
            return self.manager.post(url, parameters: params, progress: p, success: s, failure: f)
        }
        
        return nil
    }
}
