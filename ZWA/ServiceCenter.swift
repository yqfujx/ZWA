//
//  ServiceCenter.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ServiceCenter: NSObject {
    static var publicDb: Database! {
        get {
            return DatabaseManager.publicDb()
        }
    }
    
    static private var _privateDb: Database?
    static var privateDb: Database? {
        get {
            return self._privateDb
        }
    }
    static private var _network: NetworkService?
    static var network: NetworkService? {
        get {
            return self._network
        }
    }
    static private var _currentAccount: Account?
    static var currentAccount: Account? {
        get {
            return self._currentAccount
        }
        set {
            self._currentAccount = newValue
            self.network?.close()
            self.privateDb?.close()
            
            if let newValue = newValue {
                self._privateDb = DatabaseManager.privateDb(with: newValue.userID)
                self._network = NetworkService(baseURL: URL(string: newValue.serverUrl))
            }
            else {
                self._privateDb = nil
                self._network = nil
            }
        }
    }
    
    static func start() -> Void {
        _ = DatabaseManager.publicDb()
    }
    
    static func stop() ->Void {
        self.network?.close()
        self.privateDb?.close()
    }
    
    static func initAccount(userID: String) ->Account? {
         let db = DatabaseManager.privateDb(with: userID)
        
        db.inTransaction({ (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
            let sql = "SELECT userID, serverUrl, password, token FROM \(DbTabName.userInfo.rawValue) WHERE userID=?"
            if let rs = db?.executeQuery(sql, withArgumentsIn: [userID]) {
                while rs.next() {
                    let serverUrl = rs.string(forColumn: "serverUrl")
                    let password = rs.string(forColumn: "password")
                    let token = rs.string(forColumn: "token")
                    
                    ServiceCenter._currentAccount = Account(serverUrl: serverUrl!, userID: userID, password: password!)
                    ServiceCenter._currentAccount?.token = token
                }
            }
        })
        self._privateDb = db
        self._network = NetworkService(baseURL: URL(string: (self._currentAccount?.serverUrl)!))
        
        return self._currentAccount
    }
}
