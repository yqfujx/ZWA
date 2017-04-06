//
//  CommonTypes.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit




/**
 定义服务器信息
 */
struct ServerStruct {
    var name: String!
    var url: String!
    
    init?(name: String?, url: String?) {
        guard name != nil && !name!.isEmpty && url != nil && !url!.isEmpty else {
            return nil
        }
        
        var lowcase = url!.lowercased()
        if lowcase.hasSuffix("?wsdl") {
            lowcase = String(lowcase.characters.dropLast(5))
        }
        self.name = name!
        self.url = lowcase
    }
}

/**
 账户信息
 */
struct Account {
    var server: ServerStruct!
    var userID: String!
    var password: String!
    var phone: String!
    var locationCode: String!
    var token: String!
    var didSignin: Bool = false
    
    init?(server: ServerStruct?, userID: String?, password: String?, phone: String? = nil, locationCode: String? = nil, token: String? = nil) {
        
        guard server != nil && userID != nil && !userID!.isEmpty
            && password != nil && !password!.isEmpty else {
                return nil
        }
        
        self.server = server
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
    case ServerList
    case Signin(String, String, String?)
    case LiveData(Int, Int)
    case RecentLiveData(Int, Int)
    
    var interface: (String, Any?) {
        var path = ""
        var params: Any?
        
        switch self {
        case .Signin(let userID, let password, let pushToken):
            path = "/loginUserIos"
            if pushToken != nil {
                params = ["logid": userID, "pwd": password, "pushToken": pushToken]
            }
            else {
                params = ["logid": userID, "pwd": password]
            }
            
        case .RecentLiveData(let from, let count):
            path = "/AreaIllegalIOS"
            params = ["from": from, "num": count]
            
        case .LiveData(let start, let count):
            path = "/livedata"
            params = ["start": start, "count": count]
            
        default:
            break
        }
        
        return (path, params)
    }
}
