//
//  DatabaseManager.swift
//  ZWA
//
//  Created by mac on 2017/3/25.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

enum DbTabName: String {
    case server, userInfo, station, live, search
}

class Database: FMDatabaseQueue {
    func  removeAll() -> Void {
        do {
            try FileManager.default.removeItem(atPath:self.path)
        } catch let error{
            debugPrint("\(error.localizedDescription)")
        }
    }
}

class DatabaseManager: NSObject{
    
    private static var dbDirectory: String {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }
    }
    
    static func publicDb() ->Database! {
        let path = (self.dbDirectory as NSString).appendingPathComponent("public.db")
        if let db = FMDatabase(path: path) {
            db.open()
            
            if !db.tableExists(DbTabName.server.rawValue) {
                let sql = "CREATE TABLE \(DbTabName.server.rawValue) (rid TEXT, an TEXT, upi TEXT, sc TEXT,  url TEXT)"
                db.executeStatements(sql)
            }
            
            db.close()
        }
        
        return Database(path: path)
    }
    
    static func privateDb(with userID: String) ->Database {
        let path = (self.dbDirectory as NSString).appendingPathComponent(userID + ".db")
        if let db = FMDatabase(path: path) {
            db.open()
            
            var tabName = DbTabName.userInfo.rawValue
            if !db.tableExists(tabName) {
                let sql = "CREATE TABLE \(tabName) (" +
                    "userID TEXT," +
                    "password TEXT," +
                    "phone TEXT," +
                    "token TEXT," +
                    "expireTime TEXT," +
                    "serverUrl TEXT," +
                    "PRIMARY KEY(userID)" + 
                 ")"
                db.executeStatements(sql)
            }
            
            tabName = DbTabName.station.rawValue
            if !db.tableExists(tabName) {
                let sql = "CREATE TABLE \(tabName) (" +
                    "zoneID TEXT," +
                    "stationID TEXT," +
                    "stationName TEXT," +
                    "PRIMARY KEY(zoneID, stationID)" +
               ")"
                db.executeStatements(sql)
            }
            
            tabName = DbTabName.live.rawValue
            if !db.tableExists(tabName) {
                let sql = "CREATE TABLE \(tabName) (" +
                    "RID TEXT UNIQUE," +
                    "stationID TEXT," +
                    "carNo TEXT," +
                    "carLane TEXT," +
                    "overWeightRate NUMERIC," +
                    "overWeight NUMERIC," +
                    "overLength NUMERIC," +
                    "overWidth NUMERIC," +
                    "overHeight NUMERIC," +
                    "checkDate DATETIME," +
                    "checkDatetime DATETIME," +
                    "timeInt INTEGER," +
                    "picUrl TEXT" +
                ")"
                db.executeStatements(sql)
            }
            
            var sql = "CREATE INDEX IF NOT EXISTS index_liveDesc ON \(DbTabName.live.rawValue) (" +
                "checkDate DESC, checkDatetime DESC" +
                ")"
            db.executeStatements(sql)
  
            sql = "CREATE INDEX IF NOT EXISTS index_liveAsc ON \(DbTabName.live.rawValue) (" +
                "checkDate, checkDatetime" +
            ")"
            db.executeStatements(sql)

            db.close()
        }
        
        return Database(path: path)
    }
}
