//
//  SearchingService.swift
//  ZWA
//
//  Created by osx on 2017/8/6.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class SearchingResultRepository {
    private var _db: Database!
    private var _count: Int?
    private var _tableName: String!
    
    init(db: Database) {
        self._db = db
        self._tableName = "searchingResult"
        
        self._db.inTransaction { (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
            if !db!.tableExists(self._tableName) {
                let sql = "CREATE TEMPORARY TABLE \(self._tableName!) (" +
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
                db?.executeStatements(sql)
            }
        } // end inTransaction
    }
    
    var count: Int {
        get {
            if self._count == nil {
                self._db.inDatabase { (db: FMDatabase?) in
                    let sql = "SELECT COUNT(rowid) FROM \(self._tableName!)"
                    if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                        while rs.next() {
                            self._count = Int(rs.int(forColumnIndex: 0))
                        }
                    }
                }
            }
            
            return self._count!
        }
    }
    
    private func dateValue(with string: String) -> Date? {
        if let date = Date(string: string, format: "yyyy/M/dd HH:mm:ss") {
            return date
        }
        else if let date = Date(string: string, format: "yyyy/MM/dd HH:mm:ss") {
            return date
        }
        else if let date = Date(string: string, format: "yyyy-M-dd HH:mm:ss") {
            return date
        }
        else if let date = Date(string: string, format: "yyyy-MM-dd HH:mm:ss") {
            return date
        }
        else {
            return nil
        }
    }
    
    func update(array: [[String: Any]]) -> Int {
        var rows = 0
        
        self._db.inTransaction { (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
            let  sql = "INSERT OR REPLACE INTO \(self._tableName!) " +
                "(RID, stationID, carNo, carLane, overWeightRate, overWeight, overLength, overWidth, overHeight, checkDate, checkDatetime, timeInt, picUrl) " +
            "VALUES(:RId, :stationid, :CarNo, :CarLane, :OverWeightRate, :OverWeight, :OverLength, :OverWidth, :OverHeight, :checkDate, :CheckTime, :TimeInt, :PicURL)"
            for var aServer in array {
                if let timeString = aServer["CheckTime"] as? String {
                    let date = self.dateValue(with: timeString)
                    let timeString = date?.string(with: "yyyy-MM-dd HH:mm:ss")
                    let dateString = date?.string(with: "yyyy-MM-dd")
                    
                    aServer["checkDate"] = dateString
                    aServer["CheckTime"] = timeString
                    
                    guard db!.executeUpdate(sql, withParameterDictionary: aServer) else {
                        debugPrint("\(db!.lastError())")
                        break
                    }
                }
            }
            
            rows = Int(db!.changes())
            self._count = nil
        }
        return rows
    }
    
    subscript(index: Int) ->LiveData? {
        guard index >= 0 && index < self.count else {
            return nil
        }
        
        var data: LiveData?
        
        self._db.inDatabase { (db: FMDatabase?) in
            let sql = "SELECT * FROM \(self._tableName!) ORDER BY checkDatetime, rowid LIMIT 1 OFFSET \(index)"
            if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                while rs.next() {
                    data = LiveData(dictionary: rs.resultDictionary())
                }
            }
        }
        
        return data
    }
    
    var last: LiveData? {
        get {
            if self.count <= 0 {
                return nil
            }
            
            var data: LiveData?
            
            self._db.inDatabase { (db: FMDatabase?) in
                let sql = "SELECT * FROM \(self._tableName!) ORDER BY checkDatetime DESC, rowid DESC LIMIT 1"
                if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                    while rs.next() {
                        data = LiveData(dictionary: rs.resultDictionary())
                    }
                }
            }
            
            return data
        }
    }
    
}

fileprivate class SearchingOperation: Operation {
    weak var repository: SearchingResultRepository?
    weak var completionQueue: OperationQueue?
    var stationID: String?
    var vehicleID: String?
    var overloadStatus: Int?
    var overRateLower: Int?
    var overRateUpper: Int?
    var lane: String?
    var ealiestTime: Date?
    var lastTime: Date?
    
    
    var success = false
    var error: SysError?
    
    override func main() {
        var page = 1
        let token = ServiceCenter.currentAccount?.token
        
        //
        let group = DispatchGroup()
        group.enter()
        
        var stop = false
        while !stop && !isCancelled {
            let request = Request.search(page, token!, self.stationID, self.vehicleID, self.overRateLower, self.overRateUpper, self.overloadStatus, self.lane, self.ealiestTime, self.lastTime)
            _ = ServiceCenter.network?.send(request: request, completionQueue: self.completionQueue) { (success: Bool, dictionary: [String : Any]?, error: SysError?) in
                
                if !self.isCancelled {
                    self.success = success
                    self.error = error
                    if self.success {
                        if let pageCount = dictionary!["pagecount"] as? Int, let array = dictionary!["Table"] as? [[String: Any]] {
                            _ = self.repository?.update(array: array)
                            
                            page += 1
                            if page >= pageCount { // 已收到最后一页
                                stop = true
                            }
                        }
                        else {
                            self.success = false
                            self.error = SysError(domain: ErrorDomain.liveDataService, code: ErrorCode.badData)
                            stop = true
                        }
                    }
                    else {
                        stop = true
                    }
                }
                
                group.leave()
            } // end closure
            
            // 阻塞当前线程，直到当前线程被取消，或完成一次网络请求。当前线程是发送线程。
            // 当完成一次网络请求后，在回调闭包中检查是否无异常，或已收到最后一页，
            // 若是，则当前线程跳出外层循环，线程结束；否则当前线程回到外循环开头，继续请求下一页，
            while !isCancelled {
                if group.wait(timeout: DispatchTime(uptimeNanoseconds: 1_000_000)) == .success {
                    break
                }
            }
        } // end while
    }
}

class SearchingService: NSObject {
    let rowsPerPage = 40
    let repository = SearchingResultRepository(db: ServiceCenter.privateDb!)
    
    private let sendQueue = { () ->OperationQueue in
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    let completionQueue = { () ->OperationQueue in
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    
    func searchWith(stationID: String?,
                    vehicleID: String?,
                    overloadStatus: Int?,
                    overRateLower: Int?,
                    overRateUpper: Int?,
                    lane: String?,
                    earliestTime: Date?,
                    lastTime: Date?,
                    completion: ((Bool, SysError?) ->Void)?) -> Bool {
        if self.sendQueue.operationCount > 0 {
            return false
        }
        
        //
        let op = SearchingOperation()
        op.repository = self.repository
        op.completionQueue = self.completionQueue
        op.stationID = stationID
        op.vehicleID = vehicleID
        op.overloadStatus = overloadStatus
        op.overRateLower = overRateLower
        op.overRateUpper = overRateUpper
        op.lane = lane
        op.ealiestTime = earliestTime
        op.lastTime = lastTime
        op.completionBlock = {
            if !op.isCancelled {
                // 通知主线程更新界面
                DispatchQueue.main.async {
                    completion?(op.success, op.error)
                }
            }
        }
        self.sendQueue.addOperation(op)
        
        return true
    }
    
    func stop() -> Void {
        self.sendQueue.cancelAllOperations()
        self.completionQueue.cancelAllOperations()
    }
    
}
