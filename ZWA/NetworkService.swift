//
//  NetworkService.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class NetworkService: NSObject {
    var isOnline = false
    private var manager: AFHTTPSessionManager!
    
    static let service = NetworkService()
    var currentAccount: Account? {
        get {
            return Configuration.current.currentAccount
        }
    }
    
    private override init () {
        self.manager = AFHTTPSessionManager()
        self.manager.requestSerializer = AFHTTPRequestSerializer()
        self.manager.responseSerializer = AFHTTPResponseSerializer()
        self.manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/html", "text/json", "text/xml", "application/json", "application/xml") as? Set<String>
    }

    func post(url: String, request: Request, progress inp: ((Progress) -> Void)?, success ins: ((URLSessionDataTask, Data?) -> Void)?, failure inf: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
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
        
        let (component, params) = request.interface
        return self.manager.post(url + component, parameters: params, progress: p, success: s, failure: f)
    }
    
    func post(request: Request, progress inp: ((Progress) -> Void)?, success ins: ((URLSessionDataTask, Data?) -> Void)?, failure inf: ((URLSessionDataTask?, Error) -> Void)?) -> URLSessionDataTask? {
        if let url = self.currentAccount?.server.url {
            return self.post(url: url, request: request, progress: inp, success: ins, failure: inf)
        }
        return nil
    }
}
