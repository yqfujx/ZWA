//
//  DatabaseManager.swift
//  ZWA
//
//  Created by mac on 2017/3/25.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class DatabaseManager: NSObject{
    enum TableName: String {
        case ServerList, Live, Detail
    }
    
    private static var dbPath: String {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as NSString
            return documentsDirectory.appendingPathComponent("sqlite.db")
        }
    }

/**
    单例对象
 */
    static let DBM = DatabaseManager()
    var dbQueue: FMDatabaseQueue!
    
    private override init() {
    }
    
    private func initDatabase(dbPath: String) -> Bool {
        // 建表
        guard let db = FMDatabase(path: dbPath), db.open() else {
            return false
        }

        var result = true
        repeat {
            // 服务器列表
            var tb = TableName.ServerList.rawValue
            if !db.tableExists(tb) {
                let sql = "CREATE TABLE \(tb) (" +
                "rid TEXT, an TEXT, upi TEXT, sc TEXT, url TEXT, PRIMARY KEY(rid))"
                guard db.executeStatements(sql) else {
                    print(db.lastError())
                    result = false
                    break
                }
            }
            
            
            // 现场表
            tb = TableName.Live.rawValue
            if !db.tableExists(tb) {
                let sql = "CREATE TABLE \(tb) (" +
                    "sortId INTEGER NOT NULL," +
                    "rid TEXT," +
                    "stationId TEXT," +
                    "carNo TEXT," +
                    "carLane TEXT," +
                    "overWeightRate NUMERIC," +
                    "overWeight NUMERIC," +
                    "length NUMERIC," +
                    "width NUMERIC," +
                    "height NUMERIC," +
                    "scaleDate DATE," +
                    "shaftType TEXT," +
                    "picUrl TEXT," +
                    "PRIMARY KEY(sortId)" +
                ")"
                guard db.executeStatements(sql) else {
                    print(db.lastError())
                    result = false
                    break
                }
            }
            
        } while false
        db.close()

        if result {
            self.dbQueue = FMDatabaseQueue(path: dbPath)
            if self.dbQueue == nil {
                result = false
            }
        }
        
        return result
    }
    
    func initDatabase() ->Bool {
        let dbPath = DatabaseManager.dbPath
        return self.initDatabase(dbPath: dbPath)
    }
    
    /*
    // 插入测试数据
    func insertTestData() {
        self.dbQueue.inTransaction { (database: FMDatabase?, _: UnsafeMutablePointer<ObjCBool>?) in
            if let db = database {
                
                do {
                    for n in 1..<2000 {
//                        let sql = "insert into live(MatchCode, Plate, LaneNo, OverRate, WidthOver, HeightOver, LengthOver, ScaleDate, PicURL) values(?, ?, ?, ?, ?, ?)"
//                        try db.executeUpdate(sql, values: [n, "赣A12345", "A1", 0.5, 16, 17, 18, NSDate()])
                        db.executeUpdate("INSERT INTO Live (sn, rid, Plate, LaneNo, OverRate, WidthOver, HeightOver, LengthOver, ScaleDate, PicURL) VALUES(:MatchCode, :Plate, :LaneNo, :OverRate, :WidthOver, :HeightOver, :LengthOver, :ScaleDate, :PicURL)", withParameterDictionary: [
                            "sn": n,
                            "rid": "S10105110220170117000014",
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
    */
    
    
    // 删除库文件
    func removeDatabase () {
        do {
            try FileManager.default.removeItem(atPath:DatabaseManager.dbPath)
        } catch let error{
            print("\(error.localizedDescription)")
        }
    }
}
