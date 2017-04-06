//
//  LiveDataService.swift
//  ZWA
//
//  Created by mac on 2017/3/31.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class LiveDataService: NSObject {
    
    // MARK: - 现场数据结构
    struct LiveData {
        let sortId: Int!
        let rid: String!
        let stationId: String!
        let carNo: String!
        let carLane: String!
        let overWeightRate: Double!
        let overWeight: Double!
        let length: Double!
        let width: Double!
        let height: Double!
        let scaleDate: Date!
        let shaftType: String!
        let picUrl: String!
        
        init(dictionary: [AnyHashable: Any]) {
            self.sortId = dictionary["sortId"] as? Int
            self.rid = dictionary["rid"] as? String
            self.stationId = dictionary["stationId"] as? String
            self.carNo = dictionary["carNo"] as? String
            self.carLane = dictionary["carLane"] as? String
            self.overWeightRate = dictionary["overWeightRate"] as? Double
            self.overWeight = dictionary["overWeight"] as? Double
            self.length = dictionary["length"] as? Double
            self.width = dictionary["width"] as? Double
            self.height = dictionary["height"] as? Double
            self.scaleDate = dictionary["scaleDate"] as? Date
            self.shaftType = dictionary["shaftType"] as? String
            self.picUrl = dictionary["picUrl"] as? String
        }
    }

    // MARK: - 接取数据的子线程
    class PullDataOperation: Operation {
        
        var dataCollection: (lower: Int, upper: Int, count: Int) = (Int.max, Int.min, 0)
        
        /** 服务器列表的网络数据存入数据
         
         @return 收到的记录数
         */
        func saveData(data: Data?) -> (Int, Int, Int)? {
            guard data != nil else {
                return nil
            }
            
            var collection: (lower: Int, upper: Int, count: Int) = (Int.max, Int.max, 0)
            
            do {
                //　解析 JSON 数据
                let jsonObj = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                if let array = jsonObj?["Table"] as? [[String: Any]] {
                    DatabaseManager.DBM.dbQueue.inTransaction({ (db: FMDatabase?, rollBack: UnsafeMutablePointer<ObjCBool>?) in
                        var sql: String
                        for aServer in array {
                            sql = "INSERT OR REPLACE INTO \(DatabaseManager.TableName.Live) " +
                                "(sortId, rid, stationId, carNo, carLane, overWeightRate, overWeight, length, width, height, scaleDate, shaftType, picUrl) " +
                            "VALUES(:sortId, :rid, :stationId, :carNo, :carLane, :overWeightRate, :overWeight, :lenght, :width, :height, :scaleDate, :shaftType, :picUrl)"
                            guard db!.executeUpdate(sql, withParameterDictionary: aServer) else {
                                print("\(db!.lastError())")
                               break;
                            }
                            
                            let rid = Int((aServer["sortId"] as? String)!)
                            collection.lower = min(collection.lower, rid!)
                            collection.upper = max(collection.upper, rid!)
                            collection.count += 1
                        }
                    })
                    
                }
            }
            catch let error {
                print("\(error.localizedDescription)")
                return nil
            }
            
            return collection
        }
        
        func pullRecent(from: Int, count: Int, completion: ((Bool, (Int, Int, Int)?) ->Void)?) -> Bool {
            let p = {(progress: Progress) -> Void in
            }
            
            let s = {(task: URLSessionDataTask, data: Data?) -> Void in
                let collection = self.saveData(data: data)
                if completion != nil {
                    completion!(collection != nil, collection)
                }
            }
            let f = {(task: URLSessionDataTask?, error: Error) -> Void in
                if completion != nil {
                    completion!(false, nil)
                }
            }
            
            let reqeust = Request.RecentLiveData(from, count)
            return NetworkService.service.post(request: reqeust, progress: p, success: s, failure: f) != nil
        }
        
        func pullRange(lower: Int, upper: Int, completion: ((Bool, (Int, Int, Int)?) -> Void)?) -> Bool {
            let p = {(progress: Progress) -> Void in
            }
            
            let s = { (task: URLSessionDataTask, data: Data?) -> Void in
                let collection = self.saveData(data: data)
                if completion != nil {
                    completion!(collection != nil, collection)
                }
            }
            
            let f = {(task: URLSessionDataTask?, error: Error) -> Void in
                if completion != nil {
                    completion!(false, nil)
                }
            }
            
            let reqeust = Request.LiveData(lower, upper)
            return NetworkService.service.post(request: reqeust, progress: p, success: s, failure: f) != nil
        }
        
        override func main() {
            var complete = true
            
            DatabaseManager.DBM.dbQueue.inDatabase { (db: FMDatabase?) in
                let sql = "SELECT sortId FROM \(DatabaseManager.TableName.Live) ORDER BY sortId DESC LIMIT 1"
                if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                    while rs.next() {
                        self.dataCollection.upper = Int(rs.int(forColumn: "sortId"))
                    }
                }
            }
            
            let sema = DispatchSemaphore(value: 0)

            // 本地没有记录，则只拉取最新的若干条记录
            if self.dataCollection.upper <= 0 {
                if !self.pullRecent(from: 0, count: 100, completion: { (success: Bool, collection: (Int, Int, Int)?) in
                    if success {
                        self.dataCollection = collection!
                    }
                    else {
                        complete = false
                    }
                    sema.signal()
                }) {
                    sema.signal()
                    complete = false
                }
                
                sema.wait(timeout: .distantFuture)
            }
            else {
                var loop = true
                while !self.isCancelled && loop {
                    guard self.pullRange(lower: self.dataCollection.upper + 1, upper: self.dataCollection.upper + 201, completion: { (success: Bool, collection: (lower: Int, upper: Int, count: Int)?) in
                        if success {
                            if collection!.count > 0 {
                                self.dataCollection.lower = min(self.dataCollection.lower, collection!.lower)
                                self.dataCollection.upper = max(self.dataCollection.upper, collection!.upper)
                                self.dataCollection.count += collection!.count
                           }
                            else { //这表明最新数据已经拉完了
                                loop = false
                           }
                        }
                        else {
                            loop = false
                            complete = false
                        }
                        sema.signal()
                    })  else { // 操作异常，直接退出循环，线程结束
                        complete = false
                        break
                    }
                    
                    sema.wait(timeout: .distantFuture)
                } // end of while
                
            } // end of else
          
            
//            if !self.isCancelled {
                LiveDataService.service.pullingComplete(success: complete, collection: self.dataCollection)
//            }
        }
    }
    
    
    
    
    // MARK: - 以下是LiveDataService的定义
    // MARK: - 消息
    enum ServiceNotification : String {
        case dataUpdated
    }
    
    // MARK: - 属性
    static let service = LiveDataService()
    var visibleCollection: (lower: Int, upper: Int, count: Int) = (Int.max, Int.min, 0)
    
    private var writerQueue: OperationQueue
    private var completion: ((Bool, (Int, Int, Int)?) -> Void)?

    // MARK: - 方法
    private override init() {
        self.writerQueue = OperationQueue()
        
        super.init()
        
        DatabaseManager.DBM.dbQueue.inDatabase { (db: FMDatabase?) in
            let sql = "SELECT rid FROM \(DatabaseManager.TableName.Live) ORDER BY rid DESC LIMIT 40"
            if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                while rs.next() {
                    let rid = Int(rs.int(forColumn: "rid"))
                    self.visibleCollection.lower = min(self.visibleCollection.lower, rid)
                    self.visibleCollection.upper = max(self.visibleCollection.upper, rid)
                    self.visibleCollection.count += 1
                }
            }
        }
    }
    
    deinit {
        self.stop()
    }
    
    func stop() -> Void {
        self.writerQueue.cancelAllOperations()
        self.writerQueue.waitUntilAllOperationsAreFinished()
    }

    func pullData(completion: ((Bool, (Int, Int, Int)?) -> Void)?) -> Void {
        self.completion = completion
        
        if self.writerQueue.operationCount <= 0 {
            let op = PullDataOperation()
            self.writerQueue.addOperation(op)
        }
    }
    
    func pullingComplete(success: Bool, collection: (lower: Int, upper: Int, count: Int)) -> Void {
        
        OperationQueue.main.addOperation {
            if success {
                self.visibleCollection.lower = min(self.visibleCollection.lower, collection.lower)
                self.visibleCollection.upper = max(self.visibleCollection.upper, collection.upper)
                self.visibleCollection.count += collection.count
            }
            
            if self.completion != nil {
                self.completion!(success, collection)
            }
            
            self.completion = nil
        }
    }
    
    
    func dataAtIndexPath(indexPath: IndexPath) -> LiveData? {
        
        var data: LiveData!
        
        DatabaseManager.DBM.dbQueue.inDatabase({ (db: FMDatabase?) in
            let sql = "SELECT * FROM \(DatabaseManager.TableName.Live) WHERE (rid >= \(self.visibleCollection.lower)) AND (rid <= \(self.visibleCollection.upper)) ORDER BY sortId LIMIT 1 OFFSET \(indexPath.row)"
            if let rs = db?.executeQuery(sql, withArgumentsIn: nil) {
                while rs.next() {
                    data = LiveData(dictionary: rs.resultDictionary())
                }
            }
        })
        
        return data
    }
    
    func expandVisibleRange(direction: Int)  {
        
    }
}
