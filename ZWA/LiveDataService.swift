//
//  LiveDataService.swift
//  ZWA
//
//  Created by mac on 2017/3/31.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

// MARK: - 现场数据结构
struct LiveData {
    let RID: String!
    let stationID: String!
    let carNo: String!
    let carLane: String!
    let overWeightRate: Double!
    let overWeight: Double!
    let overLength: Double!
    let overWidth: Double!
    let overHeight: Double!
    let checkDate: Date!
    let checkDatetime: Date!
    let timeInt: Int!
    let picUrl: String!
    
    init(dictionary: [AnyHashable: Any]) {
        self.RID = dictionary["RID"] as? String
        self.stationID = dictionary["stationID"] as? String
        self.carNo = dictionary["carNo"] as? String
        self.carLane = dictionary["carLane"] as? String
        self.overWeightRate = dictionary["overWeightRate"] as? Double
        self.overWeight = dictionary["overWeight"] as? Double
        self.overLength = dictionary["overLength"] as? Double
        self.overWidth = dictionary["overWidth"] as? Double
        self.overHeight = dictionary["overHeight"] as? Double
        self.checkDate = Date(string: dictionary["checkDate"] as! String, format: "yyyy-MM-dd HH:mm:ss")
        self.checkDatetime = Date(string: dictionary["checkDatetime"] as! String, format: "yyyy-MM-dd HH:mm:ss")
        self.timeInt = dictionary["timeInt"] as? Int
        self.picUrl = dictionary["picUrl"] as? String
    }
    
}


class LiveDataRepository {
    private var _db: Database!
    private var _count: Int?
    
    init(db: Database) {
        self._db = db
    }
    
    var count: Int {
        get {
            if self._count == nil {
                self._db.inDatabase { [unowned self] (db: FMDatabase?) in
                    let sql = "SELECT  COUNT(rowid) FROM \(DbTabName.live.rawValue)"
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
        
        self._db.inTransaction { [unowned self] (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
            let  sql = "INSERT OR REPLACE INTO \(DbTabName.live.rawValue) " +
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
            let sql = "SELECT * FROM \(DbTabName.live.rawValue) ORDER BY checkDatetime, rowid LIMIT 1 OFFSET \(index)"
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
                let sql = "SELECT * FROM \(DbTabName.live.rawValue) ORDER BY checkDatetime DESC, rowid DESC LIMIT 1"
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

fileprivate class LiveSyncOperation: Operation {
    weak var repository: LiveDataRepository?
    var completionQueue: OperationQueue!
    var success = false
    var error: SysError?
    
    override init() {
        self.completionQueue = OperationQueue()
        self.completionQueue.maxConcurrentOperationCount = 1
        self.completionQueue.qualityOfService = .userInitiated
    }
    
    override func main() {
        guard let last  = self.repository?.last else {
            self.cancel()
            return
        }
        
        let start = last.checkDatetime.addingTimeInterval(1)
        let end = Date()
        var page = 1
        let token = ServiceCenter.currentAccount?.token
        
        //
        let group = DispatchGroup()
        group.enter()
        
        var stop = false
        while !stop && !isCancelled {
            let request = Request.liveData(start, end, page, token!)
            _ = ServiceCenter.network?.send(request: request, completionQueue: self.completionQueue) { [weak self] (success: Bool, dictionary: [String : Any]?, error: SysError?) in
                
                guard let _self = self else {
                    return
                }
                
                if !_self.isCancelled {
                    _self.success = success
                    _self.error = error
                    if _self.success {
                        if let pageCount = dictionary!["pagecount"] as? Int, let array = dictionary!["Table"] as? [[String: Any]] {
                            _ = _self.repository?.update(array: array)
                            
                            page += 1
                            if page >= pageCount { // 已收到最后一页
                                stop = true
                            }
                        }
                        else {
                            _self.success = false
                            _self.error = SysError(domain: ErrorDomain.liveDataService, code: ErrorCode.badData)
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

class LiveDataService: NSObject {
    let rowsPerPage = 40
    let repository = LiveDataRepository(db: ServiceCenter.privateDb!)
//    let sendQueue = { () ->OperationQueue in
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        queue.qualityOfService = .userInitiated
//        return queue
//    }()
    var sendQueue: OperationQueue!
    
//    let completionQueue = { () ->OperationQueue in
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        queue.qualityOfService = .userInitiated
//        return queue
//    }()
    var completionQueue: OperationQueue!
    
    override init() {
        self.sendQueue = OperationQueue.init()
        self.sendQueue.maxConcurrentOperationCount = 1
        self.sendQueue.qualityOfService = .userInitiated
        
        self.completionQueue = OperationQueue.init()
        self.completionQueue.maxConcurrentOperationCount = 1
        self.completionQueue.qualityOfService = .userInitiated
    }
    
    deinit {
        self.stop()
    }
    
    func sync(completion: ((Bool, SysError?) ->Void)?) -> Bool {
        if self.sendQueue.operationCount > 0 {
            return false
        }
        
        //
        // 本地数据库中没有记录，则只同步最近的40条记录
        if self.repository.count <= 0 {
            self.sendQueue.addOperation { [weak self] () in
                guard let _self = self else {
                    return
                }
                
                let request = Request.recentLiveData(ServiceCenter.currentAccount!.userID, _self.rowsPerPage, ServiceCenter.currentAccount!.token!)
                _ = ServiceCenter.network?.send(request: request, completionQueue: _self.completionQueue, completion: { [weak _self] (success: Bool, dictionary: [String : Any]?, error: SysError?) in
                    
                    guard let _self = _self else {
                        return
                    }
                    
                    var success = success
                    var error = error
                    
                    if success {
                        if let array = dictionary!["Table"] as? [[String: Any]] {
                            _ = _self.repository.update(array: array)
                        }
                        else {
                            success = false
                            error = SysError(domain: ErrorDomain.liveDataService, code: ErrorCode.badData)
                        }
                    }
                    
                    // 通知主线程更新界面
                    DispatchQueue.main.async {
                        completion?(success, error)
                    }
                })
            }
        }
        else {
            let op = LiveSyncOperation()
            op.repository = self.repository
            op.completionBlock = { [weak op] () in
                guard let op = op else {
                    return
                }
                
                if !op.isCancelled {
                    
                    let success = op.success
                    let error = op.error
                    // 通知主线程更新界面
                    DispatchQueue.main.async {
                        completion?(success, error)
                    }
                }
            }
            self.sendQueue.addOperation(op)
        }
        
        return true
    }
    
    func stop() -> Void {
        self.sendQueue.cancelAllOperations()
        self.completionQueue?.cancelAllOperations()
    }

}
