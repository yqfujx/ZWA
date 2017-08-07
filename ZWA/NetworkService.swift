//
//  NetworkService.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class NetworkService: AFHTTPSessionManager {
    // MARK: - 成员
    private var sendDispatchQueue: DispatchQueue!
    
    // MARK: - 属性
    
    // MARK: - 方法
    
    override init(baseURL url: URL?, sessionConfiguration configuration: URLSessionConfiguration? = URLSessionConfiguration.default) {
        super.init(baseURL: url, sessionConfiguration: configuration)
        self.requestSerializer = AFHTTPRequestSerializer()
        self.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.responseSerializer = AFXMLParserResponseSerializer()   //AFJSONResponseSerializer()
        
        self.sendDispatchQueue = DispatchQueue(label: "NetworkService send dispatch queue", qos: .userInitiated, attributes: .concurrent)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     发送HTTP请求
     */
    func send(request: Request, completionQueue: OperationQueue?, completion: ((Bool, [String: Any]?, SysError?) ->Void)?) -> Bool {
        
        let success = {(task: URLSessionDataTask, data: Any?) in
            if let parser = data as? XMLParser {
                // 1. 解析 XML，提取出内嵌的JSON 格式的字符串
                //
                let  delegate = ResponseXMLParserDelegate(parser: parser, keyElementName: "string")
                parser.parse()
                let xmlValue = delegate.elementValue?.data(using: .utf8)
                
                // 2. 字符串转换成JSon对象
                let jsonData = try? JSONSerialization.jsonObject(with: xmlValue!, options: []) as? [String: Any]
                
                // 3.
                if jsonData != nil {
                    completionQueue?.addOperation {
                        completion?(true, jsonData!, nil)
                    }
                }
                else {
                    let error = SysError(domain: ErrorDomain.networkService, code: ErrorCode.badData)
                    completionQueue?.addOperation {
                        completion?(false, nil, error)
                    }
                }
            }
        }
        
        let failure = { (task: URLSessionDataTask?, error: Error) in
            let error = error as NSError
            var sysError: SysError
            
            if let res = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] as? HTTPURLResponse {
                let code = res.statusCode
                sysError = SysError(domain: ErrorDomain.networkService, code: code)
            }
            else {
                sysError = SysError(error: error)
            }
            
            completionQueue?.addOperation {
                completion?(false, nil, sysError)
            }
        }
        
        let (method, path, params) = request.api
        let url = URL(string: path, relativeTo: self.baseURL)?.absoluteString
        
        let work = DispatchWorkItem(qos: .userInitiated, flags: .inheritQoS) {
            switch method {
            case .GET:
                _ = self.get(url!, parameters: params, progress: nil, success: success, failure: failure)
            case .POST:
                _ = self.post(url!, parameters: params, progress: nil, success: success, failure: failure)
            case .PUT:
                _ = self.put(url!, parameters: params, success: success, failure: failure)
            case .PATCH:
                _ = self.patch(url!, parameters: params, success: success, failure: failure)
            case .DELETE:
                _ = self.delete(url!, parameters: params, success: success, failure: failure)
            }
        }
        self.sendDispatchQueue.async(execute: work)
        
        return true
    }
    
    func send(request: Request, completion: ((Bool, [String: Any]?, SysError?) ->Void)?) -> Bool {
        return send(request: request, completionQueue: OperationQueue.main, completion: completion)
    }
    
    func close() -> Void {
        for task in self.tasks {
            task.cancel()
        }
    }
}
