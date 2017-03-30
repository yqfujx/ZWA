//
//  DatabaseManager.swift
//  ZWA
//
//  Created by mac on 2017/3/25.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

//let DBTable_Live = "Live"
//let DBTable_Detail = "Detail"

class DatabaseManager: NSObject{
    enum TableName: String {
        case ServerList, Live, Detail
    }

/**
    单例对象
 */
    static let DBM = { () -> DatabaseManager? in 
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let dbPath = documentsDirectory.appendingPathComponent("sqlite.db")
        return DatabaseManager(dbPath: dbPath)
    }()
    
    let dbQueue: FMDatabaseQueue!
    
    private init?(dbPath: String) {
        // 建表
        if let db = FMDatabase(path: dbPath) {
            db.open()
            
            // 服务器列表
            var tb = TableName.ServerList.rawValue
            if !db.tableExists(tb) {
                let sql = "CREATE TABLE \(tb) (" +
                "rid TEXT, an TEXT, upi TEXT, sc TEXT, url TEXT, PRIMARY KEY(rid))"
                guard db.executeStatements(sql) else {
                    print(db.lastError())
                    return nil
                }
            }
            
            
            // 现场表
            tb = TableName.Live.rawValue
            if !db.tableExists(tb) {
                let sql = "CREATE TABLE \(tb) (" +
                    "MatchCode INTEGER NOT NULL," +
                    "Plate TEXT," +
                    "LaneNo TEXT," +
                    "OverRate NUMERIC," +
                    "WidthOver NUMERIC," +
                    "HeightOver NUMERIC," +
                    "LengthOver NUMERIC," +
                    "ScaleDate DATE," +
                    "ShaftType TEXT," +
                    "PicURL TEXT," +
                    "PRIMARY KEY(MatchCode)" +
                ")"
                guard db.executeStatements(sql) else {
                    print(db.lastError())
                    return nil
                }
            }
            
//            // 详情表
//            tableName = DBTable_Detail
//            if !db.tableExists(tableName) {
//                let sql = "CREATE TABLE \(tableName)(" +
//                    "MatchCode INTEGER NOT NULL" +
//                ");"
//                guard db.executeStatements(sql) else {
//                    return nil
//                }
//            }
            
            db.close()
        }
        else {
            return nil
        }
        
        self.dbQueue = FMDatabaseQueue(path: dbPath)
        guard self.dbQueue != nil else {
            return nil
        }
        
        super.init()
    }
    
    // 插入测试数据
    func insertTestData() {
        self.dbQueue.inTransaction { (database: FMDatabase?, _: UnsafeMutablePointer<ObjCBool>?) in
            if let db = database {
                
                do {
                    for n in 1..<2000 {
//                        let sql = "insert into live(MatchCode, Plate, LaneNo, OverRate, WidthOver, HeightOver, LengthOver, ScaleDate, PicURL) values(?, ?, ?, ?, ?, ?)"
//                        try db.executeUpdate(sql, values: [n, "赣A12345", "A1", 0.5, 16, 17, 18, NSDate()])
                        db.executeUpdate("INSERT INTO Live (MatchCode, Plate, LaneNo, OverRate, WidthOver, HeightOver, LengthOver, ScaleDate, PicURL) VALUES(:MatchCode, :Plate, :LaneNo, :OverRate, :WidthOver, :HeightOver, :LengthOver, :ScaleDate, :PicURL)", withParameterDictionary: [
                            "MatchCode": n,
                            "Plate": "赣A12345",
                            "LaneNo": "A1",
                            "OverRate": 50,
                            "WidthOver": 16,
                            "HeightOver": 17,
                            "LengthOver": 18,
                            "ScaleDate": Date(),
                            "PicURL": "http://car3.autoimg.cn/cardfs/product/g9/M00/5F/52/1024x0_1_q87_autohomecar__wKgH0FcZg42AD3JMAAQ05uWN0ak963.jpg"])
                    }
                }
                catch {
                    print("\(db.lastError().localizedDescription)")
                    return
                }
            }
        }
    }
    
    // 删除库文件
    static func removeDB () {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let dbPath = documentsDirectory.appendingPathComponent("sqlite.db")
    
        do {
            try FileManager.default.removeItem(atPath:dbPath)
        } catch {
            
        }
    }
}
