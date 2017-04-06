//
//  ServiceCenter.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ServiceCenter: NSObject {
    static let center = ServiceCenter()
    
    let configuration = Configuration.current
    let dbm = DatabaseManager.DBM
    
    var network: NetworkService {
        get {
            return NetworkService.service
        }
    }
    
    
    private override init() {
    }
    
    func start() -> Bool {
        self.configuration.load()
//        self.dbm.removeDatabase()
        if !self.dbm.initDatabase() {
            return false
        }
        
        return true
    }
}
