//
//  AppConfiguration.swift
//  ZWA
//
//  Created by mac on 2017/3/21.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit


class AppConfiguration: NSObject {

    let SERVER_LIST_FILE_NAME = "serverlist.plist"
    let defaultSession = HTTPSession.localSession()
    
    
    private var _servers:[ServerStruct]!
    var servers: [ServerStruct] {
        get {
            if _servers == nil {
                _servers = localServerList()
            }
            return _servers
        }
        set {
            _servers = newValue
            saveServerList(array: newValue)
        }
    }
    
    private override init () {
    }
    
    /**
     单例
     */
    static let configuration = AppConfiguration()

    /**
     加载本地服务器列表
     */
    func localServerList() -> [ServerStruct] {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let filePath = documentsDirectory.appendingPathComponent(SERVER_LIST_FILE_NAME)
        
        if let list = NSArray(contentsOfFile: filePath) {
            return Array(list) as! [ServerStruct]
        }

        return []
    }
    
    /**
     保存服务器列表
     */
    private func saveServerList(array: [ServerStruct])  {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let filePath = documentsDirectory.appendingPathComponent(SERVER_LIST_FILE_NAME)
        (array as NSArray).write(toFile:  filePath, atomically: true)
    }
    
}
