//
//  SeverListService.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class SeverListService: NSObject {
    let serviceUrl = "http://192.134.2.166:8080/Service1.asmx/AreaUrlJsStr"
    
    var serverCount: Int {
        var count = 0
        
        DatabaseManager.DBM.dbQueue.inDatabase({ (db: FMDatabase?) in
            let sql = "SELECT COUNT(*) FROM \(DatabaseManager.TableName.ServerList) ORDER BY rid"
            if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                while rs.next() {
                    count = Int(rs.int(forColumnIndex: 0))
                }
            }
        })
        
        return count
    }

    func serverAtIndexPath(indexPath: IndexPath) -> ServerStruct? {
        var server: ServerStruct?
        
        DatabaseManager.DBM.dbQueue.inDatabase({ (db: FMDatabase?) in
            let sql = "SELECT an, url FROM \(DatabaseManager.TableName.ServerList) ORDER BY rid LIMIT 1 OFFSET \(indexPath.row)"
            if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                while rs.next() {
                    server = ServerStruct(name: rs.string(forColumn: "an"), url: rs.string(forColumn: "url"))
                }
            }
        })
        
        return server
    }

    func downloadList(completion: ((Bool) -> Void)?) -> Bool {
        let s = { (task: URLSessionDataTask, data: Data?) -> Void in
            self.saveData(data: data ) ? completion?(true) : completion?(false)
        }
        
        let f = {(task: URLSessionDataTask?, error: Error) -> Void in
            if completion != nil {
                completion!(false)
            }
        }
        
        let request = Request.ServerList
        return NetworkService.service.post(url: self.serviceUrl, request: request, progress: nil, success: s, failure: f) != nil
    }
    
    /** 服务器列表的网络数据存入数据
     */
    func saveData(data: Data?) -> Bool {
        guard data != nil else {
            return false
        }
        
        do {
            //　解析 JSON 数据
            let jsonObj = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            if let serverArray = jsonObj?["Table"] as? [[String: Any]] {
                DatabaseManager.DBM.dbQueue.inTransaction({ (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
                    var sql: String
                    for aServer in serverArray {
                        sql = "INSERT OR REPLACE INTO \(DatabaseManager.TableName.ServerList) (rid, an, upi, sc, url) VALUES(:rid, :an, :upi, :sc, :url)"
                        db?.executeUpdate(sql, withParameterDictionary: aServer)
                    }
                })
                
            }
        }
        catch let error {
            print("\(error.localizedDescription)")
            return false
        }
        
        return true
    }

}
