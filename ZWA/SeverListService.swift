//
//  SeverListService.swift
//  ZWA
//
//  Created by mac on 2017/3/30.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ServerRepository {
    private var _db: Database!
    
    init(db: Database!) {
        self._db = db
    }
    
    var count: Int {
        get {
            var count = 0
            
            self._db.inDatabase({ (db: FMDatabase?) in
                let sql = "SELECT COUNT(*) FROM \(DbTabName.server.rawValue) ORDER BY rid"
                if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                    while rs.next() {
                        count = Int(rs.int(forColumnIndex: 0))
                    }
                }
            })
            
            return count
        }
    }
    
    subscript(index: Int) ->ServerStruct? {
        get {
            var server: ServerStruct?
            
            self._db.inDatabase({ (db: FMDatabase?) in
                let sql = "SELECT rid, an, url FROM \(DbTabName.server.rawValue) ORDER BY rowid LIMIT 1 OFFSET \(index)"
                if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                    while rs.next() {
                        server = ServerStruct(id: rs.string(forColumn: "rid"), name: rs.string(forColumn: "an"), url: rs.string(forColumn: "url"))
                    }
                }
            })
            
            return server
        }
    }
    
    func update(dictArray: [[String: Any]]) {
        self._db.inTransaction { (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
            let sql = "DELETE FROM \(DbTabName.server.rawValue)"
            db?.executeStatements(sql)
            
            for dic in dictArray {
                let sql = "INSERT OR REPLACE INTO \(DbTabName.server) (rid, an, upi, sc, url) VALUES(:rid, :areaname, :upi, :sc, :url)"
                db?.executeUpdate(sql, withParameterDictionary: dic)
            }
        }
    }
}

class SeverListService: NSObject {
    let repository = ServerRepository(db: ServiceCenter.publicDb!)
    private let _network = NetworkService(baseURL: URL(string: Configuration.routerUrl!))
 
    func update(completion: ((Bool, SysError?) -> Void)?) -> Void {
        
        let request = Request.servers
        _ = self._network.send(request: request) { [weak self] (success: Bool, data: [String: Any]?, error: SysError?) in
            guard let _self = self else {
                return
            }
            
            var success = success
            var error = error
            
            if success {
                if let items = data!["Table"] as? [[String: Any]] {
                    _self.repository.update(dictArray: items)
                }
                else {
                    success = false
                    error = SysError(domain: ErrorDomain.routerService, code: ErrorCode.badData)
                }
            }
            
            completion?(success, error)
        }
    }
}
